import Cocoa
import InputMethodKit

extension azooKeyMacInputController {
    // MARK: - Settings and Menu Items

    func setupMenu() {
        self.zenzaiToggleMenuItem = NSMenuItem(title: "Zenzai（ニューラルかな漢字変換）", action: #selector(self.toggleZenzai(_:)), keyEquivalent: "")
        self.liveConversionToggleMenuItem = NSMenuItem(title: "ライブ変換", action: #selector(self.toggleLiveConversion(_:)), keyEquivalent: "")
        self.updateMenuItem = NSMenuItem(title: "アップデートを確認中…", action: #selector(self.openUpdateURL(_:)), keyEquivalent: "")
        self.updateMenuItem?.isHidden = true
        self.appMenu.addItem(self.zenzaiToggleMenuItem)
        self.appMenu.addItem(self.liveConversionToggleMenuItem)
        if let updateMenuItem {
            self.appMenu.addItem(updateMenuItem)
        }
        self.appMenu.addItem(NSMenuItem.separator())
        self.appMenu.addItem(NSMenuItem(title: "詳細設定を開く", action: #selector(self.openConfigWindow(_:)), keyEquivalent: ""))
        self.appMenu.addItem(NSMenuItem(title: "View on GitHub", action: #selector(self.openGitHubRepository(_:)), keyEquivalent: ""))

        self.startUpdateCheckerProcess()
    }

    @objc private func toggleZenzai(_ sender: Any) {
        self.segmentsManager.appendDebugMessage("\(#line): toggleZenzai")
        let config = Config.ZenzaiIntegration()
        config.value = !self.zenzaiEnabled
        self.updateZenzaiToggleMenuItem(newValue: config.value)
    }

    func updateZenzaiToggleMenuItem(newValue: Bool) {
        self.zenzaiToggleMenuItem.state = newValue ? .on : .off
        self.zenzaiToggleMenuItem.title = "Zenzai（ニューラルかな漢字変換）"
    }

    @objc func toggleLiveConversion(_ sender: Any) {
        self.segmentsManager.appendDebugMessage("\(#line): toggleLiveConversion")
        let config = Config.LiveConversion()
        config.value = !self.liveConversionEnabled
        self.updateLiveConversionToggleMenuItem(newValue: config.value)
    }

    func updateLiveConversionToggleMenuItem(newValue: Bool) {
        self.liveConversionToggleMenuItem.state = newValue ? .on : .off
        self.liveConversionToggleMenuItem.title = "ライブ変換"
    }

    @objc func openGitHubRepository(_ sender: Any) {
        guard let url = URL(string: "https://github.com/ensan-hcl/azooKey-Desktop") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc func openConfigWindow(_ sender: Any) {
        (NSApplication.shared.delegate as? AppDelegate)!.openConfigWindow()
    }

    private nonisolated func startUpdateCheckerProcess() {
        Task { [weak self] in
            while true {
                self?.segmentsManager.appendDebugMessage("\(#function): update check triggered")
                UpdateChecker.checkForUpdates { urlString in
                    self?.segmentsManager.appendDebugMessage("\(#function): urlString \(urlString as String?)")
                    guard let self, let urlString, let url = URL(string: urlString) else {
                        self?.updateMenuItem?.isHidden = true
                        self?.updateMenuItem?.representedObject = nil
                        self?.updateURL = nil
                        return
                    }
                    Task { @MainActor in
                        self.segmentsManager.appendDebugMessage("\(#function): update: updateMenuItem \(url)")
                        self.updateMenuItem?.title = "アプリの更新があります…"
                        self.updateMenuItem?.isHidden = false
                        self.updateURL = url
                    }
                }
                try await Task.sleep(for: .seconds(60 * 60 * 24))
            }
        }
    }

    @objc private func openUpdateURL(_ sender: Any) {
        if let url = self.updateURL {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Application Support Directory
    func prepareApplicationSupportDirectory() {
        do {
            self.segmentsManager.appendDebugMessage("\(#line): Applicatiion Support Directory Path: \(self.segmentsManager.azooKeyMemoryDir)")
            try FileManager.default.createDirectory(at: self.segmentsManager.azooKeyMemoryDir, withIntermediateDirectories: true)
        } catch {
            self.segmentsManager.appendDebugMessage("\(#line): \(error.localizedDescription)")
        }
    }
}
