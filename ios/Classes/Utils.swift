//
//  Utils.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/14.
//

import Foundation
import UIKit

class VideoSlider: UISlider {
    
    @IBInspectable var trackHeight: CGFloat = 2
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: CGPoint(x: bounds.origin.x, y: 6), size: CGSize(width: bounds.width, height: trackHeight))
    }
}

class LandscapeViewController: UIViewController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}

struct PlayerSetting {
    let autoPlay: Bool
    let protectionText: String?
    let enablePreventScreenCapture: Bool
    let marqueeText: String?
    let enableMarquee: Bool
    let playingItems: [PlayingItem]
    let lastPlayMessage: String?
    let posterImage: String?
    let hideBackButton: Bool
}

struct PlayingItem: Encodable {
    let url: String
    let title: String?
    let position: Double?
}

struct PlayingEvent: Encodable {
    let item: PlayingItem
    let status:PlayingStatus
}

enum PlayingStatus: Int, Encodable {
    case start = 0
    case pause = 1
    case play = 2
    case end = 3
    case error = 4
}

enum ToastType {
    case warning
    case info
    case error
    case success
    
    func toColor () -> UIColor {
        switch self {
        case .warning:
            return UIColor("#ff9800")
        case .info:
            return UIColor("#2196f3")
        case .error:
            return UIColor("#f44336")
        case .success:
            return UIColor("#4caf50")
        }
    }
}

enum GestureEvent {
    case volume
    case brightness
    case seek
    case none
    
    func description () -> String {
        switch self {
        case .volume:
            return "volume"
        case .brightness:
            return "brightness"
        case .seek:
            return "seek"
        case .none:
            return "none"
        }
    }
}

func formatTime(seconds: Double) -> String {
    let result = timeDivider(seconds: seconds)
    let hoursString = "\(result.hours)"
    var minutesString = "\(result.minutes)"
    var secondsString = "\(result.seconds)"
    
    if minutesString.count == 1 {
        minutesString = "0\(result.minutes)"
    }
    if secondsString.count == 1 {
        secondsString = "0\(result.seconds)"
    }
    
    var time = "\(hoursString):"
    if result.hours >= 1 {
        time.append("\(minutesString):\(secondsString)")
    }
    else {
        time = "\(minutesString):\(secondsString)"
    }
    return time
}

func timeDivider(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
    guard !(seconds.isNaN || seconds.isInfinite) else {
        return (0,0,0)
    }
    let secs: Int = Int(seconds)
    let hours = secs / 3600
    let minutes = (secs % 3600) / 60
    let seconds = (secs % 3600) % 60
    return (hours, minutes, seconds)
}

class MediaResource {
    static let shared = MediaResource()
    var onePlusBundle:Bundle?
    init(){
        let frameworkBundle = Bundle(for: MediaResource.self)
        if let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("OnePlusKitBundle.bundle") {
            onePlusBundle = Bundle(url: bundleURL)
        }
    }
    
    func getImage(name:String)->UIImage? {
        return UIImage(named: name,in:onePlusBundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    }
}


public class CustomTextToastView : UIStackView {
    public init(_ title: String, subtitle: String? = nil) {
        super.init(frame: CGRect.zero)
        axis = .vertical
        alignment = .center
        distribution = .fillEqually
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        titleLabel.numberOfLines = 1
        addArrangedSubview(titleLabel)
        
        if let subtitle = subtitle {
            let subtitleLabel = UILabel()
            subtitleLabel.textColor = .systemGray
            subtitleLabel.text = subtitle
            subtitleLabel.font = .systemFont(ofSize: 12, weight: .bold)
            addArrangedSubview(subtitleLabel)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    
    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") { cString.removeFirst() }
        
        if cString.count != 6 {
            self.init("ff0000") // return red color for wrong hex input
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

extension UIButton {
    func setAllStateImage(_ img:UIImage?) {
        self.setImage(img,for: .normal)
        self.setImage(img,for: .highlighted)
        self.setImage(img,for: .focused)
    }
}

extension Encodable {

    /// Encode into JSON and return `Data`
    func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}
