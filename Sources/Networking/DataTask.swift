//
//  DataTask.swift
//  ImageX
//
//  Created by Condy on 2023/6/27.
//

import Foundation

final class DataTask {
    
    private(set) var task: URLSessionDataTask!
    
    private(set) var session: URLSession?
    
    private(set) var retry: DelayRetry
    
    private(set) var request: URLRequest
    
    /// Downloaded raw data of current task.
    lazy private(set) var mutableData: Data = Data()
    
    lazy private(set) var queue: OperationQueue = OperationQueue()
    
    lazy private(set) var sessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.networkServiceType = .default
        return configuration
    }()
    
    let completionHandler: Networking.DownloadBlock
    
    init(request: URLRequest, retry: DelayRetry, completionHandler: @escaping Networking.DownloadBlock) {
        self.retry = retry
        self.completionHandler = completionHandler
        self.request = request
        //super.init()
        //self.setupRequest()
        self.setupDataTask()
    }
    
    deinit {
        session?.invalidateAndCancel()
    }
    
//    func setupRequest() {
//        request.httpShouldUsePipelining = true
//        request.cachePolicy = .reloadIgnoringLocalCacheData
//        request.allHTTPHeaderFields = ["image/webp,image/*;q=0.8": "Accept"]
//    }
    
    func setupDataTask() {
//        self.session?.invalidateAndCancel()
//        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: queue)
//        self.task = session?.dataTask(with: request)
        self.task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
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
            self.retry.retry(task: task) { [weak self] state in
                switch state {
                case .retring:
                    self?.setupDataTask()
                case .stop:
                    self?.completionHandler(data, response, error)
                }
            }
        case (let data?, _):
            self.completionHandler(data, response, error)
        }
    }
    
    private func didReceiveData(data: Data) {
        
    }
}

//extension DataTask: URLSessionDataDelegate {
//
//    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
//        guard let _ = response as? HTTPURLResponse else {
//            completionHandler(.cancel)
//            return
//        }
//        //let httpStatusCode = httpResponse.statusCode
//        completionHandler(.allow)
//    }
//
//    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        guard dataTask == task else {
//            return
//        }
//        didReceiveData(data: data)
//    }
//
//    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        result(data: nil, response: nil, error: error)
//    }
//}
