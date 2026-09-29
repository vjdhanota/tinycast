#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

BIN="${TMPDIR:-/tmp}/tinycast-harness"
mkdir -p "$BIN"

swiftc -swift-version 6 -Onone \
    Tinycast/Fork/BuiltInDeepLink.swift \
    Tinycast/Features/HotKeys/Model/HotKeyAction.swift \
    Tinycast/Features/QuickActions/Model/QuickAction.swift \
    Tinycast/Features/QuickActions/Model/BuiltInQuickAction.swift \
    Tinycast/Features/QuickActions/Model/CustomQuickAction.swift \
    Tinycast/Features/Launcher/Model/CommandID.swift \
    Tinycast/Features/Quicklinks/Model/Quicklink.swift \
    Tinycast/Features/Quicklinks/Model/QuicklinkDestination.swift \
    Tinycast/Features/SystemActions/Model/SystemAction.swift \
    Tinycast/Features/WindowManagement/Model/WindowCommand.swift \
    Tinycast/Features/Extensions/Model/ExtensionDeepLink.swift \
    Tinycast/Features/Extensions/Model/ExtensionLaunchType.swift \
    Tests/fork-deeplink-test.swift \
    -o "$BIN/fork-deeplink-test"
"$BIN/fork-deeplink-test"
