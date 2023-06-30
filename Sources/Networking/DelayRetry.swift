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
    
    /// Represents the interval mechanism which used in a `DelayRetryStrategy`.
    public enum Interval {
        /// The next retry attempt should happen in fixed seconds. For example, if the associated value is 3, the
        /// attempts happens after 3 seconds after the previous decision is made.
        case seconds(TimeInterval)
        /// The next retry attempt should happen in an accumulated duration. For example, if the associated value is 3,
        /// the attempts happens with interval of 3, 6, 9, 12, ... seconds.
        case accumulated(TimeInterval)
        /// Uses a block to determine the next interval. The current retry count is given as a parameter.
        case custom(block: (_ retriedCount: Int) -> TimeInterval)
    }
    
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

extension DelayRetry.Interval {
    
    func timeInterval(for retriedCount: Int) -> TimeInterval {
        let retryAfter: TimeInterval
        switch self {
        case .seconds(let interval):
            retryAfter = interval
        case .accumulated(let interval):
            retryAfter = Double(retriedCount + 1) * interval
        case .custom(let block):
            retryAfter = block(retriedCount)
        }
        return retryAfter
    }
}