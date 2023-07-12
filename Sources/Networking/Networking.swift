//
//  Networking.swift
//  ImageX
//
//  Created by Condy on 2023/5/20.
//

import Foundation
import Lemons

struct Networking {
    
    typealias DownloadResultBlock = ((Result<DataResult, Error>) -> Void)
    typealias DownloadProgressBlock = ((_ currentProgress: CGFloat) -> Void)
    
    static let shared = Networking()
    
    private init() { }
    
    @ImageX.Locked var downloaders = [String: DataDownloader]()
    
    @ImageX.Locked var cacheCallBlocks = [(key: String, block: (download: DownloadResultBlock, progress: DownloadProgressBlock?))]()
    
    /// Add network download data task.
    /// - Parameters:
    ///   - url: The link url.
    ///   - progressBlock: Network data task download progress.
    ///   - downloadBlock: Download callback response.
    ///   - retry: Network max retry count and retry interval.
    ///   - timeoutInterval: The timeout interval for the request. Defaults to 20.0
    ///   - interval: Network resource data download progress response interval.
    /// - Returns: The data task.
    @discardableResult func addDownloadURL(_ url: URL,
                                           progressBlock: DownloadProgressBlock? = nil,
                                           downloadBlock: @escaping DownloadResultBlock,
                                           retry: ImageX.DelayRetry = DelayRetry.max3s,
                                           timeoutInterval: TimeInterval = 20,
                                           interval: TimeInterval = 0.02) -> URLSessionDataTask {
        let key = Lemons.CryptoType.md5.encryptedString(with: url.absoluteString)
        self.cacheCallBlocks.append((key, (downloadBlock, progressBlock)))
        if let downloader = self.downloaders[key] {
            return downloader.task
        }
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpShouldUsePipelining = true
        request.cachePolicy = .reloadIgnoringLocalCacheData
        if #available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *) {
            request.allowsConstrainedNetworkAccess = false
        }
        let downloader = DataDownloader(request: request, named: key, retry: retry, interval: interval) {
            for call in cacheCallBlocks where key == call.key {
                switch $0 {
                case .downloading(let currentProgress):
                    let type = AssetType(data: $1)
                    let rest = DataResult(key: key, url: url, data: $1!, response: $2, type: type, downloadStatus: .downloading)
                    call.block.progress?(currentProgress)
                    call.block.download(.success(rest))
                case .complete:
                    let type = AssetType(data: $1)
                    let rest = DataResult(key: key, url: url, data: $1!, response: $2, type: type, downloadStatus: .complete)
                    call.block.progress?(1.0)
                    call.block.download(.success(rest))
                case .failed(let error):
                    call.block.download(.failure(error))
                case .finished(let error):
                    call.block.download(.failure(error))
                }
            }
            switch $0 {
            case .complete, .finished:
                self.removeDownloadURL(with: key)
            case .failed, .downloading:
                break
            }
        }
        self.downloaders[key] = downloader
        return downloader.task
    }
    
    /// Remove the download data task.
    /// - Parameter url: The link url.
    func removeDownloadURL(with url: URL) {
        let key = Lemons.CryptoType.md5.encryptedString(with: url.absoluteString)
        removeDownloadURL(with: key)
    }
    
    /// No other callbacks waiting, we can clear the task now.
    func removeDownloadURL(with key: String) {
        self.downloaders[key]?.cancelTask()
        self.downloaders.removeValue(forKey: key)
        self.cacheCallBlocks.removeAll { $0.key == key }
    }
}
