//
//  Networking.swift
//  ImageX
//
//  Created by Condy on 2023/5/20.
//

import Foundation
import Lemons

public struct Networking {
    
    public typealias Key = String
    public typealias DownloadBlock = ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)
    
    public static let shared = Networking()
    
    /// The timeout interval for the request. Defaults to 20.0
    public var timeoutInterval: TimeInterval = 20
    
    private init() { }
    
    @Locked var dataTasks = [Networking.Key: DataTask]()
    
    @Locked var cacheBlocks = [(key: Networking.Key, block: Networking.DownloadBlock)]()
    
    /// Add network download data task.
    /// - Parameters:
    ///   - url: The link url.
    ///   - retry: Specified max retry count and a certain interval mechanism.
    ///   - block: Download callback response.
    /// - Returns: The data task.
    @discardableResult public func addDownloadURL(_ url: URL, retry: DelayRetry = .default, block: @escaping DownloadBlock) -> URLSessionDataTask {
        let key = Lemons.CryptoType.md5.encryptedString(with: url.absoluteString)
        self.cacheBlocks.append((key, block))
        if let dataTask = self.dataTasks[key] {
            return dataTask.task
        }
        let request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        let dataTask = DataTask(request: request, retry: retry) { data, response, error in
            self.dataTasks.removeValue(forKey: key)
            self.cacheBlocks.forEach {
                $0.key == key ? $0.block(data, response, error) : nil
            }
            self.cacheBlocks.removeAll { $0.key == key }
        }
        self.dataTasks[key] = dataTask
        return dataTask.task
    }
    
    /// Remove the download data task.
    /// - Parameter url: The link url.
    public func removeDownloadURL(with url: URL) {
        let key = Lemons.CryptoType.md5.encryptedString(with: url.absoluteString)
        self.dataTasks[key]?.cancelTask()
        self.dataTasks.removeValue(forKey: key)
        self.cacheBlocks.removeAll { $0.key == key }
    }
}
