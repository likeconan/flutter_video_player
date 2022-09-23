//
//  PlayerView+Gesture.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/10.
//

import Foundation
import MediaPlayer

extension PlayerView {
    
    func bindGestures() {
        bindSpeed();
        bindSwipe();
        bindDoubleTap();
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
    
    @objc func togglePlay() {
        if(self.player?.timeControlStatus == .paused){
            self.player?.play();
            playIcon.setImage(MediaResource.shared.getImage(name: "pause"), for: .normal)
        } else if(self.player?.timeControlStatus == .playing) {
            self.player?.pause();
            playIcon.setImage(MediaResource.shared.getImage(name: "play"), for: .normal)
        }
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
                seekTo()
            }
            gestureSwipeEvent = GestureEvent.none
        }
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
