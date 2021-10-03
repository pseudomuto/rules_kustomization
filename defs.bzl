# The kustomization macro generates rules to build kustomize bases. The basic idea is that for every kustomization.yaml
# file in your tree, you'd define a `kustomization` for it, which can be used to build the base, or reference srcs for
# overlays.
#
# Example:
#   # in BUILD(.bazel) next to kustomization.yaml
#   load("@com_pseudomuto_rules_kustomization", "kustomization")
#   kustomization(
#     name = "kustomization",
#     srcs = glob(["**/*.yaml"]),
#   )
#
# Targets:
#   <name> - builds the base to a single file at <out>
#   <name>.manifest - builds the base and prints to stdout
#
# The main motivation for this macro is to make it easy to use kustomize to build manifests that can be used as
# k8s_deploy/k8s_object dependencies, etc.
def kustomization(name, srcs, out = "manifest.yaml", tags = ["block-network"]):
    public = ["//visibility:public"]
    native.filegroup(name = name +".srcs", srcs = srcs, visibility = public)
    native.filegroup(name = name +".base", srcs = ["kustomization.yaml"], visibility = ["//visibility:private"])

    # LoadRestrictionsNone is necessary since by default kustomize prunes symlinks, and bazel symlinks all the things.
    # This isn't necessarily as bad as it seems, so long as the "block-network" tag remains defined.
    cmd = ["$(location @kustomize//:file)", "build", "--load-restrictor=LoadRestrictionsNone"]

    # The main rule which generates the <out> file.
    # $ bazel build //<target>:<name>
    native.genrule(
        name = name,
        srcs = [":{}.srcs".format(name), ":{}.base".format(name)],
        outs = [out],
        cmd = " ".join(cmd + ["$$(dirname $(location :{}.base))".format(name), "> \"$@\""]),
        tools = ["@kustomize//:file"],
        tags = tags,
        visibility = public,
    )

    # A runnable rule to print the result to stdout.
    # $ bazel run //<target>:<name>.manifest
    native.genrule(
        name = "{}.manifest".format(name),
        srcs = [name],
        outs = ["print-manifest"],
        cmd = "echo 'cat $(location :{})' > \"$@\"".format(name),
        executable = True,
        visibility = public,
    )
