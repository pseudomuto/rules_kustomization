load("@bazel_tools//tools/build_defs/repo:utils.bzl", "patch", "workspace_and_buildfile")

def download_kustomize(
    version = "4.3.0",
    darwin_sha="77898f8b7c37e3ba0c555b4b7c6d0e3301127fa0de7ade6a36ed767ca1715643",
    linux_sha="d34818d2b5d52c2688bce0e10f7965aea1a362611c4f1ddafd95c4d90cb63319"):
    # format needs version, version, arch (darwin/linux)
    urlFmt = (
        "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize/" +
        "v"+ version +"/kustomize_v"+ version +"_{}_amd64.tar.gz"
    )

    _http_archive_by_os(
        name = "kustomize",
        sha256 = {
            "darwin": darwin_sha,
            "linux": linux_sha,
        },
        url = {
            "darwin": urlFmt.format("darwin"),
            "linux": urlFmt.format("linux"),
        },
        build_file_content = 'filegroup(name = "file", srcs = ["kustomize"], visibility = ["//visibility:public"])',
    )

# Everything below was "borrowed" and adapted from:
# https://github.com/bazelbuild/rules_k8s/issues/298

def _os_name(repository_ctx):
    os_name = repository_ctx.os.name.lower()
    if os_name.startswith("mac os"):
        return "darwin"
    elif os_name.startswith("linux"):
        return "linux"
    else:
        fail("Unsupported operating system: " + os_name)

_http_archive_by_os_attrs = {
    "url": attr.string_dict(),
    "sha256": attr.string_dict(),
    "strip_prefix": attr.string_dict(),
    "type": attr.string(),
    "build_file": attr.label(allow_single_file = True),
    "build_file_content": attr.string(),
    "patches": attr.label_list(default = []),
    "patch_tool": attr.string(default = "patch"),
    "patch_args": attr.string_list(default = ["-p0"]),
    "patch_cmds": attr.string_list(default = []),
    "workspace_file": attr.label(allow_single_file = True),
    "workspace_file_content": attr.string(),
}

def _http_archive_by_os_impl(ctx):
    """Implementation of the http_archive rule."""
    if not ctx.attr.url and not ctx.attr.urls:
        fail("At least one of url and urls must be provided")
    if ctx.attr.build_file and ctx.attr.build_file_content:
        fail("Only one of build_file and build_file_content can be provided.")

    host = _os_name(ctx)
    url = ctx.attr.url.get(host)
    sha256 = ctx.attr.sha256.get(host) or ""
    strip_prefix = ctx.attr.strip_prefix.get(host) or ""

    ctx.download_and_extract(
        url,
        "",
        sha256,
        ctx.attr.type,
        strip_prefix,
    )
    patch(ctx)
    workspace_and_buildfile(ctx)

_http_archive_by_os = repository_rule(
    implementation = _http_archive_by_os_impl,
    attrs = _http_archive_by_os_attrs,
)
