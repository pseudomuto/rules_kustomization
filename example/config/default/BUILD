load("@com_pseudomuto_rules_kustomization//:defs.bzl", "kustomization")

kustomization(
    name = "kustomization",
    srcs = [
        "kustomization.yaml",
        "//config/crd:kustomization.srcs",
        "//config/manager:kustomization.srcs",
    ],
)
