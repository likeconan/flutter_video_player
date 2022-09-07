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

class VideoPlayerView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var _playerContainer: UIView;
    private var playerView: PlayerView!
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel
    ) {
        _view = UIView()
        _playerContainer = UIView();
        super.init()
        // iOS views can be created here
        createNativeView(view: _view)
        channel.setMethodCallHandler { call, result in
            if(call.method == "toggleFullScreen") {
                self.playerView.toggleFullscreen(isFullScreen:true)
                result(nil)
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(
            rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    func view() -> UIView {
        return _view
    }
    
    func createNativeView(view _view: UIView){
        _view.backgroundColor = .red
        guard let url = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8") else { return }
        playerView = PlayerView(containerView: _view)
        _view.addSubview(playerView)
        playerView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(_view)
        }
        playerView.play(with: url)
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isLandscape {
            self.playerView.toggleFullscreen(isFullScreen:true, shouldRotate: false)
        } else {
            self.playerView.toggleFullscreen(isFullScreen:false, shouldRotate: false)
        }
    }
    
}


