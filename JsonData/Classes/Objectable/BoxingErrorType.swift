//
//  BoxingErrorType.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum BoxingErrorType : ErrorType {

    case InvalidTypeError(String, String)
    case UnsupportedFormatError(String)
    case CannotConvertError(String, String)
    case UnknownError(String)
    
}

extension BoxingErrorType {
    public var description: String {
        switch self {
        case .InvalidTypeError(let expected, let actual):
            return "expected type(\(expected)) is not match actual type(\(actual))."
        case .UnsupportedFormatError(let value):
            return "unsupported format(\(value))."
        case .CannotConvertError(let type, let value):
            return "cannot convert \"\(value)\" to \(type)."
        case .UnknownError(let error):
            return "unknown error(\(error))."
        }
    }
}
