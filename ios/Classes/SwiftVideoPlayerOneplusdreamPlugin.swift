import Flutter
import UIKit

public class SwiftVideoPlayerOneplusdreamPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        // view
        let factory = VideoPlayerViewFactory(registrar: registrar)
        registrar.register(factory, withId: "oneplusdream/video_player_ios")
        let channel = FlutterMethodChannel(name: "oneplusdream/global_channel", binaryMessenger: registrar.messenger())
        let instance = SwiftVideoPlayerOneplusdreamPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "cache":
            if let args = call.arguments as? Dictionary<String, Any>,
               let urlStrs = args["urls"] as? [String],
               let concurrent = args["concurrent"] as? Bool {
                DispatchQueue.global().async {
                    var urls:[URL] = []
                    for url in urlStrs {
                        guard let url = URL(string:url) else {return}
                        urls.append(url)
                    }
                    result(nil)
                    PreCacheHandler.shared.cache(urls: urls, concurrent: concurrent)
                }
            }else {
                result(FlutterError.init(code: "errorSetParameter", message: "should be array of string", details: nil))
            }
        case "cancelCache":
            if let urlStrs = call.arguments as? [String] {
                DispatchQueue.global().async {
                    var urls:[URL] = []
                    for url in urlStrs {
                        guard let url = URL(string:url) else {return}
                        urls.append(url)
                    }
                    PreCacheHandler.shared.cancelCache(urls: urls)
                    result(nil)
                }
            }else {
                result(FlutterError.init(code: "errorSetParameter", message: "should be array of string", details: nil))
            }
        case "clearAllCache":
            DispatchQueue.global().async {
                removeAllCache()
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
