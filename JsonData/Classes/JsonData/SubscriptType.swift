//
//  SubscriptType.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public enum SubscriptType {
    case Index(Int)
    case Key(String)
}

extension SubscriptType : CustomStringConvertible {
    public var description: String {
        switch self {
        case .Index(let index):
            return "Index(\(index))"
        case .Key(let key):
            return "Key(\"\(key)\")"
        }
    }
}
