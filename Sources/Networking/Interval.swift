//
//  Interval.swift
//  ImageX
//
//  Created by Condy on 2023/5/20.
//

import Foundation

extension DelayRetry {
    
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
