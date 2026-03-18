import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var rootCoordinator: RootCoordinator?
    private let appContainer = AppContainer()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let coordinator = RootCoordinator(window: window, appContainer: appContainer)
        coordinator.start()

        self.window = window
        rootCoordinator = coordinator
        return true
    }
}
