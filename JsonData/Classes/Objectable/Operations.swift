//
//  Operations.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

infix operator <^> { associativity left precedence 130}
infix operator <*> { associativity left precedence 130}

infix operator <| { associativity left  precedence 150 }
infix operator <|? { associativity left  precedence 150 }
infix operator <|| { associativity left  precedence 150 }
infix operator <||? { associativity left  precedence 150 }

infix operator >>> { associativity left  precedence 140 }
infix operator &&& { associativity left  precedence 140 }

public func <^> <T, U>(f: T -> U, x: Box<T>) -> Box<U> {
    return x.map(f)
}

public func <*> <T, U>(f: Box<T -> U>, x: Box<T>) -> Box<U> {
    return x.map(f)
}

public func <| <T where T : Objectable, T == T.ObjectType>(json: JsonData, key: Subscriptable) -> Box<T> {
    return json <| [key]
}

public func <| <T where T : Objectable, T == T.ObjectType>(json: JsonData, keys: [Subscriptable]) -> Box<T> {
    return T.boxing(json[keys])
}

public func <|? <T where T : Objectable, T == T.ObjectType>(json: JsonData, key: Subscriptable) -> Box<T?> {
    return json <|? [key]
}

public func <|? <T where T : Objectable, T == T.ObjectType>(json: JsonData, keys: [Subscriptable]) -> Box<T?> {
    return ignoreUnknownKey(json, keys: keys, f: T.boxing)
}

public func <|| <T where T : Objectable, T == T.ObjectType>(json: JsonData, key: Subscriptable) -> Box<[T]> {
    return json <|| [key]
}

public func <|| <T where T : Objectable, T == T.ObjectType>(json: JsonData, keys: [Subscriptable]) -> Box<[T]> {
    return Array<T>.boxing(json[keys])
}

public func <|? <T where T : Objectable, T == T.ObjectType>(json: JsonData, key: Subscriptable) -> Box<[T]?> {
    return json <|? [key]
}

public func <|? <T where T : Objectable, T == T.ObjectType>(json: JsonData, keys: [Subscriptable]) -> Box<[T]?> {
    return ignoreUnknownKey(json, keys: keys, f: Array<T>.boxing)
}

public func ?? <T>(box: Box<T?>, @autoclosure f: () -> T) -> Box<T> {
    switch box {
    case .Boxing(let item):
        return .Boxing(item ?? f())
    case .Error:
        return .Boxing(f())
    }
}

public func >>> <T, U>(box: Box<T>, map: (T) -> U?) -> Box<U> {
    switch box {
    case .Boxing(let item):
        if let t = map(item) {
            return .Boxing(t)
        }
        return .cannotConvertError("\(U.self)", value: "\(item)")
    case .Error(let errorInfos):
        return .Error(errorInfos)
    }
}

public func >>> <T, U>(box: Box<T>, convert: (T) -> Converting<U>) -> Box<U> {
    switch box {
    case .Boxing(let item):
        switch convert(item) {
        case .Converted(let converted):
            return .Boxing(converted)
        case .CannotConvert(let error):
            return .unknownError(error)
        }
    case .Error(let errorInfos):
        return .Error(errorInfos)
    }
}

public func &&& <T>(box: Box<T>, check: (T) -> Checking) -> Box<T> {
    switch box {
    case .Boxing(let item):
        switch check(item) {
        case .Valid:
            return box
        case .Invalid(let error):
            return .unknownError(error)
        }
    case .Error:
        return box
    }
}


private func ignoreUnknownKey<T>(json: JsonData, keys: [Subscriptable], f: (JsonData) -> Box<T>) -> Box<T?> {
    let j = json[keys]
    switch j {
    case .Error(let errorInfos):
        switch errorInfos.error {
        case JsonErrorType.UnknownKeyError:
            return .Boxing(.None)
        default:
            return .Error(errorInfos)
        }
    default:
        break
    }
    return f(j).map { .Some($0) }
}
