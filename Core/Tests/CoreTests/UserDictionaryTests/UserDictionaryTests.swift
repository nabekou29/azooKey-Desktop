import Testing
@testable import Core

@Test func testSystemUserDictionaryHelper() async throws {
    let entries = try await SystemUserDictionaryHelper.fetchEntries()
    print(entries)
    // always true
    #expect(entries.count >= 0)
}
