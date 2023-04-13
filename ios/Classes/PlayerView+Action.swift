//
//  PlayerView+Action.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/7.
//

import Foundation
import AVKit

extension PlayerView {
    
    func play(with item: PlayingItem) {
        guard let url = URL(string: item.url) else {
            // todo error
            return;}
        currentPlayingItem = item;
        self.currentTime = currentPlayingItem.position ?? 0;
        if(self._playerObserver != nil) {
            self.player?.removeTimeObserver(self._playerObserver);
        }
        self.posterImg.removeFromSuperview()
        self.posterBackIcon.removeFromSuperview()
        self.videoControllContainer.isHidden = setting.hideControls
        if let text = setting.marqueeText,
           setting.enableMarquee {
            startMarquee(text)
        }
        if(setting.enablePreventScreenCapture) {
            self.captureChanged()
        }
        bindGestures()
        bindActions()
        self.activityIndicator.startAnimating()
        setUpAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.setUpPlayerItem(with: asset)
        }
        self.title.text = item.title
        togglePlayNextLabel(show: false)
    }
    
    func resume() {
        play(with: setting.playingItems[getCurrentPlayIndex()])
    }
    
    func release() {
        player?.pause()
        onPlayingEvent(status: PlayingStatus.release);
        player?.replaceCurrentItem(with: nil)
        videoControllContainer.isHidden = true
        unbindGestures()
        marqueeLabel.layer.removeAllAnimations()
        marqueeLabel.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpAsset(with u: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        guard let url = getCachedURL(url: u) else {
            errorMessage.isHidden = false;
            errorMessage.text = "Cannot cache video to play."
            return
        }
        let asset: AVURLAsset?;
        if(!url.path.hasSuffix(".m3u8") && FileManager.default.fileExists(atPath: url.path)) {
            asset = AVURLAsset(url: url)
        }else {
            self.loaderDelegate = CacheResourceLoaderDelegate(withURL: u)
            asset = AVURLAsset(url: self.loaderDelegate!.streamingAssetURL)
            asset!.resourceLoader.setDelegate(self.loaderDelegate, queue: DispatchQueue.main)
        }
        asset?.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset?.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset!)
            case .failed:
                self.toggleMessage(msg: "Asset failed to load.")
            case .cancelled:
                self.toggleMessage(msg: "Asset cancelled to play.")
            default:
                self.toggleMessage(msg: "Asset cannot play with unknow reason.")
            }
        }
        
    }
    
    private func toggleMessage(msg: String?) {
        DispatchQueue.main.async {
            if (msg == nil) {
                self.errorMessage.isHidden = true
            } else {
                self.errorMessage.isHidden = false
                self.errorMessage.text = msg;
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        
        self.playerItem = AVPlayerItem(asset: asset)
        self.playerItem?.preferredForwardBufferDuration = self.setting.bufferDuration ?? 5;
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: &playerItemContext)
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.new], context: &playerItemContext)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if(self.player == nil){
                self.player = AVPlayer(playerItem: self.playerItem!)
            }else {
                self.player?.replaceCurrentItem(with: self.playerItem!)
            }
            self.playerLayer.videoGravity = self.currentPlayingItem.fitMode == FitMode.contain ? AVLayerVideoGravity.resizeAspect : AVLayerVideoGravity.resizeAspectFill;
            self.setViewAspectRatio()
            self.player?.play()
            if (self.setting.autoPlay || self.autoplayCalled) {
                self.toggleControl();
                self.playIcon.setAllStateImage(MediaResource.shared.getImage(name: "pause"))
            } else {
                self.player?.pause()
            }
            self.autoplayCalled = true;
            self.errorMessage.isHidden = true;
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        self.activityIndicator.stopAnimating()
        print("value \(change?[.newKey])")
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                self.onPlayingEvent(status: PlayingStatus.start);
                if(self.currentTime > 0){
                    let c:CMTime = CMTimeMake(value: Int64(self.currentTime * 1000), timescale: 1000)
                    self.seekTo(time: c)
                }
                self.videoSlider.value = Float(self.currentTime);
                self.duration = CMTimeGetSeconds(self.player?.currentItem?.duration ?? CMTime(value: 0, timescale: 1000))
                self.durationTimeLabel.text = formatTime(seconds: self.duration)
                self.videoSlider.maximumValue = Float(self.duration)
                self.onProgress();
   
                errorMessage.isHidden = true;
            case .failed:
                errorMessage.text = "Player failed to play."
                errorMessage.isHidden = false
            case .unknown:
                errorMessage.text = "Player cannot play with unkown reason."
                errorMessage.isHidden = false
            @unknown default:
                errorMessage.text = "Player has something wrong."
                errorMessage.isHidden = false
            }
        } else if (keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp)) {
            let canPlay = change?[.newKey] as? Bool ?? false
            if(canPlay) {
                self.activityIndicator.stopAnimating()
            }else {
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    @objc func playNext() {
        let ind = getCurrentPlayIndex();
        if(ind < setting.playingItems.count - 1) {
            self.play(with: setting.playingItems[ind+1])
            onPlayingEvent(status: PlayingStatus.start);
        }
    }
    
    func getCurrentPlayIndex()->Int {
        guard let ind = setting.playingItems.firstIndex(where: { $0.id == currentPlayingItem.id }) else {return 0}
        return ind;
    }
    
    @objc func backIconClicked() {
        if(self.isFullScreen) {
            toggleFullscreen(isFullScreen:false);
        } else {
            self.delegate?.onBack();
        }
    }
    
    @objc func fullscreenIconClicked() {
        toggleFullscreen(isFullScreen: !self.isFullScreen);
    }
    
    @objc func onVideoSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            print(touchEvent.phase.rawValue)
            switch touchEvent.phase {
            case .began:
                timerDraggingView.isHidden = false
            case .moved:
                timerDraggingLabel.text = formatTime(seconds: Double(slider.value)) + " / " + (durationTimeLabel.text ?? "00:00")
            case .ended:
                let selectedTime: CMTime = CMTimeMake(value: Int64(videoSlider.value * 1000), timescale: 1000)
                seekTo(time:selectedTime)
            default:
                break
            }
        }
    }
    
    func seekTo(time:CMTime) {
        guard let p = self.player else {return}
        p.seek(to: time)
        p.pause()
        p.play()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.timerDraggingView.isHidden = true
        }
    }
    
    func togglePoster(show:Bool) {
        if(show) {
            self.addSubview(posterImg)
            posterImg.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.posterImg.isHidden = false
            if(!setting.hideBackButton) {
                self.addSubview(posterBackIcon)
                posterBackIcon.snp.makeConstraints { make in
                    make.top.equalTo(self).offset(baseOffset)
                    make.left.equalTo(self).offset(baseOffset)
                }
                posterBackIcon.addTarget(self, action: #selector(backIconClicked), for: .touchDown)
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(handlePosterImageClicked))
            posterImg.addGestureRecognizer(tap)
            posterImg.isUserInteractionEnabled = true
            if(setting.posterImage != nil) {
                self.posterImg.load(url: URL(string: setting.posterImage!)!)
            }
        } else {
            self.posterImg.removeFromSuperview()
        }
        
    }
    @objc private func handlePosterImageClicked() {
        self.play(with: setting.playingItems[getCurrentPlayIndex()])
    }
    
    func setViewAspectRatio() {
        self.snp.remakeConstraints({ make in
            make.width.equalToSuperview()
            if(currentPlayingItem.aspectRatio != nil && currentPlayingItem.fitMode == FitMode.cover) {
                make.height.greaterThanOrEqualTo(self.snp.width).dividedBy(currentPlayingItem.aspectRatio!)
                make.height.lessThanOrEqualToSuperview()
            }else {
                make.height.equalToSuperview()
            }
            make.center.equalToSuperview()
        })
        
    }
    
    func toggleFullscreen(isFullScreen:Bool) {
        if(self.isFullScreen == isFullScreen){
            return;
        }
        self.isFullScreen = isFullScreen;
        var keyWindow:UIWindow?;
        if #available(iOS 13.0, *) {
            keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            
        } else {
            keyWindow = UIApplication.shared.keyWindow
        }
        if(keyWindow == nil) {
            self.delegate?.showToast(message: "Cannot find root window to play.", type: ToastType.error)
            return;
        }
        if(isFullScreen) {
            self.removeFromSuperview();
            self.backIcon.isHidden = false;
            self.viewController.view.addSubview(self);
            self.snp.makeConstraints({ make in
                make.edges.equalTo(self.viewController.view)
            })
            keyWindow!.rootViewController?.present(self.viewController, animated: true, completion: nil)
        }else {
            self.removeFromSuperview();
            self.viewController.dismiss(animated: true);
            DispatchQueue.main.async {
                self.containerView.addSubview(self)
                self.backIcon.isHidden = self.setting.hideBackButton;
                self.setViewAspectRatio()
            }
        }
        playNextIcon.isHidden = !isFullScreen
        currentTimeLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.width.equalTo(36)
            make.left.equalTo(isFullScreen ? playNextIcon.snp.right : playIcon.snp.right).offset(baseOffset)
        }
        durationTimeLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo(pipIcon.isHidden ? rateIcon.snp.left : pipIcon.snp.left).offset(baseOffset * -1)
        }
        toggleTimeLabel()
        toggleNetwork()
        fullscreenIcon.setAllStateImage(MediaResource.shared.getImage(name: isFullScreen ? "fullscreen_exit":"fullscreen"))
    }
    
    func onProgress() {
        self._playerObserver =  self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                self.currentTime = CMTimeGetSeconds(self.player!.currentTime());
                if(self.timerDraggingView.isHidden) {
                    self.videoSlider.value = Float(self.currentTime);
                }
                
                let timer = formatTime(seconds: self.currentTime)
                self.currentTimeLabel.text = timer
                self.currentTimeLabel.snp.updateConstraints { make in
                    make.width.equalTo(timer.count > 5 ? 54 : 36)
                }
                if(self.currentTime >= self.duration - 5) {
                    let ind = self.getCurrentPlayIndex()
                    self.playNextLabel.text = ind + 1 < self.setting.playingItems.count ? "Going to play next video \(self.setting.playingItems[ind+1].title ?? "")" : (self.setting.lastPlayMessage ?? "This is the last video.")
                    self.togglePlayNextLabel(show: true)
                } else {
                    self.togglePlayNextLabel(show: false)
                }
            }
            
            self.errorMessage.isHidden = true
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func togglePlayNextLabel(show:Bool?) {
        if(show == nil && !self.playNextLabel.isHidden) {
            self.playNextLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(self.baseOffset)
                make.bottom.equalToSuperview().offset(self.videoControllContainer.isHidden ? -12 : -48)
            }
        }
        if let s = show {
            self.playNextLabel.isHidden = !s
        }
    }
    
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController,
                                    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // Restore the user interface.
        print("pip completed")
        completionHandler(true)
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // Hide the playback controls.
        // Show the placeholder artwork.
        print("start pip")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // Hide the placeholder artwork.
        // Show the playback controls.
        print("stop pip")
    }
    
    @objc func pipIconClicked() {
        if self.pipController.isPictureInPictureActive {
            self.pipController.stopPictureInPicture()
        } else {
            self.pipController.startPictureInPicture()
        }
    }
    
    @objc func rateIconClicked() {
        self.rateSelectionView.isHidden = !self.rateSelectionView.isHidden
    }
    
    func onRateChanged(rate:Float) {
        self.player?.rate = rate
        self.delegate?.onRateChange(rate: rate)
        self.rateIcon.setAllStateImage(nil)
        self.rateIcon.setTitle("x \(rate)", for: .normal)
        self.rateIcon.titleLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        let playerItem = sender.object as? AVPlayerItem;
        if(playerItem == self.playerItem){
            self.onPlayingEvent(status: PlayingStatus.end)
            playNext()
        }
        
    }
    
    @objc func captureChanged() {
        self.screenCaptureView.isHidden = !UIScreen.main.isCaptured
        if(UIScreen.main.isCaptured) {
            self.bringSubviewToFront(screenCaptureView)
            togglePause(isPause: true)
        }else {
            togglePause(isPause: false)
        }
    }
}

