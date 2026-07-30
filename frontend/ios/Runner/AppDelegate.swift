import Flutter
import QuickLook
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var originalFilePreviewChannel: FlutterMethodChannel?
  private var originalFilePreviewCoordinator: OriginalFilePreviewCoordinator?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "med_story/original_file_preview",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "preview" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let self else {
        result(["type": -4, "message": "The preview handler is unavailable."])
        return
      }
      self.presentOriginalFile(call: call, result: result)
    }
    originalFilePreviewChannel = channel
  }

  private func presentOriginalFile(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let path = arguments["path"] as? String,
      !path.isEmpty
    else {
      result(["type": -4, "message": "A file path is required."])
      return
    }

    guard FileManager.default.fileExists(atPath: path) else {
      result(["type": -2, "message": "The file does not exist."])
      return
    }

    DispatchQueue.main.async { [weak self] in
      guard let self else {
        result(["type": -4, "message": "The preview presenter is unavailable."])
        return
      }
      guard self.originalFilePreviewCoordinator == nil else {
        result(["type": -4, "message": "Another preview is already open."])
        return
      }
      guard let presenter = self.activeViewController() else {
        result(["type": -4, "message": "The preview presenter is unavailable."])
        return
      }

      let previewController = QLPreviewController()
      let coordinator = OriginalFilePreviewCoordinator(
        url: URL(fileURLWithPath: path),
        onDismiss: { [weak self] in
          self?.originalFilePreviewCoordinator = nil
        }
      )
      previewController.dataSource = coordinator
      previewController.delegate = coordinator
      self.originalFilePreviewCoordinator = coordinator
      presenter.present(previewController, animated: true) {
        result(["type": 0, "message": "done"])
      }
    }
  }

  private func activeViewController() -> UIViewController? {
    let activeScenes = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .filter { $0.activationState == .foregroundActive }
    let window = activeScenes
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)
      ?? activeScenes.flatMap(\.windows).first
    return topViewController(from: window?.rootViewController)
  }

  private func topViewController(from controller: UIViewController?) -> UIViewController? {
    if let presented = controller?.presentedViewController {
      return topViewController(from: presented)
    }
    if let navigationController = controller as? UINavigationController {
      return topViewController(from: navigationController.visibleViewController)
    }
    if let tabBarController = controller as? UITabBarController {
      return topViewController(from: tabBarController.selectedViewController)
    }
    return controller
  }
}

private final class OriginalFilePreviewCoordinator: NSObject,
  QLPreviewControllerDataSource,
  QLPreviewControllerDelegate
{
  private let url: URL
  private let onDismiss: () -> Void

  init(url: URL, onDismiss: @escaping () -> Void) {
    self.url = url
    self.onDismiss = onDismiss
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return 1
  }

  func previewController(
    _ controller: QLPreviewController,
    previewItemAt index: Int
  ) -> QLPreviewItem {
    return url as NSURL
  }

  func previewControllerDidDismiss(_ controller: QLPreviewController) {
    onDismiss()
  }
}
