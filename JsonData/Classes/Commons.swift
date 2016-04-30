//
//  Commons.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

internal func dictionaryMap<Key, Value, U where Key : Hashable>(dictionary: [Key : Value], map: (Key, Value) -> U) -> [Key : U] {
    func join(a: [Key : U], b: (Key, U)) -> [Key : U] {
        var c = a
        c[b.0] = b.1
        return c
    }
    return dictionary.reduce([:]) { join($0, b: ($1.0, map($1.0, $1.1))) }
}
