.PHONY: release
release:
	git commit --allow-empty -m "Bump to version $(VERSION)"
	git tag v$(VERSION)
	git push origin main --tags
