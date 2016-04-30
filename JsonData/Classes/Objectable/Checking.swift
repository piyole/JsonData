//
//  Checking.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum Checking {
    case Valid
    case Invalid(String)
    public static func check(valid: Bool, @autoclosure message: () -> String) -> Checking {
        if valid {
            return .Valid
        }
        return .Invalid(message())
    }
}
