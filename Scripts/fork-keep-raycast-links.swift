import AppKit

let raycast = URL(fileURLWithPath: "/Applications/Raycast.app")
let group = DispatchGroup()
for scheme in ["raycast", "com.raycast"] {
    group.enter()
    NSWorkspace.shared.setDefaultApplication(at: raycast, toOpenURLsWithScheme: scheme) { error in
        print(scheme, error.map { "failed: \($0)" } ?? "-> Raycast")
        group.leave()
    }
}
group.notify(queue: .main) { exit(0) }
dispatchMain()
