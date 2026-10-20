import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  // Stripe return URLs (apa://) are handled in Dart via app_links +
  // Stripe.instance.handleURLCallback — no native Stripe import needed.

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    // flutter_stripe (and older StripeSdk lookups) still read
    // UIApplication.shared.delegate?.window, which is nil under UIScene.
    // Mirror the scene key window so Payment Sheet can present.
    syncKeyWindowToAppDelegate(from: scene)
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    syncKeyWindowToAppDelegate(from: scene)
  }

  private func syncKeyWindowToAppDelegate(from scene: UIScene) {
    guard let appDelegate = UIApplication.shared.delegate as? FlutterAppDelegate
    else {
      return
    }

    let fromScene = (scene as? UIWindowScene)?.windows.first { $0.isKeyWindow }
      ?? (scene as? UIWindowScene)?.windows.first
    let fromApp = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }

    appDelegate.window = fromApp ?? fromScene ?? appDelegate.window
  }
}
