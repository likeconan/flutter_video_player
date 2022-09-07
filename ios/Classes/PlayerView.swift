//
//  PlayerView.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/7.
//

import Foundation
import AVKit

class PlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    required init(containerView: UIView) {
        self.containerView = containerView
        super.init(frame: .zero)
        setupUI();
        bindActions();
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerItemContext = 0
    var isFullScreen = false;
    var playerItem: AVPlayerItem?
    var containerView:UIView;
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
    }
    
    func bindActions() {
        
        backIcon.addTarget(self, action: #selector(backIconClicked), for: .touchUpInside)
    }
    
    deinit {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        print("deinit of PlayerView")
    }
    
}
