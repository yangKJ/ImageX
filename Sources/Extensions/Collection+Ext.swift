//
//  Collection+Ext.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/5.
//

import Foundation

extension Collection {
    /// Safe protects the array from out of bounds by use of optional.
    ///
    ///        let arr = [1, 2, 3, 4, 5]
    ///        arr[safe: 1] -> 2
    ///        arr[safe: 10] -> nil
    ///
    /// - Parameter index: index of element to access element.
    subscript(safe index: Index) -> Element? {
        //return indices ~= index ? self[index] : nil
        return indices.contains(index) ? self[index] : nil
    }
}
