//
//  PlayerView+Action.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/7.
//

import Foundation
import AVKit

extension PlayerView {
    
    func play(with url: URL) {
        setUpAsset(with: url) { [weak self] (asset: AVAsset) in
            self?.setUpPlayerItem(with: asset)
        }
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
                print(".failed")
            case .cancelled:
                print(".cancelled")
            default:
                print("default")
            }
        }
    }
    
    private func setUpPlayerItem(with asset: AVAsset) {
        self.playerItem = AVPlayerItem(asset: asset)
        self.playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        
        DispatchQueue.main.async { [weak self] in
            self?.player = AVPlayer(playerItem: self?.playerItem!)
            self?.duration = CMTimeGetSeconds(asset.duration)
            self?.durationTimeLabel.text = formatTime(seconds: self?.duration ?? 0)
            self?.videoSlider.maximumValue = Float(self?.duration ?? 0)
            self?.onProgress()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
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
            // Switch over status value
            switch status {
            case .readyToPlay:
                print(".readyToPlay")
                player?.play()
                toggleControl();
                playIcon.setImage(MediaResource.shared.getImage(name: "pause"), for: .normal)
            case .failed:
                print(".failed")
            case .unknown:
                print(".unknown")
            @unknown default:
                print("@unknown default")
            }
        }
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
            switch touchEvent.phase {
            case .began:
                // handle drag began
                timerDraggingView.isHidden = false
            case .moved:
                // handle drag moved
                timerDraggingLabel.text = formatTime(seconds: Double(slider.value)) + " / " + (durationTimeLabel.text ?? "00:00")
            case .ended:
                // handle drag ended
                seekTo()
            default:
                break
            }
        }
    }
    
    func seekTo() {
        if player == nil { return }
        let selectedTime: CMTime = CMTimeMake(value: Int64(videoSlider.value * 1000), timescale: 1000)
        player?.seek(to: selectedTime)
        player?.pause()
        player?.play()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.timerDraggingView.isHidden = true
        }
    }
    
    func toggleFullscreen(isFullScreen:Bool, shouldRotate:Bool = true) {
        if(self.isFullScreen == isFullScreen){
            return;
        }
        self.isFullScreen = isFullScreen;
        if(isFullScreen) {
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
                // todo toast message?
                return;
            }
            if(shouldRotate){
                UIDevice.current.setValue(UIDeviceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            }
            self.removeFromSuperview();
            self.viewController.view.addSubview(self);
            self.snp.makeConstraints({ make in
                make.edges.equalTo(self.viewController.view)
            })
            keyWindow!.rootViewController?.present(self.viewController, animated: true, completion: nil)
        }else {
            self.removeFromSuperview();
            self.viewController.dismiss(animated: true);
            self.containerView.addSubview(self)
            self.containerView.backgroundColor = .yellow;
            self.snp.makeConstraints({ make in
                make.edges.equalTo(self.containerView)
            })
            if(shouldRotate){
                UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
        rateIcon.isHidden = isFullScreen ? false : true
        durationTimeLabel.snp.remakeConstraints { make in
            make.centerY.equalTo(playIcon)
            make.right.equalTo(isFullScreen ? rateIcon.snp.left : (pipIcon.isHidden ? fullscreenIcon.snp.left : pipIcon.snp.left) ).offset(baseOffset * -1)
        }
        toggleTimeLabel()
        toggleNetwork()
        fullscreenIcon.setImage(MediaResource.shared.getImage(name: isFullScreen ? "fullscreen_exit":"fullscreen"), for: .normal)
    }
    
    func onProgress() {
        self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: DispatchQueue.main) { (CMTime) -> Void in
            if self.player!.currentItem?.status == .readyToPlay {
                let time : Float64 = CMTimeGetSeconds(self.player!.currentTime());
                print(time)
                if(self.timerDraggingView.isHidden) {
                    self.videoSlider.value = Float(time);
                }
                let timer = formatTime(seconds: time)
                self.currentTimeLabel.text = timer
                self.currentTimeLabel.snp.updateConstraints { make in
                    make.width.equalTo(timer.count > 5 ? 54 : 36)
                }
            }
            let playbackLikelyToKeepUp = self.player?.currentItem?.isPlaybackLikelyToKeepUp
            if playbackLikelyToKeepUp == false{
                print("IsBuffering")
                //                self.ButtonPlay.isHidden = true
                //                self.loadingView.isHidden = false
            } else {
                //                //stop the activity indicator
                print("Buffering completed")
                //                self.ButtonPlay.isHidden = false
                //                self.loadingView.isHidden = true
            }
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
}

