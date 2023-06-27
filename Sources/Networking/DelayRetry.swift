//
//  DelayRetry.swift
//  ImageX
//
//  Created by Condy on 2023/5/20.
//

import Foundation

// See: https://github.com/onevcat/Kingfisher/blob/master/Sources/Networking/RetryStrategy.swift

/// Specified max retry count and a certain interval mechanism.
public struct DelayRetry {
    
    public static let `default` = DelayRetry.init(maxRetryCount: 3, retryInterval: .seconds(3))
    
    /// The max retry count defined for the retry strategy
    public let maxRetryCount: Int
    
    /// The retry interval mechanism defined for the retry strategy.
    public let retryInterval: Interval
    
    /// Creates a delay retry strategy.
    /// - Parameters:
    ///   - maxRetryCount: The max retry count.
    ///   - retryInterval: The retry interval mechanism. By default, `.seconds(3)` is used to provide a constant retry interval.
    public init(maxRetryCount: Int, retryInterval: Interval = .seconds(3)) {
        self.maxRetryCount = maxRetryCount
        self.retryInterval = retryInterval
    }
    
    /// The retried count before current retry happens. This value is `0` if the current retry is for the first time.
    private var retriedCount: Int = 0
    
    mutating func increaseRetryCount() {
        retriedCount += 1
    }
    
    enum RetryDecision { case retring, stop }
    
    func retry(task: URLSessionDataTask, retryHandler: @escaping (RetryDecision) -> Void) {
        // Retry count exceeded.
        if retriedCount >= maxRetryCount {
            retryHandler(.stop)
        }
        
        // User cancel the task. No retry.
        if task.state == .canceling {
            retryHandler(.stop)
        }
        
        let interval = retryInterval.timeInterval(for: retriedCount)
        if interval == 0 {
            retryHandler(.retring)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                retryHandler(.retring)
            }
        }
    }
}
