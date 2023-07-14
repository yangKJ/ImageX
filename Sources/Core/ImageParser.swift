//
//  ImageParser.swift
//  ImageX
//
//  Created by Condy on 2023/2/28.
//

import Foundation

struct ImageParser {
    enum JPEGHeaderSegment {
        case nextSegment
        case sofSegment
        case skipSegment
        case parseSegment
        case eoiSegment
    }
    
    struct UInt16Size {
        var width: UInt16 = 0
        var height: UInt16 = 0
    }
    
    struct UInt32Size {
        var width: UInt32 = 0
        var height: UInt32 = 0
    }
    
    static func parse(_ data: Data, offset: Int, segment: JPEGHeaderSegment) -> CGSize {
        var tuple: JPEGParseResult = .tuple((data, offset: offset, segment: segment))
        while true {
            switch tuple {
            case .size(let size):
                return size
            case .tuple(let newTuple):
                tuple = parse(jpeg: newTuple)
            }
        }
    }
}

extension ImageParser {
    
    private enum JPEGParseResult {
        case size(CGSize)
        case tuple((data: Data, offset: Int, segment: JPEGHeaderSegment))
    }
    
    private static func parse(jpeg tuple: (data: Data, offset: Int, segment: JPEGHeaderSegment)) -> JPEGParseResult {
        let data = tuple.data
        let offset = tuple.offset
        let segment = tuple.segment
        if segment == .eoiSegment ||
            (data.count <= offset + 1) ||
            (data.count <= offset + 2) && segment == .skipSegment ||
            (data.count <= offset + 7) && segment == .parseSegment {
            return .size(CGSize.zero)
        }
        switch segment {
        case .nextSegment:
            let newOffset = offset + 1
            var byte = 0x0
            (data as NSData).getBytes(&byte, range: NSRange(location: newOffset, length: 1))
            if byte == 0xFF {
                return .tuple((data, offset: newOffset, segment: .sofSegment))
            } else {
                return .tuple((data, offset: newOffset, segment: .nextSegment))
            }
        case .sofSegment:
            let newOffset = offset + 1
            var byte = 0x0
            (data as NSData).getBytes(&byte, range: NSRange(location: newOffset, length: 1))
            switch byte {
            case 0xE0...0xEF:
                return .tuple((data, offset: newOffset, segment: .skipSegment))
            case 0xC0...0xC3, 0xC5...0xC7, 0xC9...0xCB, 0xCD...0xCF:
                return .tuple((data, offset: newOffset, segment: .parseSegment))
            case 0xFF:
                return .tuple((data, offset: newOffset, segment: .sofSegment))
            case 0xD9:
                return .tuple((data, offset: newOffset, segment: .eoiSegment))
            default:
                return .tuple((data, offset: newOffset, segment: .skipSegment))
            }
        case .skipSegment:
            var length = UInt16(0)
            (data as NSData).getBytes(&length, range: NSRange(location: offset + 1, length: 2))
            let newOffset = offset + Int(CFSwapInt16(length)) - 1
            return .tuple((data, offset: Int(newOffset), segment: .nextSegment))
        case .parseSegment:
            var size = UInt16Size()
            (data as NSData).getBytes(&size, range: NSRange(location: offset + 4, length: 4))
            return .size(CGSize(width: Int(CFSwapInt16(size.width)), height: Int(CFSwapInt16(size.height))))
        default:
            return .size(CGSize.zero)
        }
    }
}
