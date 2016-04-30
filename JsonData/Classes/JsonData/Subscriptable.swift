//
//  Subscriptable.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public protocol Subscriptable {
    var subscriptType: SubscriptType { get }
}

extension Int : Subscriptable {
    public var subscriptType: SubscriptType {
        return .Index(self)
    }
}

extension String : Subscriptable {
    public var subscriptType: SubscriptType {
        return .Key(self)
    }
}