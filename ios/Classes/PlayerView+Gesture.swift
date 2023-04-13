//
//  PlayerView+Gesture.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/10.
//

import Foundation
import Network
import MediaPlayer

extension PlayerView {
    
    func bindGestures() {
        bindSpeed();
        bindSwipe();
        bindDoubleTap();
        bindTap();
    }
    
    func unbindGestures() {
        for recognizer in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(recognizer)
        }
    }
    
    func bindSpeed() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(speedUp))
        longPressRecognizer.numberOfTouchesRequired = 1
        longPressRecognizer.minimumPressDuration = 2
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    func bindSwipe() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panedView(_:)))
        self.addGestureRecognizer(panGestureRecognizer)
    }
    
    func bindDoubleTap() {
        let tapGR = UITapGestureRecognizer(target:self,action:#selector(togglePlay))
        tapGR.numberOfTapsRequired = 2
        self.addGestureRecognizer(tapGR)
    }
    
    func bindTap() {
        let tapGR = UITapGestureRecognizer(target:self,action:#selector(toggleControl))
        tapGR.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGR)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(sliderTapped))
        self.videoSlider.addGestureRecognizer(tap)
    }
    
    @objc func togglePlay() {
        if(self.player?.timeControlStatus == nil) {
            self.play(with: setting.playingItems[(getCurrentPlayIndex())])
            playIcon.setAllStateImage(MediaResource.shared.getImage(name: "pause"))
            onPlayingEvent(status: PlayingStatus.play);
            return;
        }
        togglePause(isPause: self.player?.timeControlStatus == .playing)
    }
    
    func togglePause(isPause:Bool) {
        if(self.player?.timeControlStatus == nil) {
            return;
        }
        if(isPause){
            self.player?.pause();
            playIcon.setAllStateImage(MediaResource.shared.getImage(name: "play"))
            self.hideControlWork?.cancel()
            onPlayingEvent(status: PlayingStatus.pause);
        }else {
            self.player?.play();
            playIcon.setAllStateImage(MediaResource.shared.getImage(name: "pause"))
            onPlayingEvent(status: PlayingStatus.play);
        }
    }
    
    func onPlayingEvent(status:PlayingStatus) {
        self.delegate?.onPlaying(event: PlayingEvent(item:currentPlayingItem,status: status,currentPosition: self.currentTime));
    }
    
    @objc func sliderTapped(gestureRecognizer: UILongPressGestureRecognizer) {
        let width = videoSlider.frame.size.width;
        let tapPoint = gestureRecognizer.location(in: videoSlider)
        let fP = tapPoint.x / width;
        let newV = videoSlider.maximumValue * Float(fP) + 0.5;
        if(newV != videoSlider.value) {
            videoSlider.value = newV
        }
        let selectedTime: CMTime = CMTimeMake(value: Int64(videoSlider.value * 1000), timescale: 1000)
        seekTo(time:selectedTime)
        toggleControl()
    }
    
    @objc func toggleControl() {
        if(setting.hideControls) {
            return;
        }
        self.videoControllContainer.isHidden = false
        toggleTimeLabel()
        toggleNetwork()
        togglePlayNextLabel(show: nil)
        self.hideControlWork?.cancel()
        self.hideControlWork = DispatchWorkItem(block: {
            self.videoControllContainer.isHidden = true
            self.rateSelectionView.isHidden = true
            self.playNextLabel.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(self.baseOffset)
                make.bottom.equalToSuperview().offset(self.videoControllContainer.isHidden ? -12 : -48)
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: self.hideControlWork!)
    }
    
    @objc func speedUp(gestureRecognizer: UILongPressGestureRecognizer) {
        if(UIGestureRecognizer.State.began == gestureRecognizer.state) {
            self.player?.rate = 3;
        }else if(UIGestureRecognizer.State.ended == gestureRecognizer.state) {
            self.player?.rate = 1;
        }
    }
    
    @objc func panedView(_ sender:UIPanGestureRecognizer){
        let distanceKey:CGFloat = 10;
        if (sender.state == UIGestureRecognizer.State.began) {
            self.startLocation = sender.location(in: self)
            self.currentSliderTime = CGFloat(self.videoSlider.value)
        } else if (sender.state == UIGestureRecognizer.State.changed || sender.state == UIGestureRecognizer.State.ended) {
            let stopLocation = sender.location(in: self)
            let dx = stopLocation.x - self.startLocation.x;
            let dy = stopLocation.y - self.startLocation.y;
            
            if(gestureSwipeEvent == GestureEvent.none) {
                if(abs(dx) < distanceKey && abs(dy) > distanceKey) {
                    let isLeft = self.startLocation.x <= (sender.view?.frame.width ?? 0) / 2;
                    gestureSwipeEvent = isLeft ? GestureEvent.brightness : GestureEvent.volume;
                }else if(abs(dx) > distanceKey && abs(dy) < distanceKey) {
                    gestureSwipeEvent = GestureEvent.seek;
                }
            } else {
                handleSwipeEvent(type: gestureSwipeEvent, val: gestureSwipeEvent == GestureEvent.seek ? dx : dy, isEnded: sender.state == UIGestureRecognizer.State.ended)
            }
        }
    }
    
    func handleSwipeEvent(type:GestureEvent, val:CGFloat, isEnded: Bool) {
        NSLog("Gesture: \( type.description()), Change Value: %f", val)
        if(type == GestureEvent.volume) {
            MPVolumeView.setVolume(CGFloat(currentVolume) - val / 100)
        } else if(type == GestureEvent.brightness) {
            UIScreen.main.brightness = currentBrightness - val / 100
        } else if(type == GestureEvent.seek) {
            let current = max(min(self.currentSliderTime + val, self.duration), 0)
            timerDraggingView.isHidden = false
            timerDraggingLabel.text = formatTime(seconds: current) + " / " + (durationTimeLabel.text ?? "00:00")
        }
        if(isEnded) {
            currentVolume = AVAudioSession.sharedInstance().outputVolume
            currentBrightness = UIScreen.main.brightness
            if(type == GestureEvent.seek) {
                let current = max(min(self.currentSliderTime + val, self.duration), 0)
                self.videoSlider.value = Float(current)
                let selectedTime: CMTime = CMTimeMake(value: Int64(videoSlider.value * 1000), timescale: 1000)
                seekTo(time:selectedTime)
            }
            gestureSwipeEvent = GestureEvent.none
        }
    }
    
    func toggleTimeLabel() {
        self.timeLabel.isHidden = !self.isFullScreen
        if(self.isFullScreen) {
            let currentDateTime = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            self.timeLabel.text = "\(dateFormatter.string(from: currentDateTime))"
        }
    }
    
    func toggleNetwork() {
        self.networkView.isHidden = !self.isFullScreen
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.sync {
                    if path.usesInterfaceType(.wifi) {
                        self.networkView.image = MediaResource.shared.getImage(name: "wifi")
                    } else if path.usesInterfaceType(.cellular) {
                        self.networkView.image = MediaResource.shared.getImage(name: "cellular")
                    }
                }
            } else if path.status == .unsatisfied {
                
            }
            monitor.cancel()
        }
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
        
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: CGFloat) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            NSLog("Changed volume %f", volume)
            slider?.value = Float(volume)
        }
    }
    
    static func getVolume()->Float {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        return slider?.value ?? 0;
    }
}


