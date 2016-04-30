//
//  Parse.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public func parse<T where T : Objectable, T == T.ObjectType>(string: String) -> Box<T> {
    return T.boxing(JsonData.parse(string))
}

public func parse<T where T : Objectable, T == T.ObjectType>(data: NSData) -> Box<T> {
    return T.boxing(JsonData.parse(data))
}

public func parse<T where T : Objectable, T == T.ObjectType>(string: String) -> T? {
    return T.boxing(JsonData.parse(string)).item
}

public func parse<T where T : Objectable, T == T.ObjectType>(data: NSData) -> T? {
    return T.boxing(JsonData.parse(data)).item
}
