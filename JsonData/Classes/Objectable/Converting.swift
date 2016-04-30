//
//  Converting.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum Converting<T> {
    case Converted(T)
    case CannotConvert(String)
    public static func convert(@autoclosure convert: () -> T?, @autoclosure message: () -> String) -> Converting {
        if let converted = convert() {
            return .Converted(converted)
        }
        return .CannotConvert(message())
    }
}

