////
////  Marquee.swift
////  video_player_oneplusdream
////
////  Created by Conan on 2022/9/30.
////
//
import Foundation

extension PlayerView {
    func initMarquee(_ text:String) {
        let attrStri = NSMutableAttributedString.init(string:text)
        for _ in text.enumerated() {
            let v = Int.random(in: 0..<text.count)
            attrStri.addAttribute(NSAttributedString.Key.foregroundColor, value: self.randomColor(index:Int32(v)), range: NSMakeRange(v, 1))
        }
        marqueeLabel.text = text
        marqueeLabel.sizeToFit()
        marqueeLabel.attributedText = attrStri
        marqueeLabel.isHidden = true
    }
    
    func startMarquee(_ text: String) {
        if (marqueeStarted) {
            return
        }
        marqueeStarted = true
        marqueeLabel.layer.removeAllAnimations()
        marqueeLabel.removeFromSuperview()
        initMarquee(text)
        self.addSubview(marqueeLabel)
        let fullscreen = self.isFullScreen
        let width = UIScreen.main.bounds.size.width
        let _altitude = marqueeLabel.frame.size.height
        let _len = marqueeLabel.frame.size.width
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.marqueeLabel.isHidden = false
            var y = max(self.bounds.size.height, 100);
            y = CGFloat.random(in: (_altitude + 20)..<(y - 20));
            self.marqueeLabel.frame = CGRect(x: _len * -2, y: y, width: _len, height:_altitude);
            UIView.animate(withDuration: fullscreen ? 10 : 6, delay: 0, options: UIView.AnimationOptions.curveLinear) { [self] in
                self.marqueeLabel.frame = CGRect(x: width + _len * 2, y: y, width: _len, height:_altitude);
            } completion: { [self] finished in
                self.marqueeStarted = false;
                self.startMarquee(text);
            }
            
        }
    }
    
    
    func randomColor(index:Int32) -> UIColor {
        let i = index % 5;
        if(i==0){
            return UIColor.red;
        }else if(i==1) {
            return UIColor.cyan;
        } else if (i==2) {
            return UIColor.blue;
        } else if(i==3){
            return UIColor.green;
        }else if(i==4){
            return UIColor.purple;
        }else {
            return UIColor.darkGray;
        }
    }
    
    
}


