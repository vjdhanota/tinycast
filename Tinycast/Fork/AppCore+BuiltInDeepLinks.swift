import Foundation

extension AppCore {
    func handleBuiltInDeepLink(_ url: URL) -> Bool {
        guard let link = BuiltInDeepLink.parse(url) else { return false }
        switch link {
        case .action(let action):
            hotKeys.perform(action)
        case .named(let catalog, let slug):
            guard let action = namedAction(slug, in: catalog) else {
                showMessage("Nothing named '\(slug)'", tone: .danger)
                return true
            }
            hotKeys.perform(action)
        }
        return true
    }

    private func namedAction(_ slug: String, in catalog: BuiltInDeepLink.NamedCatalog) -> HotKeyAction? {
        let matches = { (name: String) in BuiltInDeepLink.slug(name) == slug }
        switch catalog {
        case .quickAction:
            return customQuickActions.actions.first { matches($0.name) }.map { .quickAction(id: $0.id) }
        case .customCommand:
            return customCommands.commands.first { matches($0.name) }.map { .customCommand(id: $0.id) }
        case .quicklink:
            return quicklinks.quicklinks.first { matches($0.name) }.map { .quicklink(id: $0.id) }
        }
    }
}
