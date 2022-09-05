import Flutter
import UIKit

public class SwiftVideoPlayerOneplusdreamPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "video_player_oneplusdream", binaryMessenger: registrar.messenger())
    let instance = SwiftVideoPlayerOneplusdreamPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
      let factory = VideoPlayerViewFactory(messenger: registrar.messenger())
              registrar.register(factory, withId: "video_player")
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
