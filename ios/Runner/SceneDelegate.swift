import Flutter
import Stripe
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    var handledByStripe = false
    for context in URLContexts {
      if StripeAPI.handleURLCallback(with: context.url) {
        handledByStripe = true
      }
    }

    if !handledByStripe {
      super.scene(scene, openURLContexts: URLContexts)
    }
  }
}
