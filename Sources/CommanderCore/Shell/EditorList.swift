// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 The Axolotl Commander Authors

import Foundation

/// The editors offered for F4 (Settings → Viewer & Editor): the known ones that are installed,
/// then the applications the user added. Plain values, so the merge is testable without AppKit.
public enum EditorList {
    public struct App: Hashable, Sendable, Identifiable {
        public var bundleID: String
        public var name: String
        public var id: String { bundleID }

        public init(bundleID: String, name: String) {
            self.bundleID = bundleID
            self.name = name
        }
    }

    /// `known`, then `custom`, one entry per bundle identifier (the first wins). A `selected`
    /// identifier that is in neither (an application that was removed, say) is appended under its
    /// identifier, so a picker never has a selection it cannot show.
    public static func merged(known: [App], custom: [App], selected: String?) -> [App] {
        var seen = Set<String>()
        var result = (known + custom).filter { seen.insert($0.bundleID).inserted }
        if let selected, !selected.isEmpty, seen.insert(selected).inserted {
            result.append(App(bundleID: selected, name: selected))
        }
        return result
    }

    /// `paths` with `path` added at the end. An application that is already listed (same path
    /// once standardized) stays where it is; an empty path is ignored.
    public static func adding(_ path: String, to paths: [String]) -> [String] {
        guard !path.isEmpty else { return paths }
        let key = standardized(path)
        if paths.contains(where: { standardized($0) == key }) { return paths }
        return paths + [path]
    }

    private static func standardized(_ path: String) -> String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }
}
