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
