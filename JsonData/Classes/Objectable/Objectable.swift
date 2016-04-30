//
//  Objectable.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public protocol Objectable {
    associatedtype ObjectType = Self
    static func boxing(json: JsonData) -> Box<ObjectType>
}

extension String : Objectable {
    public static func boxing(json: JsonData) -> Box<String> {
        switch json {
        case .String(_, let string):
            return .Boxing(string)
        default:
            return .invalidTypeError("String", json: json)
        }
    }
}

extension Int : Objectable {
    public static func boxing(json: JsonData) -> Box<Int> {
        switch json {
        case .Number(_, let number):
            return .Boxing(number as Int)
        default:
            return .invalidTypeError("Int", json: json)
        }
    }
}

extension Int64 : Objectable {
    public static func boxing(json: JsonData) -> Box<Int64> {
        switch json {
        case .Number(_, let number):
            return .Boxing(number.longLongValue)
        default:
            return .invalidTypeError("Int64", json: json)
        }
    }
}

extension Double : Objectable {
    public static func boxing(json: JsonData) -> Box<Double> {
        switch json {
        case .Number(_, let number):
            return .Boxing(number as Double)
        default:
            return .invalidTypeError("Double", json: json)
        }
    }
}

extension Bool : Objectable {
    public static func boxing(json: JsonData) -> Box<Bool> {
        switch json {
        case .Bool(_, let bool):
            return .Boxing(bool)
        default:
            return .invalidTypeError("Bool", json: json)
        }
    }
}

extension Optional where Wrapped: Objectable, Wrapped == Wrapped.ObjectType {
    public static func boxing(json: JsonData) -> Box<Optional<Wrapped>> {
        return Wrapped.boxing(json).map { .Some($0) }
    }
}

extension CollectionType where Generator.Element: Objectable, Generator.Element == Generator.Element.ObjectType {
    public static func boxing(json: JsonData) -> Box<[Generator.Element]> {
        switch json {
        case .Array(_, let array):
            return map(array.map(Generator.Element.boxing))
        default:
            return .invalidTypeError("Array", json: json)
        }
    }
    private static func map<T>(array: [Box<T>]) -> Box<[T]> {
        let plus: [T] -> [T] -> [T] = { a in { b in a + b } }
        return array.reduce(.Boxing([])) { $1.map { [$0] }.map($0.map(plus)) }
    }
}

extension DictionaryLiteralConvertible where Value: Objectable, Value == Value.ObjectType {
    public static func boxing(json: JsonData) -> Box<[String : Value]> {
        switch json {
        case .Object(_, let object):
            return map(dictionaryMap(object, map: { Value.boxing($1) } ))
        default:
            return .invalidTypeError("Object", json: json)
        }
    }
    private static func map<T>(object: [String : Box<T>]) -> Box<[String : T]> {
        let join: [String : T] -> [String : T] -> [String : T] = {
            var a = $0
            return { b in
                for (key, value) in b {
                    a[key] = value
                }
                return a
            }
        }
        return object.reduce(.Boxing([:])) { merge, entry in entry.1.map { [entry.0 : $0] }.map(merge.map(join))}
    }
}

extension NSDate : Objectable {
    public static func boxing(json: JsonData) -> Box<NSDate> {
        switch json {
        case .String(_, let string):
            if let date = parse(string) {
                return .Boxing(date)
            }
            return .unsupportedFormatError(string, json: json)
        default:
            return .invalidTypeError("String", json: json)
        }
    }
    private static func parse(string: String) -> NSDate? {
        // Supported Format
        //   (23)yyyy/MM/dd HH:mm:ss.SSS
        //   (19)yyyy/MM/dd HH:mm:ss
        //   (10)yyyy/MM/dd
        //
        //   (23)yyyy-MM-dd HH:mm:ss.SSS
        //   (19)yyyy-MM-dd HH:mm:ss
        //   (10)yyyy-MM-dd
        //
        //   ( 8)yyyyMMdd
        //   ( 8)HH:mm:ss
        let length = string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if let format = infer(string, length: length) {
            let formatter = NSDateFormatter()
            formatter.dateFormat = format
            return formatter.dateFromString(string)
        }
        return nil
    }

    private static func infer(string: String, length: Int) -> String? {
        switch (string, length) {
        case (let s, 23) where contains(s, chars: ["/", " ", ":", "."]):
            return "yyyy/MM/dd HH:mm:ss.SSS"
        default:
            return nil
        }
    }

    private static func contains(target: String, chars: [String], any: Bool = false) -> Bool {
        let matches = chars.filter { target.containsString($0) }
        return any ? !matches.isEmpty : matches.count == chars.count
    }
}