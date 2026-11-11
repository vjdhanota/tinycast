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

        check(
            "an app to bring forward by bundle id",
            parse("tinycast://focus-app/com.mitchellh.ghostty") == .focusApp(bundleID: "com.mitchellh.ghostty"))
        check("an app link without a bundle id", parse("tinycast://focus-app") == nil)

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
            "Raycast Improve Writing",
            parse("raycast://ai-commands/improve-writing") == .action(.command(.rewrite)))
        check(
            "Raycast Fix Spelling and Grammar",
            parse("raycast://ai-commands/fix-spelling-and-grammar") == .action(.command(.fixGrammar)))
        check(
            "Raycast Summarize",
            parse("raycast://ai-commands/summarize") == .action(.command(.summarize)))
        check(
            "another Raycast AI command resolves to a Quick Action of the same name",
            parse("raycast://ai-commands/explain-code-step-by-step")
                == .named(.quickAction, "explain-code-step-by-step"))
        check(
            "the Raycast AI extension's Improve Writing",
            parse("raycast://extensions/raycast/ai/improve-writing") == .action(.command(.rewrite)))
        check(
            "Raycast AI Chat",
            parse("raycast://extensions/raycast/ai/ai-chat") == .action(.command(.aiChat)))
        check("a bare ai-commands link", parse("raycast://ai-commands") == nil)
        check("Raycast confetti", parse("raycast://confetti") == nil)

        let roundTrips: [HotKeyAction] = [
            .command(.clipboardHistory), .command(.fixGrammar), .windowCommand(id: .topLeftQuarter),
            .systemAction(id: .sleep), .quickAction(id: id), .customCommand(id: id), .quicklink(id: id),
            .customWindowSize(id: id),
        ]
        for action in roundTrips {
            let url = BuiltInDeepLink.url(for: action)
            check(
                "\(action) round-trips through its deeplink",
                url.flatMap { URL(string: $0) }.flatMap(BuiltInDeepLink.parse) == .action(action))
        }
        check(
            "a command's deeplink uses its catalog id",
            BuiltInDeepLink.url(for: .command(.clipboardHistory)) == "tinycast://command/clipboard-history")
        check(
            "a custom item's deeplink uses its lowercased id",
            BuiltInDeepLink.url(for: .quickAction(id: id))
                == "tinycast://quick-action/\(id.uuidString.lowercased())")
        check("an app has no deeplink", BuiltInDeepLink.url(for: .app(bundleID: "com.apple.Notes")) == nil)
        check("the palette toggle has no deeplink", BuiltInDeepLink.url(for: .togglePalette) == nil)

        let extensionURL = BuiltInDeepLink.extensionURL(
            author: "raycast", extensionName: "github", commandName: "my-issues")
        check("an extension command's deeplink", extensionURL == "tinycast://extensions/raycast/github/my-issues")
        check(
            "a scoped extension name keeps its owner",
            BuiltInDeepLink.extensionURL(author: "someone", extensionName: "team/tool", commandName: "run")
                == "tinycast://extensions/team/tool/run")

        check("a slug lowercases and hyphenates", BuiltInDeepLink.slug("Explain  Code!") == "explain-code")
        check("a slug trims separators", BuiltInDeepLink.slug(" -Fix/Grammar- ") == "fix-grammar")

        if failures > 0 { exit(1) }
        print("all passed")
    }
}
