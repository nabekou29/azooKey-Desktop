//
//  Version.swift
//  azooKeyMac
//
//  Created by Codex.
//

import Foundation

/// Semantic version representation supporting pre-release identifiers.
public struct Version: Comparable {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let preRelease: [Identifier]

    /// Pre-release identifier.
    public enum Identifier: Comparable {
        case numeric(Int)
        case text(String)

        public static func < (lhs: Identifier, rhs: Identifier) -> Bool {
            switch (lhs, rhs) {
            case let (.numeric(a), .numeric(b)):
                return a < b
            case (.numeric, .text):
                return true
            case (.text, .numeric):
                return false
            case let (.text(a), .text(b)):
                return a < b
            }
        }
    }

    public init?(string: String) {
        var version = string
        if version.first == "v" || version.first == "V" {
            version.removeFirst()
        }
        let parts = version.split(separator: "-", maxSplits: 1, omittingEmptySubsequences: true)
        let numbers = parts.first?.split(separator: ".") ?? []
        guard numbers.count >= 3,
              let major = Int(numbers[0]),
              let minor = Int(numbers[1]),
              let patch = Int(numbers[2]) else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch

        if parts.count == 2 {
            self.preRelease = parts[1].split(separator: ".").map { segment in
                if let value = Int(segment) {
                    return .numeric(value)
                }
                return .text(String(segment))
            }
        } else {
            self.preRelease = []
        }
    }

    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        if lhs.patch != rhs.patch {
            return lhs.patch < rhs.patch
        }
        if lhs.preRelease.isEmpty && rhs.preRelease.isEmpty {
            return false
        }
        if lhs.preRelease.isEmpty {
            return false
        }
        if rhs.preRelease.isEmpty {
            return true
        }
        for (a, b) in zip(lhs.preRelease, rhs.preRelease) {
            if a == b { continue }
            return a < b
        }
        return lhs.preRelease.count < rhs.preRelease.count
    }
}
