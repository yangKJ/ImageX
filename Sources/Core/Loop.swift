//
//  Loop.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/12.
//

import Foundation

public enum Loop {
    case forever
    case never
    case count(_ count: Int)
}

extension Wintersweet.Loop {
    /// Desired number of loops.
    var count: Int {
        switch self {
        case .forever:
            return 0
        case .never:
            return 1
        case .count(let count):
            assert(count > 0) // disable: this empty_count
            return count
        }
    }
}
