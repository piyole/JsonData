//
//  JsonData.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum JsonData {

    case String(Path, Swift.String)
    case Number(Path, NSNumber)
    case Array(Path, [JsonData])
    case Object(Path, [Swift.String : JsonData])
    case Bool(Path, Swift.Bool)
    case Error(ErrorInfos)

}

// MARK: - Property

extension JsonData {

    public var isValid: Swift.Bool {
        switch self {
        case .Error:
            return false
        default:
            return true
        }
    }

}

// MARK: - Parse

public extension JsonData {
    static public func parse(data: NSData, options: NSJSONReadingOptions = []) -> JsonData {
        do {
            return JsonData.of(Path.root(), object: try NSJSONSerialization.JSONObjectWithData(data, options: options))
        } catch let error {
            if let string = Swift.String(data: data, encoding: NSUTF8StringEncoding) {
                return parseErrorOnRootPath(string)
            }
            return parseErrorOnRootPath("\(error)")
        }
    }
    static public func parse(string: Swift.String) -> JsonData {
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            return parse(data)
        }
        return parseErrorOnRootPath(string)
    }

    static private func parseErrorOnRootPath(error: Swift.String) -> JsonData {
        return JsonData.error(Path.root(), error: .ParseError(error))
    }
}

// MARK: - Subscription

extension JsonData {

    public subscript(keys: Subscriptable...) -> JsonData {
        return self[keys]
    }
    
    public subscript(keys: [Subscriptable]) -> JsonData {
        return keys.reduce(self) { $0[key: $1] }
    }

    private subscript(key key: Subscriptable) -> JsonData {
        switch (self, key.subscriptType) {
        case (.Array(_, let array), .Index(let index)):
            if index >= 0 && index < array.count {
                return array[index]
            } else {
                return compound(key, error: .IndexOutOfBoundsError(0 ..< array.count, index))
            }
        case (.Object(_, let object), .Key(let key)):
            if let value = object[key] {
                return value
            } else {
                return compound(key, error: .UnknownKeyError(key))
            }
        default:
            break
        }
        return compound(key, error: .InvalidSubscriptError(type, key))
    }

}

// MARK: - Creation

private extension JsonData {

    static private func of(path: Path, object: AnyObject) -> JsonData {
        switch object {
        case let value as NSNumber where JsonData.isBool(value):
            return .Bool(path, value.boolValue)
        case let value as NSNumber:
            return .Number(path, value)
        case let value as Swift.String:
            return .String(path, value)
        case let value as [AnyObject]:
            return .Array(path, value.enumerate().map { of(path.appendingPath($0), object: $1)})
        case let value as [Swift.String : AnyObject]:
            return .Object(path, dictionaryMap(value, map: { of(path.appendingPath($0), object: $1) }))
        default:
            return error(path, error: .UnsupportedTypeError(object.description))
        }
    }
}

// MARK: - Internal/Private Property

private extension JsonData {
    private static let `true` = NSNumber(bool: true)
    private static let `false` = NSNumber(bool: false)
    private static let objCTypeTrue = Swift.String.fromCString(`true`.objCType)
    private static let objCTypeFalse = Swift.String.fromCString(`false`.objCType)

    private static func isBool(number: NSNumber) -> Swift.Bool {
        let objCType = Swift.String.fromCString(number.objCType)
        if (number.compare(`true`) == NSComparisonResult.OrderedSame && objCType == objCTypeTrue)
            || (number.compare(`false`) == NSComparisonResult.OrderedSame && objCType == objCTypeFalse){
                return true
        } else {
            return false
        }
    }
}

extension JsonData {

    internal var type: Swift.String {
        switch self {
        case .String:
            return "String"
        case .Number:
            return "Number"
        case .Array:
            return "Array"
        case .Object:
            return "Object"
        case .Bool:
            return "Bool"
        case .Error:
            return "Error"
        }
    }

    internal var path: Path {
        switch self {
        case .String(let path, _):
            return path
        case .Number(let path, _):
            return path
        case .Array(let path, _):
            return path
        case .Object(let path, _):
            return path
        case .Bool(let path, _):
            return path
        case .Error(let errorInfos):
            return errorInfos.path
        }
    }

    internal var errorInfos: ErrorInfos? {
        switch self {
        case .Error(let errorInfos):
            return errorInfos
        default:
            return nil
        }
    }

}

extension JsonData {

    private static func error(path: Path, error: JsonErrorType) -> JsonData {
        return .Error(ErrorInfos.of(path, error: error))
    }

    private func compound(key: Subscriptable, error: JsonErrorType) -> JsonData {
        switch self {
        case .Error(let errorInfos):
            return .Error(errorInfos.compound(key, error: error))
        default:
            return JsonData.error(path.appendingPath(key), error: error)
        }
    }

}

extension JsonData : CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .String(let path, let string):
            return "\(path) : String(\"\(string)\")"
        case .Number(let path, let number):
            return "\(path) : Number(\(number))"
        case .Array(let path, let array):
            return "\(path) : Array(\(array.count))\n" + array.enumerate().map { "\($0).\($1)\n" }.joinWithSeparator("")
        case .Object(let path, let object):
            return "\(path) : Object(\(object.count))\n" + object.reduce("", combine: { $0 + "\n\($1.0) : \($1.1.description)" })
        case .Bool(let path, let bool):
            return "\(path) : Bool(\(bool))"
        case .Error(let errorInfos):
            return errorInfos.description
        }

    }
}