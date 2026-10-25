# Yapper iOS

Full-screen iOS wrapper for https://www.yapper.website, built with SwiftUI and WKWebView.

- No address bar or browser toolbar.
- Yapper pages on yapper.website and yapin.gg stay inside the app.
- Off-site HTTP/HTTPS links open via iOS, which routes them to the user's configured default browser where supported.
- No index.html; the app loads the live website directly.
- GitHub Actions builds an unsigned IPA and stores it as an artifact.
- Push a tag such as v1.0.0 to also attach the IPA to a GitHub Release.

## Build

Open Actions → Build Yapper iOS IPA → Run workflow. Download the Yapper-iOS-unsigned-IPA artifact from the finished run.

For a tagged release, push a tag, e.g. git tag v1.0.0 && git push origin v1.0.0.

## Signing

The workflow produces an unsigned IPA. Sign it with KSign or another compatible tool using a valid certificate/provisioning setup before installing on a device.

## Notes

This is a web wrapper, not a native rewrite. Site features depend on iOS WKWebView compatibility and an internet connection.
