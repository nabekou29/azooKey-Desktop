import Metadata

public struct PackageMetadata {
    public static var gitTag: String? {
        let gitTag = String(validatingCString: git_tag_string())
        return if gitTag == "unknown" {
            nil
        } else {
            gitTag
        }
    }
    public static var gitCommit: String? {
        let gitCommit = String(validatingCString: git_commit_string())
        return if gitCommit == "unknown" {
            nil
        } else {
            gitCommit
        }
    }
}
