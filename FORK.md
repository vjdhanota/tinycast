# vjdhanota/tinycast

Upstream Tinycast at its latest stable tag, plus deeplinks to built-in commands so launchers like
Leader Key can trigger them. Branch `fork` carries the patch; `main` mirrors upstream.

## Deeplinks

| URL | Runs |
| --- | --- |
| `tinycast://command/<id>` | A built-in command, e.g. `clipboard-history`, `search-emoji`, `open-camera`, `fix-grammar`, `rewrite`, `summarize`, `show-notes`, `my-schedule` (ids in `CommandID.swift`, without the `command:` prefix) |
| `tinycast://window-command/<id>` | A window command, e.g. `left-half`, `top-left-quarter`, `maximize` (`WindowCommand.swift`) |
| `tinycast://system-action/<id>` | A system action, e.g. `sleep` (`SystemAction.swift`) |
| `tinycast://quick-action/<name-or-uuid>` | A custom Quick Action, e.g. `quick-action/explain-code` |
| `tinycast://custom-command/<name-or-uuid>` | A custom command |
| `tinycast://quicklink/<name-or-uuid>` | A quicklink |

Names match case-insensitively with punctuation and spaces as hyphens. Each link runs exactly what the
action's global shortcut runs, so the feature must be switched on in Settings.

When Tinycast owns `raycast://`, Raycast's built-in links for window management, system actions,
clipboard history, emoji, camera, menu search, notes and schedule run their Tinycast equivalents.
`raycast://ai-commands/*` and Raycast store extensions are left to upstream's handling.

## Staying current

```sh
./Scripts/fork-sync.sh            # merge the newest upstream stable tag, test, build, install
./Scripts/fork-sync.sh --rebuild  # rebuild and reinstall even when already current
```

Needs Xcode 26, `brew install xcodegen`, and the `Tinycast Self-Signed` identity (docs/signing.md §1).
Conflicts stop the script; resolve, commit, rerun with `--rebuild`. `git rerere` remembers the
resolution for next time. While Raycast is installed the script hands `raycast://` back to it.

The patch touches upstream in three lines: `handleOpenURL` calls `handleBuiltInDeepLink` first,
`HotKeyManager.perform` is not private, and `ReleaseFeed.repository` names this fork so the in-app
updater never offers upstream builds this signature cannot replace. Everything else lives in
`Tinycast/Fork/`, `Scripts/fork-*` and `Tests/fork-*`. `Tinycast.xcodeproj` is regenerated at build
time and never committed here.
