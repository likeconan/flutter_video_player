//
//  PlayRateSelectionView.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/11/12.
//

import Foundation
import AVKit
import MediaPlayer

class PlayRateSelectionView: UIView {
    
    let rates: [Float] = [2.0, 1.5, 1.2, 1.0, 0.5]
    var onRateChanged: ((Float) -> Void)?
    
    required init() {
        super.init(frame: .zero)
        self.backgroundColor = .black.withAlphaComponent(0.2)
        var rateViews:[UIButton] = []
        for rate in rates {
            let r = RateUIButton()
            r.setTitle("x \(rate)", for: .normal)
            r.titleLabel?.textAlignment = .center
            r.titleLabel?.textColor = .white
            r.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            rateViews.append(r)
            self.addSubview(r)
            r.rate = rate
            r.addTarget(self, action: #selector(rateClicked), for: .touchDown)
        }
        var i = 0;
        for v in rateViews {
            v.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(16)
                make.top.equalTo(i * 16)
            }
            i += 1;
        }
    }
    
    @objc private func rateClicked(sender:RateUIButton ) {
        print(sender.rate)
        guard let call = self.onRateChanged else {return}
        call(sender.rate)
//        if( != nil) {
//            self.onRateChanged(sender.rate)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class RateUIButton: UIButton {
    var rate = Float()
}
