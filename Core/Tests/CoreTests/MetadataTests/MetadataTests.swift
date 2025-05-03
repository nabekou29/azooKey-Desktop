import Testing
import Core

@Test func testMetadata() async throws {
    print("🏷️\tCurrent Git Tag", PackageMetadata.gitTag ?? "nil")
    #expect(PackageMetadata.gitTag != nil)
    #expect(PackageMetadata.gitTag != "unknown")
}
