//
//  VideoPlayerView.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/6.
//

import Flutter
import UIKit
import SnapKit
import ToastViewSwift

class VideoPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return VideoPlayerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            registrar: registrar)
    }
}

class VideoPlayerView: NSObject, FlutterPlatformView, PlayerViewDelegate {
    
    
    private var _view: UIView
    private var _playerContainer: UIView;
    private var playerView: PlayerView?
    private var _channle:FlutterMethodChannel;
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        registrar registrar: FlutterPluginRegistrar
    ) {
        print("viewId: \(viewId)")
        _channle = FlutterMethodChannel(name: "oneplusdream/video_channel_\(viewId)", binaryMessenger: registrar.messenger())
        let instance = SwiftVideoPlayerOneplusdreamPlugin()
        registrar.addMethodCallDelegate(instance,channel:_channle)
        
        _view = UIView()
        _playerContainer = UIView();
        super.init()
        // iOS views can be created here
        createNativeView(view: _view, arguments: args);
        setEvents();
    }
    
    func setEvents() {
        self._channle.setMethodCallHandler { call, result in
            if(call.method == "toggleFullScreen") {
                if let args = call.arguments as? Dictionary<String, Any>,
                   let isFullScreen = args["isFullScreen"] as? Bool{
                    self.playerView?.toggleFullscreen(isFullScreen:isFullScreen)
                    result(nil)
                } else {
                    result(FlutterError.init(code: "errorSetParameter", message: "data or format error", details: nil))
                }
            } else if (call.method == "play") {
                if let args = call.arguments as? Dictionary<String, Any>,
                   let url = args["url"] as? String{
                    let item = PlayingItem(url:url, title: args["title"] as? String, position: args["position"] as? Double)
                    self.playerView?.play(with: item)
                    result(nil)
                } else {
                    result(FlutterError.init(code: "errorSetParameter", message: "data or format error", details: nil))
                }
            } else if (call.method == "togglePause") {
                let args = call.arguments as? Bool
                if(args ?? false) {
                    self.playerView?.player?.pause()
                }else {
                    self.playerView?.player?.play()
                }
                result(nil)
            } else if (call.method == "release") {
                self.playerView?.release()
                result(nil)
            } else if(call.method == "ready") {
                result(nil)
            } else {
                result(FlutterError.init(code: "noMethodFound", message: "no related method found" + call.method, details: nil))
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(
            rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForegroundNotification),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func createNativeView(view _view: UIView, arguments args: Any?){
        _view.backgroundColor = .black
        guard let args = args as? Dictionary<String, Any>,
              let autoPlay = args["autoPlay"] as? Bool,
              let enablePreventScreenCapture = args["enablePreventScreenCapture"] as? Bool,
              let enableMarquee = args["enableMarquee"] as? Bool,
              let items = args["playingItems"] as? [Dictionary<String, Any>]
        else {
            showToast(message: "Setting is not right, cannot initial player.")
            return}
        if(items.count == 0) {
            showToast(message: "Playing items must be greater than 0")
        }
        let protectionText = args["protectionText"] as? String
        let marqueeText = args["marqueeText"] as? String
        let lastPlayMessage = args["lastPlayMessage"] as? String
        let posterImage = args["posterImg"] as? String
        let hideBackButton = args["hideBackButton"] as? Bool
        var playingItems = [PlayingItem]()
        for item in items {
            playingItems.append(PlayingItem(url: item["url"] as! String, title: item["title"] as? String,position: item["position"] as? Double))
        }
        let param = PlayerSetting(autoPlay: autoPlay, protectionText: protectionText, enablePreventScreenCapture: enablePreventScreenCapture, marqueeText: marqueeText, enableMarquee: enableMarquee, playingItems: playingItems, lastPlayMessage: lastPlayMessage, posterImage: posterImage, hideBackButton: hideBackButton ?? false)
        playerView = PlayerView(containerView: _view,setting: param)
        _view.addSubview(playerView!)
        playerView?.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(_view)
        }
        playerView?.delegate = self;
    }
    
    @objc func rotated() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, windowScene.activationState == .foregroundActive, let _ = windowScene.windows.first else { return }
        if windowScene.interfaceOrientation.isLandscape {
            self.playerView?.toggleFullscreen(isFullScreen:true)
        } else if windowScene.interfaceOrientation.isPortrait {
            self.playerView?.toggleFullscreen(isFullScreen:false)
        }
    }
    
    @objc func appWillEnterForegroundNotification() {
        self.playerView?.activityIndicator.startAnimating()
        if(self.playerView?.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate){
            print("resume to play")
            self.playerView?.resume()
        }else {
            self.playerView?.player?.play()
        }
        
    }
    
    func onBack() {
        self._channle.invokeMethod("onBack", arguments: nil)
    }
    
    func onPlaying(event:PlayingEvent) {
        do {
            let jsonData = try event.jsonData()
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dictionary = json as? [String : Any] else {
                return
            }
            self._channle.invokeMethod("onPlaying", arguments: dictionary)
        } catch {
            print(error)
        }
    }
    
    func onRateChange(rate: Float) {
        self._channle.invokeMethod("onRateChange", arguments: rate)
    }
    
    func showToast(message:String, type:ToastType = ToastType.warning) {
        let appleToastView = AppleToastView(child: CustomTextToastView(message),minHeight: 32, darkBackgroundColor: type.toColor(), lightBackgroundColor:type.toColor())
        let toast = Toast.custom(view: appleToastView)
        toast.show()
    }
    
    deinit {
        print("deinit in flutter video player")
        NotificationCenter.default.removeObserver(self)
        self.playerView?.release()
    }
}


