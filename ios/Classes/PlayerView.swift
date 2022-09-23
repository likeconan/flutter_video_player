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
        setupPictureInPicture();
        setupUI();
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
    var duration:Float64 = 0;
    // gestures param
    var startLocation = CGPoint()
    var currentVolume = Float(0.0)
    var currentBrightness = CGFloat(0)
    var currentSliderTime = CGFloat(0)
    var gestureSwipeEvent = GestureEvent.none
    var baseOffset = CGFloat(12)
    
    
    lazy var viewController:UIViewController = {
        let _viewController = UIViewController();
        _viewController.modalPresentationStyle = .fullScreen
        return _viewController;
    }()
    
    lazy var backIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(MediaResource.shared.getImage(name: "arrow_back"), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var rateIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(MediaResource.shared.getImage(name: "play_speed"), for: .normal)
        button.isHidden = true
        button.sizeToFit()
        return button
    }()
    
    lazy var fullscreenIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(MediaResource.shared.getImage(name: "fullscreen"), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var pipIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(MediaResource.shared.getImage(name: "picture_in_picture"), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var playIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(MediaResource.shared.getImage(name: "play"), for: .normal)
        button.sizeToFit()
        return button
    }()
    
    lazy var videoSlider: VideoSlider = {
        let slider = VideoSlider()
        //        slider.backgroundColor = .red
        slider.maximumTrackTintColor = .lightGray
        slider.minimumTrackTintColor = .white
        slider.thumbTintColor = .white
        slider.minimumValue = 0
        slider.maximumValue = 0
        slider.value = 0
        slider.setThumbImage(MediaResource.shared.getImage(name: "slider_thumb"), for: .normal)
        slider.setThumbImage(MediaResource.shared.getImage(name: "slider_thumb"), for: .highlighted)
        return slider
    }()
    
    lazy var currentTimeLabel: UILabel = {
        let l = UILabel();
        l.text = "00:00";
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 12)
        l.textAlignment = NSTextAlignment.left
        return l;
    }()
    
    lazy var durationTimeLabel: UILabel = {
        let l = UILabel();
        l.text = "00:00";
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 12)
        l.textAlignment = NSTextAlignment.left
        return l;
    }()
    
    lazy var timerDraggingView: UIView = {
        let v = UIView()
        v.isHidden = true
        v.layer.cornerRadius = 10
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return v
    }()
    
    lazy var timerDraggingLabel: UILabel = {
        let l = UILabel();
        l.text = "00:00 / 00:00";
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 14)
        l.textAlignment = NSTextAlignment.left
        return l;
    }()
    
    lazy var videoControllContainer:UIView = {
        let view = UIView()
        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 0.4).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 0.4).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at:0)
        //        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
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
        self.addSubview(timerDraggingView)
        self.addSubview(videoControllContainer)
        videoControllContainer.addSubview(backIcon)
        videoControllContainer.addSubview(playIcon)
        videoControllContainer.addSubview(pipIcon)
        videoControllContainer.addSubview(fullscreenIcon)
        videoControllContainer.addSubview(rateIcon)
        videoControllContainer.addSubview(videoSlider)
        videoControllContainer.addSubview(currentTimeLabel)
        videoControllContainer.addSubview(durationTimeLabel)
        timerDraggingView.addSubview(timerDraggingLabel)
        
        videoControllContainer.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        backIcon.snp.makeConstraints { make in
            make.top.equalTo(self).offset(baseOffset)
            make.left.equalTo(self).offset(baseOffset)
        }
        
        playIcon.snp.makeConstraints { make in
            make.bottom.equalTo(videoControllContainer).offset(baseOffset * -0.5)
            make.left.equalTo(videoControllContainer).offset(baseOffset)
        }
        
        fullscreenIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo(videoControllContainer).offset(baseOffset * -1)
        }
        
        pipIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo(fullscreenIcon.snp.left).offset(baseOffset * -1)
        }
        rateIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo((pipIcon.isHidden ? fullscreenIcon.snp.left : pipIcon.snp.left)).offset(baseOffset * -1)
        }
        
        currentTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.width.equalTo(36)
            make.left.equalTo(playIcon.snp.right).offset(baseOffset)
        }
        
        videoSlider.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.height.equalTo(baseOffset)
            make.left.equalTo(currentTimeLabel.snp.right).offset(baseOffset/2)
            make.right.equalTo(durationTimeLabel.snp.left).offset(baseOffset / -2)
        }
        
        durationTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo((pipIcon.isHidden ? fullscreenIcon.snp.left : pipIcon.snp.left)).offset(baseOffset * -1)
        }
        
        timerDraggingView.snp.makeConstraints { make in
            make.center.equalTo(self).offset(-16)
            make.height.equalTo(48)
            make.width.equalTo(120)
        }
        
        timerDraggingLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bindActions() {
        backIcon.addTarget(self, action: #selector(backIconClicked), for: .touchUpInside)
        playIcon.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        pipIcon.addTarget(self, action: #selector(pipIconClicked), for: .touchUpInside)
        videoSlider.addTarget(self, action: #selector(onVideoSliderValChanged(slider:event:)), for: .valueChanged)
        fullscreenIcon.addTarget(self, action: #selector(fullscreenIconClicked), for: .touchUpInside)
    }
    
    func setupPictureInPicture() {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: playerLayer)
            pipController.delegate = self
            pipPossibleObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                            options: [.initial, .new]) { [weak self] _, change in
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
