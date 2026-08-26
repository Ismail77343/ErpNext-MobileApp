import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  private var privacyProtectionView: UIView?

  override func sceneWillResignActive(_ scene: UIScene) {
    super.sceneWillResignActive(scene)
    showPrivacyProtectionView()
  }

  override func sceneDidBecomeActive(_ scene: UIScene) {
    super.sceneDidBecomeActive(scene)
    hidePrivacyProtectionView()
  }

  private func showPrivacyProtectionView() {
    guard privacyProtectionView == nil, let window else { return }

    let view = UIView(frame: window.bounds)
    view.backgroundColor = UIColor.systemBackground
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let label = UILabel()
    label.text = "TPGNexus"
    label.font = .boldSystemFont(ofSize: 28)
    label.textColor = UIColor.label
    label.translatesAutoresizingMaskIntoConstraints = false

    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])

    window.addSubview(view)
    privacyProtectionView = view
  }

  private func hidePrivacyProtectionView() {
    privacyProtectionView?.removeFromSuperview()
    privacyProtectionView = nil
  }
}
