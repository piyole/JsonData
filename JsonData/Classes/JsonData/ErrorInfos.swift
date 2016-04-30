//
//  ErrorInfos.swift
//  JsonData
//
//  Created by wegie on 2016/04/30.
//  Copyright © 2016年 wegie. All rights reserved.
//

import Foundation

public struct ErrorInfos : ErrorType {

    private typealias ErrorInfo = (path: Path, error: ErrorType)

    private let errors: [ErrorInfo]

    public var error: ErrorType {
        return errors.last!.error
    }

    internal var path: Path {
        return errors.last!.path
    }

    internal func compound(key: Subscriptable, error: ErrorType) -> ErrorInfos {
        return compound(path.appendingPath(key), error: error)
    }
    internal func compound(path: Path, error: ErrorType) -> ErrorInfos {
        var errors = self.errors
        errors.append((path: path, error: error))
        return ErrorInfos(errors: errors)
    }
    internal func compound(errorInfos: ErrorInfos) -> ErrorInfos {
        var errors = self.errors
        errors.appendContentsOf(errorInfos.errors)
        return ErrorInfos(errors: errors)
    }

}

extension ErrorInfos {
    internal static func of(path: Path, error: ErrorType) -> ErrorInfos {
        return ErrorInfos(errors: [(path: path, error: error)])
    }
}

extension ErrorInfos : CustomStringConvertible {
    public var description: String {
        if let last = errors.last {
            let length = last.path.description.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            return errors.reduce(last.error.description, combine: { (string, errorInfo) -> String in
                string + "\n\t" + "\(path(errorInfo.path, length: length)) : \(errorInfo.error)"
            })
        }
        return ""
    }
    private func path(path: Path, length: Int) -> String {
        return path.description + String(count: length - path.description.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), repeatedValue: Character(" "))
    }
}
