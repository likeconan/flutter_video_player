//
//  PlayerView.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/7.
//

import Foundation
import AVKit
import MediaPlayer

class PlayerView: UIView, AVPictureInPictureControllerDelegate {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    weak var delegate: PlayerViewDelegate?
    
    required init(containerView: UIView) {
        self.containerView = containerView
        super.init(frame: .zero)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            currentVolume = audioSession.outputVolume
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true, options: [])
            
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        currentBrightness = UIScreen.main.brightness
        setupUI();
        setupPictureInPicture();
        bindActions();
        bindGestures();
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerItemContext = 0
    var isFullScreen = false;
    var playerItem: AVPlayerItem?
    var containerView:UIView;
    var pipController: AVPictureInPictureController!
    var pipPossibleObservation: NSKeyValueObservation?
    
    // gestures param
    var startLocation = CGPoint()
    var currentVolume = Float(0.0)
    var currentBrightness = CGFloat(0)
    var gestureSwipeEvent = GestureEvent.none
    
    
    lazy var viewController:UIViewController = {
        let _viewController = UIViewController();
        _viewController.modalPresentationStyle = .fullScreen
        return _viewController;
    }()
    
    lazy var backIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Back", for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var pipIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Pip", for: .normal)
        button.sizeToFit()
        return button
    }()
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    func setupUI() {
        self.addSubview(backIcon);
        self.addSubview(pipIcon)
        
        backIcon.snp.makeConstraints { make in
            make.top.equalTo(self).offset(12)
            make.left.equalTo(self).offset(12)
        }
        pipIcon.snp.makeConstraints { make in
            make.bottom.equalTo(self).offset(-12)
            make.right.equalTo(self).offset(-12)
        }
    }
    
    func bindActions() {
        backIcon.addTarget(self, action: #selector(backIconClicked), for: .touchUpInside)
        pipIcon.addTarget(self, action: #selector(pipIconClicked), for: .touchUpInside)
    }
    
    func setupPictureInPicture() {
        // Ensure PiP is supported by current device.
        if AVPictureInPictureController.isPictureInPictureSupported() {
            // Create a new controller, passing the reference to the AVPlayerLayer.
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController.delegate = self
            pipPossibleObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                            options: [.initial, .new]) { [weak self] _, change in
                // Update the PiP button's enabled state.
//                self?.pipButton.isEnabled = change.newValue ?? false
                self?.pipIcon.isHidden = !(change.newValue ?? false)
            }
        } else {
            // PiP isn't supported by the current device. Disable the PiP button.
            self.pipIcon.isHidden = true
        }
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        print("deinit of PlayerView")
    }
    
}


enum GestureEvent {
    case volume
    case brightness
    case seek
    case none
    
    func description () -> String {
        switch self {
        case .volume:
            return "volume"
        case .brightness:
            return "brightness"
        case .seek:
            return "seek"
        case .none:
            return "none"
        }
    }
}
