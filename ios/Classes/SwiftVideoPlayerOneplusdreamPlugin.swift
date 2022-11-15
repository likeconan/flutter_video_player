import Flutter
import UIKit

public class SwiftVideoPlayerOneplusdreamPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // channel
        let channel = FlutterMethodChannel(name: "video_player_oneplusdream", binaryMessenger: registrar.messenger())
        let instance = SwiftVideoPlayerOneplusdreamPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // view
        let factory = VideoPlayerViewFactory(registrar: registrar)
        registrar.register(factory, withId: "oneplusdream/video_player_ios")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
