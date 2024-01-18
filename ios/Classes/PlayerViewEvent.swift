//
//  PlayerView+Event.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2022/9/7.
//

import Foundation


protocol PlayerViewDelegate: AnyObject {
    func onBack()
    func showToast(message:String, type:ToastType)
    func onRateChange(rate:Float)
    func onPlaying(event:PlayingEvent)
    func onUrlRequested(url:String)
}

