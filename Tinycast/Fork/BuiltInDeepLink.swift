import Foundation

enum BuiltInDeepLink: Equatable, Sendable {
    enum NamedCatalog: Sendable {
        case quickAction
        case customCommand
        case quicklink
        case windowSize
    }

    case action(HotKeyAction)
    case named(NamedCatalog, String)

    static func parse(_ url: URL) -> BuiltInDeepLink? {
        switch url.scheme?.lowercased() {
        case "tinycast":
            return parseTinycast(segments(of: url))
        case "raycast", "com.raycast":
            return parseRaycast(segments(of: url))
        default:
            return nil
        }
    }

    static func url(for action: HotKeyAction) -> String? {
        let path: String
        switch action {
        case .command(let id):
            guard id.hotKeyAction != nil else { return nil }
            path = id.rawValue.replacingOccurrences(of: ":", with: "/")
        case .windowCommand(let id): path = "window-command/" + id.rawValue
        case .systemAction(let id): path = "system-action/" + id.rawValue
        case .quickAction(let id): path = "quick-action/" + id.uuidString.lowercased()
        case .customCommand(let id): path = "custom-command/" + id.uuidString.lowercased()
        case .quicklink(let id): path = "quicklink/" + id.uuidString.lowercased()
        case .customWindowSize(let id): path = "window-size/" + id.uuidString.lowercased()
        default:
            return nil
        }
        return "tinycast://" + path
    }

    static func extensionURL(author: String, extensionName: String, commandName: String) -> String {
        let owner = extensionName.contains("/") ? [] : [author]
        return "tinycast://" + (["extensions"] + owner + [extensionName, commandName]).joined(separator: "/")
    }

    static func slug(_ name: String) -> String {
        name.lowercased()
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .joined(separator: "-")
    }

    private static func segments(of url: URL) -> [String] {
        var segments: [String] = []
        if let host = url.host, !host.isEmpty { segments.append(host) }
        segments += url.pathComponents.filter { $0 != "/" }
        return segments.map { $0.removingPercentEncoding ?? $0 }
    }

    private static func parseTinycast(_ segments: [String]) -> BuiltInDeepLink? {
        guard segments.count == 2 else { return nil }
        let target = segments[1]
        switch segments[0].lowercased() {
        case "command":
            return CommandID(rawValue: "command:" + target)?.hotKeyAction.map { .action($0) }
        case "window-command":
            return WindowCommand.ID(rawValue: target).map { .action(.windowCommand(id: $0)) }
        case "system-action":
            return SystemAction.ID(rawValue: target).map { .action(.systemAction(id: $0)) }
        case "quick-action":
            return item(target, in: .quickAction) { .quickAction(id: $0) }
        case "custom-command":
            return item(target, in: .customCommand) { .customCommand(id: $0) }
        case "quicklink":
            return item(target, in: .quicklink) { .quicklink(id: $0) }
        case "window-size":
            return item(target, in: .windowSize) { .customWindowSize(id: $0) }
        default:
            return nil
        }
    }

    private static func item(
        _ target: String, in catalog: NamedCatalog, action: (UUID) -> HotKeyAction
    ) -> BuiltInDeepLink {
        UUID(uuidString: target).map { .action(action($0)) } ?? .named(catalog, slug(target))
    }

    private static let raycastCommands: [String: CommandID] = [
        "clipboard-history/clipboard-history": .clipboardHistory,
        "emoji-symbols/search-emoji-symbols": .searchEmoji,
        "raycast/open-camera": .openCamera,
        "navigation/search-menu-items": .searchMenuItems,
        "raycast-notes/raycast-notes": .showNotes,
        "calendar/my-schedule": .mySchedule,
    ]

    private static let raycastAICommands: [String: CommandID] = [
        "improve-writing": .rewrite,
        "fix-spelling-and-grammar": .fixGrammar,
        "summarize": .summarize,
        "ai-chat": .aiChat,
    ]

    private static func parseRaycast(_ segments: [String]) -> BuiltInDeepLink? {
        if segments.count == 2, segments[0] == "ai-commands" { return aiCommand(segments[1]) }
        guard segments.count == 4, segments[0] == "extensions", segments[1] == "raycast" else {
            return nil
        }
        let (extensionName, command) = (segments[2], segments[3])
        switch extensionName {
        case "window-management":
            return WindowCommand.ID(rawValue: command).map { .action(.windowCommand(id: $0)) }
        case "system":
            return SystemAction.ID(rawValue: command).map { .action(.systemAction(id: $0)) }
        case "ai":
            return aiCommand(command)
        default:
            return raycastCommands[extensionName + "/" + command]?.hotKeyAction.map { .action($0) }
        }
    }

    private static func aiCommand(_ name: String) -> BuiltInDeepLink? {
        guard let command = raycastAICommands[name] else { return .named(.quickAction, slug(name)) }
        return command.hotKeyAction.map { .action($0) }
    }
}
