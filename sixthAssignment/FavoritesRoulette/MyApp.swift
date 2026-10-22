import SwiftUI
import UIKit

@main
struct MyApp: App {

    var body: some Scene {
        WindowGroup {
            StoryboardRootView()
                .ignoresSafeArea()
        }
    }
}

struct StoryboardRootView: UIViewControllerRepresentable {

    func makeUIViewController(
        context: Context
    ) -> UIViewController {

        let storyboard = UIStoryboard(
            name: "Main",
            bundle: nil
        )

        guard let controller =
            storyboard.instantiateInitialViewController() else {
            return UIViewController()
        }

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: Context
    ) {
    }
}
