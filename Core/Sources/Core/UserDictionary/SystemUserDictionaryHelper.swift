import Foundation
import SQLite3
#if canImport(AppKit)
import AppKit
#endif


/// macOSのユーザ辞書データを取り出すためのヘルパー
///
/// - note:
///   `bash`コマンドとしては次の通りのものに対応
///   ```bash
///   sqlite3 -header -csv ~/Library/KeyboardServices/TextReplacements.db "SELECT ZSHORTCUT, ZPHRASE FROM ZTEXTREPLACEMENTENTRY"
///   ```
public enum SystemUserDictionaryHelper: Sendable {
#if canImport(AppKit)
    /// Delegate that allows the user to choose **only** a directory named "KeyboardServices".
    private final class KeyboardServicesDirectoryDelegate: NSObject, NSOpenSavePanelDelegate {
        private let allowedFolderName = "KeyboardServices"

        /// Controls which items are enabled in the open panel.
        func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
            // Enable selection only for the target directory itself.
            return url.hasDirectoryPath && url.lastPathComponent == allowedFolderName
        }

        /// Validates the final URL when the user presses “Open”.
        func panel(_ sender: Any, validate url: URL) throws {
            guard url.lastPathComponent == allowedFolderName else {
                throw NSError(
                    domain: NSCocoaErrorDomain,
                    code: NSUserCancelledError,
                    userInfo: [NSLocalizedDescriptionKey: "KeyboardServicesという名前のフォルダのみ選択できます。"]
                )
            }
        }
    }

    /// A shared delegate instance that remains alive for the lifetime of the open panel.
    @MainActor private static let keyboardServicesDelegate = KeyboardServicesDirectoryDelegate()
#endif

    public struct Entry: Sendable {
        public let shortcut: String
        public let phrase: String
    }

    public enum FetchError: Sendable, Error {
        case fileNotExist(String)
        case fileNotReadable(String)
        case failedToOpenDatabase(status: Int32)
        case failedToPrepareStatement(status: Int32)
    }

    @MainActor static func promptUserForTextReplacementDirectory() -> URL? {
        let panel = NSOpenPanel()
        panel.title = "システムのユーザ辞書ディレクトリ（KeyboardServices）を選択してください"
        panel.message = "システムのユーザ辞書ディレクトリ（KeyboardServices）を選択してください"
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/KeyboardServices")
#if canImport(AppKit)
        panel.delegate = keyboardServicesDelegate
#endif

        let response = panel.runModal()
        return response == .OK ? panel.url : nil
    }

    @MainActor public static func fetchEntries() throws(FetchError) -> [Entry] {
        let userName = NSUserName()
        var dbPath = "/Users/\(userName)/Library/KeyboardServices/TextReplacements.db"
        guard FileManager.default.fileExists(atPath: dbPath) else {
            throw .fileNotExist(dbPath)
        }
        // 事前に取得を試みる
        print("dbPath", dbPath)

        if !FileManager.default.isReadableFile(atPath: dbPath) {
#if canImport(AppKit)
            guard let url = Self.promptUserForTextReplacementDirectory(), url.startAccessingSecurityScopedResource() else {
                throw FetchError.fileNotReadable(dbPath)
            }
#else
            throw FetchError.fileNotReadable(dbPath)
#endif
        }
        var db: OpaquePointer?

        let openStatus = sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READONLY, nil)
        guard openStatus == SQLITE_OK else {
            print("Failed to open database")
            throw .failedToOpenDatabase(status: openStatus)
        }

        defer {
            sqlite3_close(db)
        }

        let query = "SELECT ZSHORTCUT, ZPHRASE FROM ZTEXTREPLACEMENTENTRY"
        var statement: OpaquePointer?

        let prepareStatus = sqlite3_prepare_v2(db, query, -1, &statement, nil)
        guard prepareStatus == SQLITE_OK else {
            print("Failed to prepare statement")
            throw .failedToPrepareStatement(status: prepareStatus)
        }

        defer {
            sqlite3_finalize(statement)
        }

        var entries: [Entry] = []
        while sqlite3_step(statement) == SQLITE_ROW {
            if let shortcutC = sqlite3_column_text(statement, 0),
               let phraseC = sqlite3_column_text(statement, 1) {
                let shortcut = String(cString: shortcutC)
                let phrase = String(cString: phraseC)
                entries.append(Entry(shortcut: shortcut, phrase: phrase))
            }
        }

        return entries
    }
}
