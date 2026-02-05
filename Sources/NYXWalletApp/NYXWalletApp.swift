import SwiftUI
import NYXUI

#if os(iOS)
@main
struct NYXWalletApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
#else
@main
struct NYXWalletApp {
    static func main() {}
}
#endif
