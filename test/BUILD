load("@com_pseudomuto_rules_kustomization//:defs.bzl", "kustomization")
load("@bazel_tools//tools/build_rules:test_rules.bzl", "file_test")

kustomization(
    name = "kustomization",
    srcs = glob(["**/*.yaml"]),
)

golden_output = """apiVersion: v1
kind: Namespace
metadata:
  name: placeholder
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: MyDeployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  spec:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - image: nginx:latest
        name: nginx
  template:
    spec:
      containers:
      - image: nginx:1.17.1
        name: nginx
"""

file_test(
    name = "output-test",
    content = golden_output,
    file = ":kustomization",
)
