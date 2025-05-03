import Metadata

public struct PackageMetadata {
    public static var gitTag: String? {
        String(validatingCString: git_tag_string())
    }
}
