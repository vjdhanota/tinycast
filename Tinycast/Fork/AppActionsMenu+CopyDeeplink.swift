import SwiftUI

extension AppActionsMenu {
    static func copyDeeplinkItems(app: AppEntry, core: AppCore) -> [PopoverMenuItem] {
        guard let url = deeplink(for: app, core: core) else { return [] }
        return [
            PopoverMenuItem(title: "Copy Deeplink", systemImage: "link", startsSection: true) {
                Paster.copyPlainText(url)
                core.showMessage("Copied deeplink")
            }
        ]
    }

    private static func deeplink(for app: AppEntry, core: AppCore) -> String? {
        guard app.kind == .extensionCommand else {
            return app.hotKeyAction.flatMap(BuiltInDeepLink.url(for:))
        }
        return core.extensions.resolve(app).map { owner, command in
            BuiltInDeepLink.extensionURL(
                author: owner.manifest.author, extensionName: owner.manifest.name,
                commandName: command.name)
        }
    }
}
