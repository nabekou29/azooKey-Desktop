import Core
import Foundation

enum UpdateChecker {
    private static let lastCheckKey = "dev.ensan.inputmethod.azooKeyMac.preference.lastUpdateCheck"
    private static let updateURLKey = "dev.ensan.inputmethod.azooKeyMac.preference.availableUpdateURL"

    static func storedURL() -> String? {
        UserDefaults.standard.string(forKey: updateURLKey)
    }

    static func checkForUpdates(completion: @escaping (String?) -> Void) {
        let now = Date().timeIntervalSince1970
        if let last = UserDefaults.standard.value(forKey: lastCheckKey) as? Double,
           now - last < 60 * 60 * 24 {
            completion(storedURL())
            return
        }
        UserDefaults.standard.set(now, forKey: lastCheckKey)

        guard let url = URL(string: "https://api.github.com/repos/azooKey/azooKey-Desktop/releases/latest") else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            var updateURL: String?
            defer {
                DispatchQueue.main.async {
                    completion(updateURL)
                }
            }
            guard let data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let tagName = json["tag_name"] as? String else {
                return
            }
            let htmlURL = "https://github.com/azooKey/azooKey-Desktop/releases/tag/\(tagName)"
            let current = PackageMetadata.gitTag ?? "0"
            if let new = Version(string: tagName),
               let currentVer = Version(string: current),
               currentVer < new {
                updateURL = htmlURL
                UserDefaults.standard.set(updateURL, forKey: updateURLKey)
            } else {
                UserDefaults.standard.removeObject(forKey: updateURLKey)
            }
        }
        task.resume()
    }

}
