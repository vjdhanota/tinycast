import Foundation

@main
struct ForkDeepLinkTest {
    static func main() {
        var failures = 0

        func check(_ description: String, _ condition: @autoclosure () -> Bool) {
            if condition() {
                print("PASS  \(description)")
            } else {
                print("FAIL  \(description)")
                failures += 1
            }
        }

        func parse(_ string: String) -> BuiltInDeepLink? {
            BuiltInDeepLink.parse(URL(string: string)!)
        }

        check(
            "a built-in command by its catalog id",
            parse("tinycast://command/clipboard-history") == .action(.command(.clipboardHistory)))
        check(
            "a Quick Action command",
            parse("tinycast://command/fix-grammar") == .action(.command(.fixGrammar)))
        check("an unknown command", parse("tinycast://command/nope") == nil)
        check("a command that cannot be bound", parse("tinycast://command/quit") == nil)

        check(
            "a window command",
            parse("tinycast://window-command/left-half") == .action(.windowCommand(id: .leftHalf)))
        check("an unknown window command", parse("tinycast://window-command/nope") == nil)
        check(
            "a system action",
            parse("tinycast://system-action/sleep") == .action(.systemAction(id: .sleep)))

        let id = UUID(uuidString: "97A1DDFA-76F3-4872-A672-25D5F35B7882")!
        check(
            "a custom Quick Action by id",
            parse("tinycast://quick-action/\(id.uuidString)") == .action(.quickAction(id: id)))
        check(
            "a custom command by id, lowercased",
            parse("tinycast://custom-command/\(id.uuidString.lowercased())")
                == .action(.customCommand(id: id)))
        check(
            "a quicklink by id",
            parse("tinycast://quicklink/\(id.uuidString)") == .action(.quicklink(id: id)))
        check(
            "a custom window size by id",
            parse("tinycast://window-size/\(id.uuidString)") == .action(.customWindowSize(id: id)))
        check(
            "a custom window size by name",
            parse("tinycast://window-size/top-center-two-thirds")
                == .named(.windowSize, "top-center-two-thirds"))
        check(
            "a custom Quick Action by name",
            parse("tinycast://quick-action/Explain%20Code") == .named(.quickAction, "explain-code"))
        check(
            "a custom command by slug",
            parse("tinycast://custom-command/open-logs") == .named(.customCommand, "open-logs"))

        check(
            "extension links stay with the extension runner",
            parse("tinycast://extensions/raycast/github/my-issues") == nil)
        check("a bare scheme", parse("tinycast://") == nil)
        check("another app's scheme", parse("slack://command/clipboard-history") == nil)

        check(
            "Raycast window management",
            parse("raycast://extensions/raycast/window-management/top-left-quarter")
                == .action(.windowCommand(id: .topLeftQuarter)))
        check(
            "Raycast maximize",
            parse("raycast://extensions/raycast/window-management/maximize")
                == .action(.windowCommand(id: .maximize)))
        check(
            "a Raycast window command Tinycast lacks",
            parse("raycast://extensions/raycast/window-management/top-center-two-thirds") == nil)
        check(
            "Raycast clipboard history",
            parse("raycast://extensions/raycast/clipboard-history/clipboard-history")
                == .action(.command(.clipboardHistory)))
        check(
            "Raycast emoji search",
            parse("raycast://extensions/raycast/emoji-symbols/search-emoji-symbols")
                == .action(.command(.searchEmoji)))
        check(
            "Raycast camera",
            parse("raycast://extensions/raycast/raycast/open-camera") == .action(.command(.openCamera)))
        check(
            "Raycast menu search",
            parse("raycast://extensions/raycast/navigation/search-menu-items")
                == .action(.command(.searchMenuItems)))
        check(
            "Raycast notes",
            parse("raycast://extensions/raycast/raycast-notes/raycast-notes")
                == .action(.command(.showNotes)))
        check(
            "Raycast schedule",
            parse("raycast://extensions/raycast/calendar/my-schedule") == .action(.command(.mySchedule)))
        check(
            "Raycast system sleep",
            parse("raycast://extensions/raycast/system/sleep") == .action(.systemAction(id: .sleep)))
        check(
            "the com.raycast spelling",
            parse("com.raycast:/extensions/raycast/window-management/left-half")
                == .action(.windowCommand(id: .leftHalf)))
        check(
            "Raycast store extensions stay with the extension runner",
            parse("raycast://extensions/raycast/github/my-pull-requests") == nil)
        check(
            "Raycast AI commands are left alone",
            parse("raycast://ai-commands/improve-writing") == nil)
        check("Raycast confetti", parse("raycast://confetti") == nil)

        check("a slug lowercases and hyphenates", BuiltInDeepLink.slug("Explain  Code!") == "explain-code")
        check("a slug trims separators", BuiltInDeepLink.slug(" -Fix/Grammar- ") == "fix-grammar")

        if failures > 0 { exit(1) }
        print("all passed")
    }
}
