import Testing
import Core

@Test func testVersionComparison() throws {
    let a = Version(string: "v0.1.0-alpha.17")!
    let b = Version(string: "v0.1.0-alpha.18")!
    let c = Version(string: "v0.1.0-beta.1")!
    let d = Version(string: "v0.1.0")!
    #expect(a < b)
    #expect(b < c)
    #expect(c < d)
    #expect(a < c)
}

@Test func testVersionComparisonExtended() throws {
    let release = Version(string: "v0.1.0")!
    let beta = Version(string: "v0.1.0-beta.1")!
    let patch1 = Version(string: "v0.1.1")!
    let patch11 = Version(string: "v0.1.11")!
    let minor2 = Version(string: "v0.2.0")!

    #expect(beta < release)
    #expect(release < patch1)
    #expect(patch1 < patch11)
    #expect(patch11 < minor2)
}
