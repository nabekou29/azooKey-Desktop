#ifndef GIT_TAG
#define GIT_TAG "unknown"
#endif

#ifndef GIT_COMMIT
#define GIT_COMMIT "unknown"
#endif

const char* git_tag_string(void) {
    return GIT_TAG;
}

const char* git_commit_string(void) {
    return GIT_COMMIT;
}
