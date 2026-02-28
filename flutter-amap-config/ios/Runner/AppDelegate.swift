import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    AMapServices.shared().enableHTTPS = true
    AMapServices.shared().apiKey = "e17f8ae117d84e2d2d394a2124866603"
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
