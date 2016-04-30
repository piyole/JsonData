//
//  Box.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum Box<T> {
    case Boxing(T)
    case Error(ErrorInfos)
}

extension Box {

    public var item: T? {
        switch self {
        case .Boxing(let item):
            return item
        default:
            return nil
        }
    }

    public var errorInfos: ErrorInfos? {
        switch self {
        case .Error(let errorInfos):
            return errorInfos
        default:
            return nil
        }
    }

}

extension Box {
    public func map<U>(f: T -> U) -> Box<U> {
        switch self {
        case .Boxing(let value):
            return .Boxing(f(value))
        case .Error(let errors):
            return .Error(errors)
        }
    }
    public func flatMap<U>(f: T -> Box<U>) -> Box<U> {
        switch self {
        case .Boxing(let value):
            return f(value)
        case .Error(let errors):
            return .Error(errors)
        }
    }
    internal func map<U>(f: Box<T -> U>) -> Box<U> {
        switch (self, f) {
        case (.Boxing, .Boxing(let function)):
            return map(function)
        case (.Error(let errorInfos), let any):
            return .Error(any.errorInfos == nil ? errorInfos : errorInfos.compound(any.errorInfos!))
        case (let any, .Error(let errorInfos)):
            return .Error(any.errorInfos == nil ? errorInfos : any.errorInfos!.compound(errorInfos))
        default:
            fatalError()
        }
    }
}

extension Box {

    private static func error(error: BoxingErrorType) -> Box<T> {
        return .Error(ErrorInfos.of(Path.root(), error: error))
    }

    private static func compound(json: JsonData, error: BoxingErrorType) -> Box<T> {
        let path = json.path.appendingPath("[->]")
        switch json {
        case .Error(let errorInfos):
            return .Error(errorInfos.compound(path, error: error))
        default:
            return .Error(ErrorInfos.of(path, error: error))
        }
    }

    public static func invalidTypeError(expected: String, json: JsonData) -> Box<T> {
        return compound(json, error: .InvalidTypeError(expected, json.type))
    }

    public static func unsupportedFormatError(format: String, json: JsonData) -> Box<T> {
        return compound(json, error: .UnsupportedFormatError(format))
    }

    public static func cannotConvertError(type: String, value: String) -> Box<T> {
        return error(.CannotConvertError(type, value))
    }

    public static func unknownError(message: String) -> Box<T> {
        return error(.UnknownError(message))
    }

}

extension Box : CustomStringConvertible {

    public var description: String {
        switch self {
        case .Boxing(let item):
            return "Box(\(item))"
        case .Error(let errorInfos):
            return errorInfos.description
        }
    }

}

