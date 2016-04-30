//
//  JsonErrorType.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum JsonErrorType : ErrorType {

    case ParseError(String)
    case UnsupportedTypeError(String)

    case UnknownKeyError(String)
    case IndexOutOfBoundsError(Range<Int>, Int)
    case InvalidSubscriptError(String, Subscriptable)

}

extension JsonErrorType : CustomStringConvertible {
    public var description: String {
        switch self {
        case .ParseError(let string):
            return "cannot parse to json data. [\(string)]"
        case .UnsupportedTypeError(let type):
            return "unsupported type(\(type))."
        case .InvalidSubscriptError(let type, let subscriptable):
            return "\(type) is not support subscript(\(subscriptable.subscriptType))."
        case .UnknownKeyError(let key):
            return "unknown key[\(key)]."
        case .IndexOutOfBoundsError(let range, let index):
            return "index[\(index)] is out of bounds[\(range)]."
        }
    }
}

