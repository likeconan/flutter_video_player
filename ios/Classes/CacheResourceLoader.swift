//
//  CacheResourceLoader.swift
//  video_player_oneplusdream
//
//  Created by Conan on 2023/4/13.
//

import Foundation
import AVFoundation

class CacheResourceLoaderDelegate: NSObject, AVAssetResourceLoaderDelegate, URLSessionDataDelegate, URLSessionTaskDelegate {
    
    private static let SchemeSuffix = "-cacheloader"
    let sessionConfig = URLSessionConfiguration.default
    lazy var session:URLSession = {
        return URLSession(configuration: sessionConfig)
    }()
    lazy var streamingAssetURL: URL = {
        guard var components = URLComponents(url: self.url, resolvingAgainstBaseURL: false) else {
            fatalError()
        }
        components.scheme = (components.scheme ?? "") + CacheResourceLoaderDelegate.SchemeSuffix
        guard let retURL = components.url else {
            fatalError()
        }
        return retURL
    }()
    
    // MARK: Private
    
    private let url:            URL
    
    // MARK: - Life Cycle Methods
    
    init(withURL url: URL) {
        self.url = url
        sessionConfig.timeoutIntervalForRequest = 5.0
        super.init()
    }
    
    // MARK: - Public Methods
    
    func invalidate() {
        
    }
    
    // MARK: - AVAssetResourceLoaderDelegate
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let url = loadingRequest.request.url?.absoluteString else {
            return false
        }
        DispatchQueue.global().async {
            let newUrl = url.replacingOccurrences(of: CacheResourceLoaderDelegate.SchemeSuffix, with: "")
            if let url = URL(string: newUrl),
               let data = self.dataRequest(url: url) {
                DispatchQueue.main.async {
                    loadingRequest.redirect = URLRequest(url: url)
                    loadingRequest.response = HTTPURLResponse(url: url, statusCode: 302, httpVersion: nil, headerFields: nil)
                    loadingRequest.dataRequest!.respond(with: data)
                    loadingRequest.finishLoading()
                }
            } else {
                loadingRequest.finishLoading(with:  NSError(domain: NSURLErrorDomain, code: 400, userInfo: nil) as Error)
            }
            
        }
        return true
    }
    private var triedCount = 0;
    
    func innerTask (url:URL, completionHandler: @escaping (Data?) -> ()) {
        let task = session.dataTask(with: url) { d,response,error in
            print("data request called \(self.triedCount)")
            if(d != nil && error == nil) {
                print("finish")
                completionHandler(d)
            } else if(self.triedCount < 5) {
                self.triedCount += 1
                self.innerTask(url: url, completionHandler:completionHandler)
            } else {
                completionHandler(nil)
            }
        }
        task.resume()
    }

    func dataRequest(url:URL) -> Data? {
        let semaphore = DispatchSemaphore(value: 0)
        var data = getMediaDataFromLocalFile(url: url)
        if(data == nil) {
            innerTask(url: url) { d in
                if (d != nil) {
                    data = d;
                    saveMediaDataToLocalFile(data: data!, url: url)
                }
                self.triedCount = 0
                semaphore.signal()
            }
        }else {
            semaphore.signal()
        }
        _ = semaphore.wait(timeout: .distantFuture)
        return data
    }
    
}
