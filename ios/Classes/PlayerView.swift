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
    
    required init(containerView: UIView, setting:PlayerSetting) {
        self.containerView = containerView
        self.setting = setting
        self.currentPlayingItem = setting.playingItems[setting.initialPlayIndex];
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
        toggleNetwork();
        backIcon.addTarget(self, action: #selector(backIconClicked), for: .touchDown)
        if(setting.playingItems.count == 0) {
            self.errorMessage.text = "No available playing items";
            return;
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        if(setting.enablePreventScreenCapture) {
            NotificationCenter.default.addObserver(self, selector: #selector(self.captureChanged), name: UIScreen.capturedDidChangeNotification, object: nil)
        }
        self.play(with: currentPlayingItem )
        if(!setting.autoPlay && setting.posterImage != nil) {
            togglePoster(show: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerItemContext = 0
    var isFullScreen = false
    var playerItem: AVPlayerItem?
    var containerView:UIView
    var setting:PlayerSetting
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
    
    var marqueeStarted:Bool = false;
    
    var hideControlWork:DispatchWorkItem?
    var currentPlayingItem: PlayingItem
    var currentTime = Double(0.0)
    var _playerObserver:Any?
    var autoplayCalled = false;
    var loaderDelegate:CacheResourceLoaderDelegate?;
    
    
    lazy var viewController:LandscapeViewController = {
        let _viewController = LandscapeViewController();
        _viewController.modalPresentationStyle = .fullScreen
        return _viewController;
    }()
    
    lazy var backIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "arrow_back"))
        button.sizeToFit()
        return button
    }()
    
    lazy var posterBackIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "arrow_back"))
        button.sizeToFit()
        return button
    }()
    
    lazy var posterImg: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.isHidden = true
        v.image = MediaResource.shared.getImage(name: "video_poster")
        v.backgroundColor = .black;
        return v;
    }()
    
    lazy var screenCaptureView:UIView = {
        let v = UIView()
        let l = UILabel()
        l.textColor = .white
        l.text = setting.protectionText ?? "In order to protect our digital content, please close record or share screen function"
        l.numberOfLines = 4
        l.font = UIFont.systemFont(ofSize: 14)
        v.addSubview(l)
        l.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(300)
        }
        l.textAlignment = .center
        v.backgroundColor = .black
        v.isHidden = true
        return v
    }()
    
    lazy var errorMessage:UILabel = {
        let label = UILabel();
        label.textColor = .white
        label.layer.masksToBounds = false
        label.layer.shadowRadius = 2.0
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize(width: 1, height: 2)
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 4
        label.textAlignment = .center
        return label
    }()
    
    lazy var title:UILabel = {
        let label = UILabel();
        label.textColor = .white
        label.layer.masksToBounds = false
        label.layer.shadowRadius = 2.0
        label.layer.shadowOpacity = 0.5
        label.layer.shadowOffset = CGSize(width: 1, height: 2)
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        return label
    }()
    
    lazy var timeLabel:UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10)
        l.textColor = .white
        l.layer.masksToBounds = false
        l.layer.shadowRadius = 2.0
        l.layer.shadowOpacity = 0.5
        l.layer.shadowOffset = CGSize(width: 1, height: 2)
        l.isHidden = true
        return l;
    }()
    
    lazy var networkView:UIImageView = {
        let i = UIImageView()
        i.image = MediaResource.shared.getImage(name: "cellular")
        i.isHidden = true
        return i
    }()
    
    lazy var rateIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "play_speed"))
        button.sizeToFit()
        return button
    }()
    
    lazy var rateSelectionView:PlayRateSelectionView = {
        let v = PlayRateSelectionView()
        v.isHidden = true
        v.onRateChanged = self.onRateChanged
        return v
    }()
    
    lazy var fullscreenIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "fullscreen"))
        button.sizeToFit()
        return button
    }()
    
    lazy var pipIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "picture_in_picture"))
        button.sizeToFit()
        return button
    }()
    
    lazy var playIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "play"))
        button.sizeToFit()
        return button
    }()
    
    lazy var playNextIcon:UIButton = {
        let button = UIButton(type: .custom)
        button.setAllStateImage(MediaResource.shared.getImage(name: "skip_next"))
        button.sizeToFit()
        button.isHidden = true
        return button
    }()
    
    lazy var playNextLabel: PaddingLabel = {
        let l = PaddingLabel()
        l.textColor = .white
        l.layer.cornerRadius = 10
        l.layer.masksToBounds = true
        l.backgroundColor = .black.withAlphaComponent(0.7)
        l.isHidden = true
        l.paddingTop = 6
        l.paddingBottom = 6
        l.paddingLeft = 10
        l.paddingRight = 10
        l.font = UIFont.systemFont(ofSize: 10)
        return l
    }()
    
    lazy var videoSlider: VideoSlider = {
        let slider = VideoSlider()
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
        return view
    }()
    
    lazy var gradientBottomView:UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    lazy var marqueeLabel:UILabel = {
        let l = UILabel()
        l.sizeToFit()
        return l
    }()
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
   
    
    func setupUI() {
        self.addSubview(timerDraggingView)
        self.addSubview(errorMessage)
        self.addSubview(playNextLabel)
        self.addSubview(activityIndicator)
        self.addSubview(rateSelectionView)
        self.addSubview(videoControllContainer)
        self.addSubview(screenCaptureView)

        videoControllContainer.addSubview(gradientBottomView)
        videoControllContainer.addSubview(backIcon)
        videoControllContainer.addSubview(title)
        videoControllContainer.addSubview(timeLabel)
        videoControllContainer.addSubview(networkView)
        videoControllContainer.addSubview(playIcon)
        videoControllContainer.addSubview(playNextIcon)
        videoControllContainer.addSubview(pipIcon)
        videoControllContainer.addSubview(fullscreenIcon)
        videoControllContainer.addSubview(rateIcon)
        videoControllContainer.addSubview(videoSlider)
        videoControllContainer.addSubview(currentTimeLabel)
        videoControllContainer.addSubview(durationTimeLabel)
        videoControllContainer.addSubview(rateSelectionView)
        timerDraggingView.addSubview(timerDraggingLabel)
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        screenCaptureView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        errorMessage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.width.lessThanOrEqualToSuperview().offset(-20)
            make.right.equalToSuperview().offset(-20)
        }
        
        playNextLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(baseOffset)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        videoControllContainer.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        gradientBottomView.snp.makeConstraints { make in
            make.bottom.equalTo(videoControllContainer)
            make.height.equalTo(36)
            make.width.equalToSuperview()
        }
        
        backIcon.snp.makeConstraints { make in
            make.top.equalTo(self).offset(baseOffset)
            make.left.equalTo(self).offset(baseOffset)
        }
        
        backIcon.isHidden = setting.hideBackButton
        
        title.snp.makeConstraints { make in
            make.centerY.equalTo(backIcon)
            make.left.equalTo(backIcon).offset(backIcon.frame.width + baseOffset)
            make.width.equalTo(250)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.centerX.equalToSuperview()
        }
        
        networkView.snp.makeConstraints { make in
            make.centerY.equalTo(backIcon)
            make.right.equalToSuperview().offset(baseOffset * -1)
        }
        
        playIcon.snp.makeConstraints { make in
            make.bottom.equalTo(videoControllContainer).offset(baseOffset * -0.5)
            make.left.equalTo(videoControllContainer).offset(baseOffset)
        }
        
        playNextIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.left.equalTo(playIcon.snp.right).offset(baseOffset)
        }
        
        fullscreenIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo(videoControllContainer).offset(baseOffset * -1)
        }
        
        rateIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo((pipIcon.isHidden ? fullscreenIcon.snp.left : pipIcon.snp.left)).offset(baseOffset * -1)
        }
        
        rateSelectionView.snp.makeConstraints { make in
            make.width.equalTo(rateIcon.snp.width).offset(12)
            make.height.equalTo(80)
            make.bottom.equalTo(rateIcon.snp.top)
            make.left.equalTo(rateIcon.snp.left).offset(-6)
        }
        
        pipIcon.snp.makeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo(rateIcon.snp.left).offset(baseOffset * -1)
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
            make.right.equalTo((pipIcon.isHidden ? rateIcon.snp.left : pipIcon.snp.left)).offset(baseOffset * -1)
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
        backIcon.addTarget(self, action: #selector(backIconClicked), for: .touchDown)
        playIcon.addTarget(self, action: #selector(togglePlay), for: .touchDown)
        playNextIcon.addTarget(self, action: #selector(playNext), for: .touchDown)
        pipIcon.addTarget(self, action: #selector(pipIconClicked), for: .touchDown)
        videoSlider.addTarget(self, action: #selector(onVideoSliderValChanged(slider:event:)), for: .valueChanged)
        rateIcon.addTarget(self, action: #selector(rateIconClicked), for: .touchDown)
        fullscreenIcon.addTarget(self, action: #selector(fullscreenIconClicked), for: .touchDown)
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
        NotificationCenter.default.removeObserver(self)
        release();
        print("deinit of PlayerView")
    }
}
