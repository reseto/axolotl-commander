// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 The Axolotl Commander Authors

import Testing
@testable import CommanderCore

@Suite struct EditorListTests {
    private let textEdit = EditorList.App(bundleID: "com.apple.TextEdit", name: "TextEdit")
    private let code = EditorList.App(bundleID: "com.microsoft.VSCode", name: "Visual Studio Code")
    private let codium = EditorList.App(bundleID: "com.vscodium", name: "VSCodium")

    @Test func knownEditorsComeBeforeAddedOnes() {
        let list = EditorList.merged(known: [textEdit, code], custom: [codium], selected: "com.apple.TextEdit")
        #expect(list.map(\.bundleID) == ["com.apple.TextEdit", "com.microsoft.VSCode", "com.vscodium"])
    }

    @Test func anApplicationInBothListsAppearsOnce() {
        // The first entry wins, so a known editor keeps its name.
        let renamed = EditorList.App(bundleID: "com.microsoft.VSCode", name: "Code")
        let list = EditorList.merged(known: [code], custom: [renamed, codium], selected: nil)
        #expect(list == [code, codium])
    }

    @Test func aSelectionThatIsNotListedIsAppendedSoThePickerCanShowIt() {
        let list = EditorList.merged(known: [textEdit], custom: [], selected: "org.example.Gone")
        #expect(list.last == EditorList.App(bundleID: "org.example.Gone", name: "org.example.Gone"))
        #expect(list.count == 2)
    }

    @Test func noSelectionAddsNothing() {
        #expect(EditorList.merged(known: [textEdit], custom: [], selected: nil) == [textEdit])
        #expect(EditorList.merged(known: [textEdit], custom: [], selected: "") == [textEdit])
        #expect(EditorList.merged(known: [], custom: [], selected: nil).isEmpty)
    }

    @Test func addingAppendsInOrder() {
        var paths: [String] = []
        paths = EditorList.adding("/Applications/VSCodium.app", to: paths)
        paths = EditorList.adding("/Applications/Zed.app", to: paths)
        #expect(paths == ["/Applications/VSCodium.app", "/Applications/Zed.app"])
    }

    @Test func addingTheSameApplicationAgainKeepsItsPlace() {
        let paths = ["/Applications/VSCodium.app", "/Applications/Zed.app"]
        #expect(EditorList.adding("/Applications/VSCodium.app", to: paths) == paths)
        // The same folder written another way is the same application.
        #expect(EditorList.adding("/Applications/./VSCodium.app", to: paths) == paths)
        #expect(EditorList.adding("/Applications/VSCodium.app/", to: paths) == paths)
    }

    @Test func addingAnEmptyPathChangesNothing() {
        #expect(EditorList.adding("", to: ["/Applications/Zed.app"]) == ["/Applications/Zed.app"])
    }
}
