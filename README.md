# rules_kustomization

![Build status](https://github.com/pseudomuto/rules_kustomization/actions/workflows/ci.yaml/badge.svg?branch=main)

A bazel macro for generating kustomize bases. The main motivation for this macro is to make it easy to use kustomize to
build manifests that can be used as k8s_deploy/k8s_object dependencies, etc.

It has been tested on OSX (amd64 and arm64) and Linux amd64. Other platform _may_ work.

## Setup

In your WORKSPACE file add the following:

```bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "com_pseudomuto_rules_kustomization",
    sha256 = "f25fecad8852572028e8f17080267dd915bbc6f258370ed6d4dccf4203159096",
    strip_prefix = "rules_kustomization-v0.1.0",
    urls = ["https://github.com/pseudomuto/rules_kustomization/archive/v0.1.0.tar.gz"],
)

load("@com_pseudomuto_rules_kustomization//:workspace.bzl", "download_kustomize")
download_kustomize()
```

## Usage

Add the following to your BUILD file. This build file must be a sibling of kustomization.yaml. See the
[example](example) for a working demo.

```bzl
load("@com_pseudomuto_rules_kustomization//:defs.bzl", "kustomization")

kustomization(
    name = "kustomization",
    srcs = glob(["**/*.yaml"]),
)
```

This can then be used as input by other rules. For example:

```bzl
# ...omitted code from above
load("@k8s_deploy//:defaults.bzl", "k8s_deploy")
k8s_deploy(
    name = "crd",
    template = ":kustomization", # the name from above
    visibility = ["//visibility:public"],
)
```

### Viewing output

If you'd like to see what is being generated, you can run the `<name>.manifest` rule. Assuming we have the kustomization
rule above you'd run `bazel run //<target>:kustomization.manifest`. This will dump the result from `kustomize build` to
stdout.
