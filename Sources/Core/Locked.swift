//
//  Locked.swift
//  Wintersweet
//
//  Created by Condy on 2023/3/7.
//

import Foundation

/// Define an atomic property decorator through Property Wrappers.
@propertyWrapper public struct Locked<Value> {
    
    private var raw: Value
    private let lock = NSLock()
    
    public init(wrappedValue value: Value) {
        self.raw = value
    }
    
    public var wrappedValue: Value {
        get { return load() }
        set { store(newValue: newValue) }
    }
    
    private func load() -> Value {
        lock.lock()
        defer { lock.unlock() }
        return raw
    }
    
    private mutating func store(newValue: Value) {
        lock.lock()
        defer { lock.unlock() }
        raw = newValue
    }
    
    private mutating func withValue(_ closure: (Value) -> Value) {
        lock.lock()
        defer { lock.unlock() }
        raw = closure(raw)
    }
}

extension Locked: CustomStringConvertible {
    public var description: String {
        return "\(wrappedValue)"
    }
}

extension Locked where Value: Equatable {
    public static func == (left: Locked, right: Value) -> Bool {
        return left.wrappedValue == right
    }
}

extension Locked where Value: Comparable {
    public static func < (left: Locked, right: Value) -> Bool {
        return left.wrappedValue < right
    }
    
    public static func > (left: Locked, right: Value) -> Bool {
        return left.wrappedValue > right
    }
}
