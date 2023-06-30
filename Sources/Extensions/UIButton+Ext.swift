//
//  UIButton+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/6/29.
//

import Foundation
import Harbeth

#if canImport(UIKit) && !os(watchOS)
import UIKit

extension UIButton: AsAnimatable, UIButtonContainer, C7Compatible { }

extension Queen where Base: UIButton {
    
    /// Sets an image or gif to the button for a specified state with a named, And add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - state: The button state to which the image or gif should be set.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setImage(
        with named: String?,
        for state: UIControl.State,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) {
        let other = AnimatedOthers(key: AnimatedOthers.ButtonKey.image.rawValue, value: state)
        HandyImage.displayImage(source: named, to: base, filters: filters, options: options, other: other)
    }
    
    /// Sets an image or gif to the button for a specified state with a data, And add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - state: The button state to which the image or gif should be set.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setImage(
        with data: Data?,
        for state: UIControl.State,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> AssetType {
        let other = AnimatedOthers(key: AnimatedOthers.ButtonKey.image.rawValue, value: state)
        return HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: other)
    }
    
    /// Sets an image or gif to the button for a specified state with a url, And add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - state: The button state to which the image or gif should be set.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    ///   - failed: Network failure callback.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setImage(
        with url: URL?,
        for state: UIControl.State,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> URLSessionDataTask? {
        let other = AnimatedOthers(key: AnimatedOthers.ButtonKey.image.rawValue, value: state)
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: other)
    }
    
    /// Sets an image or gif to the button for a specified state with a named, And add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - state: The button state to which the image or gif should be set.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setBackgroundImage(
        with named: String?,
        for state: UIControl.State,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) {
        let other = AnimatedOthers(key: AnimatedOthers.ButtonKey.backgroundImage.rawValue, value: state)
        HandyImage.displayImage(source: named, to: base, filters: filters, options: options, other: other)
    }
    
    /// Sets an image or gif to the button for a specified state with a data, And add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - state: The button state to which the image or gif should be set.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setBackgroundImage(
        with data: Data?,
        for state: UIControl.State,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> AssetType {
        let other = AnimatedOthers(key: AnimatedOthers.ButtonKey.backgroundImage.rawValue, value: state)
        return HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: other)
    }
    
    /// Sets an image or gif to the button for a specified state with a url, And add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - state: The button state to which the image or gif should be set.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    ///   - failed: Network failure callback.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setBackgroundImage(
        with url: URL?,
        for state: UIControl.State,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> URLSessionDataTask? {
        let other = AnimatedOthers(key: AnimatedOthers.ButtonKey.backgroundImage.rawValue, value: state)
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: other)
    }
}

#endif
