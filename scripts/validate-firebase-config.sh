#!/bin/bash
#
# Fails the build when GoogleService-Info.plist is missing (or is still the
# unfilled template) in the built app bundle.
#
# GoogleService-Info.plist is gitignored and picked up implicitly through the
# synchronized file-system group, so a fresh clone or a CI machine builds and
# archives perfectly happily without it. FirebaseBootstrapper then soft-fails at
# launch and the whole cloud-sync half of the app is dead with no crash and no
# visible error. This phase turns that into a build failure for Release/archive
# builds, and a warning for local Debug builds (working without Firebase is a
# supported local-first setup).

set -u

CONFIG_NAME="GoogleService-Info.plist"
SOURCE_PLIST="${SRCROOT:-$PWD}/Momsy/${CONFIG_NAME}"
BUNDLED_PLIST="${BUILT_PRODUCTS_DIR:-}/${UNLOCALIZED_RESOURCES_FOLDER_PATH:-}/${CONFIG_NAME}"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

# Release builds and anything being archived/installed must ship a real config.
severity="warning"
if [ "${CONFIGURATION:-Debug}" != "Debug" ] || [ "${ACTION:-build}" = "install" ]; then
    severity="error"
fi

fail_count=0

report() {
    echo "${severity}: ${1}"
    if [ "${severity}" = "error" ]; then
        fail_count=$((fail_count + 1))
    fi
}

plist_value() {
    "${PLIST_BUDDY}" -c "Print :${1}" "${2}" 2>/dev/null
}

if [ ! -f "${BUNDLED_PLIST}" ]; then
    if [ -f "${SOURCE_PLIST}" ]; then
        report "${CONFIG_NAME} exists at ${SOURCE_PLIST} but was not copied into the app bundle — check that it is a member of the Momsy target."
    else
        report "${CONFIG_NAME} is missing. Firebase will not configure, so cloud sync, family sharing and push will be silently dead in this build. Copy Momsy/${CONFIG_NAME}.template to Momsy/${CONFIG_NAME} and fill it in with the real Firebase values (the file is gitignored; on CI provide it from secrets)."
    fi
    exit $((fail_count > 0 ? 1 : 0))
fi

if ! plutil -lint "${BUNDLED_PLIST}" >/dev/null 2>&1; then
    report "${CONFIG_NAME} in the app bundle is not a valid property list."
    exit $((fail_count > 0 ? 1 : 0))
fi

for key in API_KEY GOOGLE_APP_ID PROJECT_ID GCM_SENDER_ID BUNDLE_ID; do
    value="$(plist_value "${key}" "${BUNDLED_PLIST}")"
    if [ -z "${value}" ]; then
        report "${CONFIG_NAME} is missing a value for ${key}."
    elif [[ "${value}" == *YOUR_* || "${value}" == *yourcompany* ]]; then
        report "${CONFIG_NAME} still contains the template placeholder for ${key} (\"${value}\"). Fill it in with the real Firebase values."
    fi
done

bundle_id="$(plist_value BUNDLE_ID "${BUNDLED_PLIST}")"
expected_bundle_id="${PRODUCT_BUNDLE_IDENTIFIER:-}"
if [ -n "${bundle_id}" ] && [ -n "${expected_bundle_id}" ] && [ "${bundle_id}" != "${expected_bundle_id}" ]; then
    echo "warning: ${CONFIG_NAME} BUNDLE_ID (${bundle_id}) does not match the target bundle identifier (${expected_bundle_id})."
fi

exit $((fail_count > 0 ? 1 : 0))
