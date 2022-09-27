//
//  VideoPlayerView.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/6.
//

import Flutter
import UIKit
import SnapKit

class VideoPlayerViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var channel: FlutterMethodChannel
    init(messenger: FlutterBinaryMessenger, channel:FlutterMethodChannel) {
        self.messenger = messenger
        self.channel = channel
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
            binaryMessenger: messenger,
            channel: self.channel)
    }
}

class VideoPlayerView: NSObject, FlutterPlatformView, PlayerViewDelegate {
    
    
    private var _view: UIView
    private var _playerContainer: UIView;
    private var playerView: PlayerView!
    private var _channle:FlutterMethodChannel;
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel
    ) {
        _view = UIView()
        _playerContainer = UIView();
        _channle = channel;
        super.init()
        // iOS views can be created here
        createNativeView(view: _view, arguments: args);
        setEvents();
    }
    
    func setEvents() {
        self._channle.setMethodCallHandler { call, result in
            if(call.method == "toggleFullScreen") {
                if let args = call.arguments as? Dictionary<String, Any>,
                   let isFullScreen = args["isFullScreen"] as? Bool,
                   let shouldRotate = args["shouldRotate"] as? Bool{
                    self.playerView.toggleFullscreen(isFullScreen:isFullScreen,shouldRotate:shouldRotate)
                    result(nil)
                } else {
                    result(FlutterError.init(code: "errorSetParameter", message: "data or format error", details: nil))
                }
                
                result(nil)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(
            rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func createNativeView(view _view: UIView, arguments args: Any?){
        guard let args = args as? Dictionary<String, Any>,
              let autoPlay = args["autoPlay"] as? Bool,
              let enablePreventScreenCapture = args["enablePreventScreenCapture"] as? Bool,
              let enableMarquee = args["enableMarquee"] as? Bool,
              let defaultFullScreen = args["defaultFullScreen"] as? Bool,
              let items = args["playingItems"] as? [Dictionary<String, Any>]
        else {return}
        let protectionText = args["protectionText"] as? String
        let marqueeText = args["marqueeText"] as? String
        let position = args["position"] as? Double
        var playingItems = [PlayingItem]()
        for item in items {
            playingItems.append(PlayingItem(url: item["url"] as! String, title: item["title"] as? String))
        }
        let param = PlayerSetting(autoPlay: autoPlay, protectionText: protectionText, enablePreventScreenCapture: enablePreventScreenCapture, marqueeText: marqueeText, enableMarquee: enableMarquee, defaultFullScreen: defaultFullScreen, poisition: position, playingItems: playingItems)
        playerView = PlayerView(containerView: _view,setting: param)
        _view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(_view)
        }
        //        playerView.play(with: url)
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            self.playerView.toggleFullscreen(isFullScreen:true, shouldRotate: false)
        } else {
            self.playerView.toggleFullscreen(isFullScreen:false, shouldRotate: false)
        }
    }
    
    func onBack() {
        self._channle.invokeMethod("onBack", arguments: nil)
    }
    
}


