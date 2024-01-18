//
//  PreCacheHandler.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2023/4/27.
//

import Foundation

class PreCacheHandler{
    
    static let shared = PreCacheHandler()
    
    private var cacheUrls: [URL] = []
    private var running = false;
    private init(){}
    
    func cache(urls:[URL], concurrent: Bool = true){
        if(concurrent) {
            for url in urls {
                downloadCache(url: url)
            }
        } else {
            cacheUrls.append(contentsOf: urls)
            if(!running) {
                run()
            }
        }
    }
    
    func cancelCache(urls:[URL]) {
        for url in urls {
            guard let ind = cacheUrls.firstIndex(where: {$0.relativeString == url.relativeString}) else {
                print("cancel \(url.absoluteString) failed because already cached or not existed.")
                return
            }
            cacheUrls.remove(at: ind)
            print("cancel \(url.absoluteString) success.")
        }
    }
    
    private func run() {
        running = true
        while (!cacheUrls.isEmpty) {
            let url = cacheUrls.removeFirst()
            download(url: url)
        }
        running = false
    }
    
    private func download(url:URL) {
        let semaphore = DispatchSemaphore(value: 0)
        downloadCache(url: url) { (res: Bool) in
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        
    }
}
