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
    }
}

