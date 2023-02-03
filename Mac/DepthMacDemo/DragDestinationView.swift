//
//  DragDestinationView.swift
//  DepthMacDemo
//
//  Created by Condy on 2023/1/12.
//

import Cocoa

@objc protocol DragDestinationViewDelegate: NSObjectProtocol {
    
    @objc optional func processImage(_ image: NSImage, pasteBoard: NSPasteboard)
    
    @objc optional func process(_ obj: Any, pasteBoard: NSPasteboard)
}

/// 拖拽目标视图
@available(macOS 10.13, *)
class DragDestinationView: NSView {
    
    var delegate: DragDestinationViewDelegate?
    
    /// 支持拖入的类型
    var supportedTypes: [NSPasteboard.PasteboardType] = [.tiff, .color, .string, .fileURL, .html]{
        willSet{
            self.registerForDraggedTypes(newValue)
        }
    }
    
    /// 支持拖入的子类型
    var acceptableUTITypes: [NSPasteboard.ReadingOptionKey : Any] {
        let types = [
            NSImage.imageTypes,
            NSString.readableTypeIdentifiersForItemProvider,
            NSURL.readableTypeIdentifiersForItemProvider
        ].flatMap { $0 }
        return [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes : types]
    }
    
    var isReceivingDrag = false {
        didSet {
            needsDisplay = true
        }
    }
    
    // MARK: - lifecycle
    convenience init(types: [NSPasteboard.PasteboardType]) {
        self.init()
        self.registerForDraggedTypes(types)
    }
    
    // MARK: - drag
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true
    }
    
    // 仅支持 image 可用此方法
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        let pasteBoard = sender.draggingPasteboard
        guard let image = NSImage(pasteboard: pasteBoard) else {
            return false
        }
        delegate?.processImage?(image, pasteBoard: pasteBoard)
        return true
    }
    
    //    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    //        isReceivingDrag = false
    //        let pasteBoard = sender.draggingPasteboard
    //        let classArray: [AnyClass] = [NSImage.self, NSColor.self, NSString.self, NSURL.self]
    //        return (pasteBoard.readObjects(forClasses: classArray, options: acceptableUTITypes) { (obj) in
    //            if let value = obj as? NSImage {
    //                self.delegate?.processImage?(value, pasteBoard: pasteBoard)
    //            } else {
    //                self.delegate?.process?(obj, pasteBoard: pasteBoard)
    //            }
    //        } != nil)
    //    }
    
    override func concludeDragOperation(_ sender: NSDraggingInfo?) {
        
    }
}
