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
        self.posterImg.removeFromSuperview()
        self.posterBackIcon.removeFromSuperview()
        self.videoControllContainer.isHidden = false
        if let text = setting.marqueeText,
           setting.enableMarquee {
            startMarquee(text)
        }
        if(setting.enablePreventScreenCapture) {
            self.captureChanged()
        }
        currentPlayingItem = item
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
        play(with: setting.playingItems[getCurrentPlayIndex() ?? 0])
    }
    
    func release() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        videoControllContainer.isHidden = true
        unbindGestures()
        marqueeLabel.layer.removeAllAnimations()
        marqueeLabel.removeFromSuperview()
    }
    
    private func setUpAsset(with url: URL, completion: ((_ asset: AVAsset) -> Void)?) {
        let asset = AVAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                completion?(asset)
            case .failed:
                self.errorMessage.isHidden = true
                self.errorMessage.text = "Asset failed to load."
            case .cancelled:
                self.errorMessage.isHidden = true
                self.errorMessage.text = "Asset cancelled to play."
            default:
                self.errorMessage.text = "Asset cannot play with unknow reason."
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        
        self.playerItem = AVPlayerItem(asset: asset)
        //        self.playerItem?.preferredPeakBitRate = 200000.0
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.player = AVPlayer(playerItem: self.playerItem!)
            if(self.currentTime > 0){
                let c:CMTime = CMTimeMake(value: Int64(self.currentTime * 1000), timescale: 1000)
                self.player?.seek(to: c)
            }
            self.duration = CMTimeGetSeconds(asset.duration)
            self.durationTimeLabel.text = formatTime(seconds: self.duration)
            self.videoSlider.maximumValue = Float(self.duration)
            self.onProgress()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .readyToPlay:
                player?.play()
                toggleControl();
                errorMessage.isHidden = true
                playIcon.setAllStateImage(MediaResource.shared.getImage(name: "pause"))
                self.delegate?.onPlaying(event: PlayingEvent(item: setting.playingItems[getCurrentPlayIndex()!], status: PlayingStatus.start));
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
        }
    }
    
    @objc func playNext() {
        guard let ind = getCurrentPlayIndex() else {return}
        if(ind < setting.playingItems.count - 1) {
            self.currentTime = 0
            self.play(with: setting.playingItems[ind+1])
            self.delegate?.onPlaying(event: PlayingEvent(item: setting.playingItems[ind+1], status: PlayingStatus.start));
        }else {
            self.delegate?.showToast(message:setting.lastPlayMessage ?? "This is the last one for play.", type: ToastType.info)
        }
    }
    
    func getCurrentPlayIndex()->Int? {
        guard let url = (self.player?.currentItem?.asset as? AVURLAsset)?.url else {return nil}
        guard let ind = setting.playingItems.firstIndex(where: { $0.url == url.absoluteString }) else {return nil}
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
        print("value changed")
        if let touchEvent = event.allTouches?.first {
            print(touchEvent.phase.rawValue)
            switch touchEvent.phase {
            case .began:
                timerDraggingView.isHidden = false
            case .moved:
                timerDraggingLabel.text = formatTime(seconds: Double(slider.value)) + " / " + (durationTimeLabel.text ?? "00:00")
            case .ended:
                seekTo()
            default:
                break
            }
        }
    }
    
    func seekTo() {
        guard let p = self.player else {return}
        let selectedTime: CMTime = CMTimeMake(value: Int64(videoSlider.value * 1000), timescale: 1000)
        p.seek(to: selectedTime)
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
        self.play(with: setting.playingItems[getCurrentPlayIndex() ?? 0])
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
            self.delegate?.showToast(message:setting.lastPlayMessage ?? "Cannot find root window.", type: ToastType.error)
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
                self.snp.makeConstraints({ make in
                    make.edges.equalTo(self.containerView)
                })
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
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
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
                    if let ind = self.getCurrentPlayIndex(),
                       ind + 1 < self.setting.playingItems.count{
                        self.playNextLabel.text = "Going to play next video \(self.setting.playingItems[ind+1].title ?? "")"
                        self.togglePlayNextLabel(show: true)
                    }
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
        self.delegate?.onPlaying(event: PlayingEvent(item: setting.playingItems[getCurrentPlayIndex()!], status: PlayingStatus.end));
        playNext()
    }
    
    @objc func captureChanged() {
        self.screenCaptureView.isHidden = !UIScreen.main.isCaptured
        if(UIScreen.main.isCaptured) {
            self.bringSubviewToFront(screenCaptureView)
            self.player?.pause()
        }else {
            self.player?.play()
        }
    }
}

