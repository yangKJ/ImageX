//
//  DataTask.swift
//  ImageX
//
//  Created by Condy on 2023/6/27.
//

import Foundation

final class DataTask {
    
    private(set) var task: URLSessionDataTask!
    
    private(set) var retry: DelayRetry
    
    let request: URLRequest
    
    let completionHandler: Networking.DownloadBlock
    
    init(request: URLRequest, retry: DelayRetry, completionHandler: @escaping Networking.DownloadBlock) {
        self.retry = retry
        self.completionHandler = completionHandler
        self.request = request
        self.setupDataTask()
    }
    
    func setupDataTask() {
        self.task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.result(data: data, response: response, error: error)
        }
        self.task.resume()
        self.retry.increaseRetryCount()
    }
    
    func cancelTask() {
        self.task.cancel()
    }
}

extension DataTask {
    
    private func result(data: Data?, response: URLResponse?, error: Error?) {
        switch (data, error) {
        case (.none, let error):
            self.retry.retry(task: task) { state in
                switch state {
                case .retring:
                    self.setupDataTask()
                case .stop:
                    self.completionHandler(data, response, error)
                }
            }
        case (let data?, _):
            self.completionHandler(data, response, error)
        }
    }
}
