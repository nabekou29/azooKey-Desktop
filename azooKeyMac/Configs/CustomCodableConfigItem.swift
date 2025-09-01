//
//  LearningConfig.swift
//  azooKeyMac
//
//  Created by miwa on 2024/04/27.
//

import Foundation
import enum KanaKanjiConverterModuleWithDefaultDictionary.LearningType
import struct KanaKanjiConverterModuleWithDefaultDictionary.ConvertRequestOptions

protocol CustomCodableConfigItem: ConfigItem {
    static var `default`: Value { get }
}

extension CustomCodableConfigItem {
    var value: Value {
        get {
            guard let data = UserDefaults.standard.data(forKey: Self.key) else {
                print(#file, #line, "data is not set yet")
                return Self.default
            }
            do {
                let decoded = try JSONDecoder().decode(Value.self, from: data)
                return decoded
            } catch {
                print(#file, #line, error)
                return Self.default
            }
        }
        nonmutating set {
            do {
                let encoded = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(encoded, forKey: Self.key)
            } catch {
                print(#file, #line, error)
            }
        }
    }
}

extension Config {
    /// ライブ変換を有効化する設定
    struct Learning: CustomCodableConfigItem {
        enum Value: String, Codable, Equatable, Hashable {
            case inputAndOutput
            case onlyOutput
            case nothing

            var learningType: LearningType {
                switch self {
                case .inputAndOutput:
                    .inputAndOutput
                case .onlyOutput:
                    .onlyOutput
                case .nothing:
                    .nothing
                }
            }
        }
        static var `default`: Value = .inputAndOutput
        static var key: String = "dev.ensan.inputmethod.azooKeyMac.preference.learning"
    }
}

extension Config {
    struct UserDictionaryEntry: Sendable, Codable, Identifiable {
        init(word: String, reading: String, hint: String? = nil) {
            self.id = UUID()
            self.word = word
            self.reading = reading
            self.hint = hint
        }

        var id: UUID
        var word: String
        var reading: String
        var hint: String?

        var nonNullHint: String {
            get {
                hint ?? ""
            }
            set {
                if newValue.isEmpty {
                    hint = nil
                } else {
                    hint = newValue
                }
            }
        }
    }

    struct UserDictionary: CustomCodableConfigItem {
        var items: Value = Self.default

        struct Value: Codable {
            var items: [UserDictionaryEntry]
        }

        static let `default`: Value = .init(items: [
            .init(word: "azooKey", reading: "あずーきー", hint: "アプリ"),
            .init(word: #"<date format="yyyy/MM/dd" type="western" language="ja_JP" delta="0" deltaunit="1">"#, reading: "きょう", hint: "日付"),
            .init(word: #"<date format="yyyy-MM-dd" type="western" language="ja_JP" delta="0" deltaunit="1">"#, reading: "きょう", hint: "日付"),
            .init(word: #"<date format="HH:mm" type="western" language="ja_JP" delta="0" deltaunit="1">"#, reading: "いま", hint: "時刻"),
            .init(word: #"<date format="yyyy/MM/dd'\s'HH:mm" type="western" language="ja_JP" delta="0" deltaunit="1">"#, reading: "なう", hint: "日時"),
            .init(word: #"<date format="yyyy-MM-dd'T'HH:mm:ss+09:00" type="western" language="ja_JP" delta="0" deltaunit="1">"#, reading: "なう", hint: "日時")
        ])
        static let key: String = "dev.nabekou29.inputmethod.azooKeyMac.preference.user_dictionary_temporal2"
    }

    struct SystemUserDictionary: CustomCodableConfigItem {
        var items: Value = Self.default

        struct Value: Codable {
            var lastUpdate: Date?
            var items: [UserDictionaryEntry]
        }

        static let `default`: Value = .init(items: [])
        static let key: String = "dev.ensan.inputmethod.azooKeyMac.preference.system_user_dictionary"
    }
}

extension Config {
    /// Zenzaiのパーソナライズ強度
    struct ZenzaiPersonalizationLevel: CustomCodableConfigItem {
        enum Value: String, Codable, Equatable, Hashable {
            case off
            case soft
            case normal
            case hard

            var alpha: Float {
                switch self {
                case .off:
                    0
                case .soft:
                    0.5
                case .normal:
                    1.0
                case .hard:
                    1.5
                }
            }
        }
        static var `default`: Value = .normal
        static var key: String = "dev.ensan.inputmethod.azooKeyMac.preference.zenzai.personalization_level"
    }
}

extension Config {
    struct InputStyle: CustomCodableConfigItem {
        enum Value: String, Codable, Equatable, Hashable {
            case `default`
            case defaultAZIK
            case defaultKanaJIS
            case defaultKanaUS
            case custom
        }
        static var `default`: Value = .default
        static var key: String = "dev.ensan.inputmethod.azooKeyMac.preference.input_style"
    }
}
