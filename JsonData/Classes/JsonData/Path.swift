//
//  Path.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public struct Path {

    private let paths: [Subscriptable]

    internal func appendingPath(path: Subscriptable) -> Path {
        var paths = self.paths
        paths.append(path)
        return Path(paths: paths)
    }
}

extension Path {
    internal static func root() -> Path {
        return Path(paths: [])
    }
}

extension Path : CustomStringConvertible {
    public var description: String {
        return "\"" + paths.map { "\($0)" }.joinWithSeparator(".") + "\""
    }
}