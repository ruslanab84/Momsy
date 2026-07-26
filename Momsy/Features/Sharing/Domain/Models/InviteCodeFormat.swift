import Foundation

/// Единственный источник правды для формата семейного инвайт-кода.
///
/// `MOMSY-XXXX-XXXX-XXXX` — 12 символов из 32-символьного алфавита без
/// визуально неоднозначных знаков (нет I/O/0/1), то есть 32¹² ≈ 2⁶⁰ вариантов.
/// Прежний шестисимвольный код давал 2³⁰ и перебирался за минуты, что означало
/// полный админ-доступ к чужой семье (роль по умолчанию при join — родитель).
///
/// `pattern` дублируется в `firestore.rules` (`isStrongInviteCode`). Обе стороны
/// закреплены тестами: `InviteCodeFormatTests.patternIsShared` и
/// `tests/firebase-rules.test.mjs`.
enum InviteCodeFormat {
    static let prefix = "MOMSY"
    static let separator = "-"
    static let groupCount = 3
    static let groupLength = 4

    /// Без I, O, 0, 1 — код диктуется голосом и вводится вручную.
    static let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")

    /// `MOMSY` + три группы по 4 символа с разделителями.
    static let length = prefix.count + groupCount * (separator.count + groupLength)

    static let pattern = "^MOMSY(-[A-HJ-NP-Z2-9]{4}){3}$"

    /// Плейсхолдер поля ввода. Формат, а не текст — локализации не требует.
    static let placeholder = "MOMSY-XXXX-XXXX-XXXX"

    /// `Int.random(in:)` использует `SystemRandomNumberGenerator`, который на
    /// платформах Apple опирается на криптографический системный источник.
    static func generate() -> String {
        let groups = (0..<groupCount).map { _ in
            String((0..<groupLength).map { _ in alphabet[Int.random(in: alphabet.indices)] })
        }
        return ([prefix] + groups).joined(separator: separator)
    }

    /// Явная проверка длины идёт вместе с regex: якорь `$` в ICU допускает
    /// завершающий перевод строки, а идентификатор документа Firestore — нет.
    static func isValid(_ code: String) -> Bool {
        code.count == length
            && code.range(of: pattern, options: .regularExpression) != nil
    }
}
