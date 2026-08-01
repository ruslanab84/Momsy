#!/usr/bin/env python3
"""Generate WHOGrowthStandards.swift from the official WHO Child Growth Standards.

The app plots P3/P15/P50/P85/P97 bands for months 0-24 per sex. Those numbers are
medical reference data, so they are transcribed mechanically from the WHO tables
rather than typed by hand, and this script stays in the repo so they can be
re-derived and audited.

xlsx is a zip of XML, so zipfile + ElementTree is enough - no third-party deps.

Usage: python3 scripts/generate_who_tables.py
"""

from __future__ import annotations

import io
import pathlib
import subprocess
import xml.etree.ElementTree as ET
import zipfile

BASE = (
    "https://cdn.who.int/media/docs/default-source/child-growth/"
    "child-growth-standards/indicators"
)

SOURCES = {
    # (metric, sex): url
    ("weight", "boys"): f"{BASE}/weight-for-age/tab_wfa_boys_p_0_5.xlsx",
    ("weight", "girls"): f"{BASE}/weight-for-age/tab_wfa_girls_p_0_5.xlsx",
    ("height", "boys"): f"{BASE}/length-height-for-age/tab_lhfa_boys_p_0_2.xlsx",
    ("height", "girls"): f"{BASE}/length-height-for-age/tab_lhfa_girls_p_0_2.xlsx",
    ("head", "boys"): f"{BASE}/head-circumference-for-age/tab_hcfa_boys_p_0_5.xlsx",
    ("head", "girls"): f"{BASE}/head-circumference-for-age/tab_hcfa_girls_p_0_5.xlsx",
}

PERCENTILES = ("P3", "P15", "P50", "P85", "P97")
MAX_MONTH = 24
NS = "{http://schemas.openxmlformats.org/spreadsheetml/2006/main}"

OUTPUT = (
    pathlib.Path(__file__).resolve().parent.parent
    / "Momsy/Features/Tracking/Domain/Models/WHOGrowthStandards.swift"
)


def column_index(reference: str) -> int:
    """'B7' -> 1. xlsx omits empty cells, so position in the row means nothing."""
    letters = "".join(c for c in reference if c.isalpha())
    index = 0
    for letter in letters:
        index = index * 26 + (ord(letter.upper()) - ord("A") + 1)
    return index - 1


def sheet_rows(payload: bytes) -> list[list[str]]:
    archive = zipfile.ZipFile(io.BytesIO(payload))

    shared: list[str] = []
    if "xl/sharedStrings.xml" in archive.namelist():
        root = ET.fromstring(archive.read("xl/sharedStrings.xml"))
        shared = [
            "".join(t.text or "" for t in si.iter(NS + "t"))
            for si in root.findall(NS + "si")
        ]

    sheet = next(n for n in archive.namelist() if n.startswith("xl/worksheets/sheet"))
    root = ET.fromstring(archive.read(sheet))

    def cell(node: ET.Element) -> str:
        value = node.find(NS + "v")
        if value is None or value.text is None:
            return ""
        return shared[int(value.text)] if node.get("t") == "s" else value.text

    rows: list[list[str]] = []
    for row in root.iter(NS + "row"):
        cells: list[str] = []
        for node in row.findall(NS + "c"):
            column = column_index(node.get("r", ""))
            if column < 0:
                column = len(cells)
            cells.extend([""] * (column + 1 - len(cells)))
            cells[column] = cell(node)
        rows.append(cells)
    return rows


def fetch_table(url: str) -> list[tuple[int, list[float]]]:
    # curl rather than urllib: python.org builds ship without a CA bundle on macOS.
    download = subprocess.run(
        ["curl", "-sSLf", "--max-time", "120", url],
        capture_output=True,
        check=True,
    )
    rows = sheet_rows(download.stdout)

    header = rows[0]
    index = {name: i for i, name in enumerate(header)}
    age_column = index.get("Month", index.get("Age"))
    if age_column is None:
        raise SystemExit(f"no age column in {url}: {header}")
    missing = [p for p in PERCENTILES if p not in index]
    if missing:
        raise SystemExit(f"missing {missing} in {url}")

    table: dict[int, list[float]] = {}
    for row in rows[1:]:
        if len(row) <= max(index.values()):
            continue
        try:
            month = int(row[age_column])
        except ValueError:
            continue
        if month > MAX_MONTH or month in table:
            continue
        values = [float(row[index[p]]) for p in PERCENTILES]
        for value in values:
            if abs(value - round(value, 1)) > 1e-6:
                raise SystemExit(f"{url} month {month}: {value} needs >1 decimal")
        if values != sorted(values):
            raise SystemExit(f"{url} month {month}: percentiles not ascending")
        table[month] = values

    expected = list(range(MAX_MONTH + 1))
    if sorted(table) != expected:
        raise SystemExit(f"{url}: months {sorted(table)} != 0...{MAX_MONTH}")
    return [(m, table[m]) for m in expected]


def swift_array(name: str, table: list[tuple[int, list[float]]]) -> str:
    lines = [f"    private static let {name}: [WHOPoint] = ["]
    for month, values in table:
        p3, p15, p50, p85, p97 = (f"{v:.1f}" for v in values)
        lines.append(
            f"        WHOPoint(month: {month:2d}, p3: {p3:>5}, p15: {p15:>5}, "
            f"p50: {p50:>5}, p85: {p85:>5}, p97: {p97:>5}),"
        )
    lines.append("    ]")
    return "\n".join(lines)


def main() -> None:
    tables = {key: fetch_table(url) for key, url in SOURCES.items()}

    arrays = "\n\n".join(
        swift_array(f"{sex}{metric.capitalize()}", tables[(metric, sex)])
        for metric in ("weight", "height", "head")
        for sex in ("boys", "girls")
    )

    OUTPUT.write_text(
        """import Foundation

// Generated by scripts/generate_who_tables.py from the WHO Child Growth Standards
// (weight-for-age, length-for-age, head-circumference-for-age; months 0-24).
// Do not edit by hand - re-run the script instead.

enum WHOGrowthStandards {

    static func weight(_ sex: BabySex) -> [WHOPoint] {
        sex == .boy ? boysWeight : girlsWeight
    }

    static func height(_ sex: BabySex) -> [WHOPoint] {
        sex == .boy ? boysHeight : girlsHeight
    }

    static func head(_ sex: BabySex) -> [WHOPoint] {
        sex == .boy ? boysHead : girlsHead
    }

"""
        + arrays
        + "\n}\n"
    )

    for (metric, sex), table in sorted(tables.items()):
        print(f"{metric:6} {sex:5} months 0-{MAX_MONTH}  m0={table[0][1]}  m24={table[-1][1]}")
    print(f"wrote {OUTPUT}")


if __name__ == "__main__":
    main()
