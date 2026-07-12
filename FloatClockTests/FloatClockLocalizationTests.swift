import Foundation
import Testing
@testable import FloatClock

@MainActor
struct FloatClockLocalizationTests {
    private static func localizedBundle(for language: String) throws -> Bundle {
        let appBundle = Bundle(for: FloatClockController.self)
        let lproj = try #require(appBundle.path(forResource: language, ofType: "lproj"))
        return try #require(Bundle(path: lproj))
    }

    @Test
    func englishAlertStringsResolveFromSource() throws {
        let bundle = try Self.localizedBundle(for: "en")

        #expect(bundle.localizedString(forKey: "OK", value: nil, table: "Localizable") == "OK")
        #expect(
            bundle.localizedString(
                forKey: "FloatClock Is Unavailable",
                value: nil,
                table: "Localizable"
            )
            .isEmpty == false
        )
    }

    @Test
    func simplifiedChineseAlertStringsAreTranslated() throws {
        let bundle = try Self.localizedBundle(for: "zh-Hans")

        #expect(bundle.localizedString(forKey: "OK", value: nil, table: "Localizable") == "好")
        #expect(
            bundle.localizedString(
                forKey: "FloatClock Is Unavailable",
                value: nil,
                table: "Localizable"
            )
            == "FloatClock 不可用"
        )
        #expect(
            bundle.localizedString(
                forKey: "FloatClock Couldn’t Update",
                value: nil,
                table: "Localizable"
            )
            == "FloatClock 无法更新"
        )
    }

    @Test
    func settingsGuidanceIsLocalizedInBothLanguages() throws {
        let settingsKey = "Live Activities are turned off. Enable them in Settings to use FloatClock."
        let english = try Self.localizedBundle(for: "en")
            .localizedString(forKey: settingsKey, value: nil, table: "Localizable")
        let chinese = try Self.localizedBundle(for: "zh-Hans")
            .localizedString(forKey: settingsKey, value: nil, table: "Localizable")

        #expect(english == settingsKey)
        #expect(chinese == "实时活动已关闭。请在“设置”中启用，才能使用 FloatClock。")
    }
}
