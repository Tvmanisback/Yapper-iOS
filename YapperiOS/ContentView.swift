import SwiftUI
import WebKit
import UIKit

struct ContentView: View {
    @StateObject private var browser = WebsiteBrowser()

    var body: some View {
        WebView(browser: browser)
            .ignoresSafeArea(edges: .bottom)
            .onAppear {
                browser.load(URL(string: "https://www.yapper.website")!)
            }
    }
}

final class WebsiteBrowser: ObservableObject {
    @Published var isLoading = false
    @Published var currentURLString: String?
    weak var webView: WKWebView?

    func load(_ url: URL) {
        webView?.load(URLRequest(url: url))
    }

    func update(from webView: WKWebView) {
        isLoading = webView.isLoading
        currentURLString = webView.url?.absoluteString
    }
}

struct WebView: UIViewRepresentable {
    @ObservedObject var browser: WebsiteBrowser

    func makeCoordinator() -> Coordinator {
        Coordinator(browser: browser)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        browser.webView = webView
        webView.load(URLRequest(url: URL(string: "https://www.yapper.website")!))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let browser: WebsiteBrowser
        private let yapperHosts = [
            "yapper.website", "www.yapper.website",
            "yapin.gg", "www.yapin.gg"
        ]

        init(browser: WebsiteBrowser) {
            self.browser = browser
        }

        private func isYapperHost(_ url: URL) -> Bool {
            guard let host = url.host?.lowercased() else { return false }
            return yapperHosts.contains(host) ||
                host.hasSuffix(".yapper.website") ||
                host.hasSuffix(".yapin.gg")
        }

        private func openInDefaultBrowser(_ url: URL) {
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            guard let scheme = url.scheme?.lowercased(),
                  scheme == "https" || scheme == "http" else {
                decisionHandler(.cancel)
                openInDefaultBrowser(url)
                return
            }

            if !isYapperHost(url) {
                decisionHandler(.cancel)
                openInDefaultBrowser(url)
                return
            }

            if navigationAction.targetFrame == nil {
                decisionHandler(.cancel)
                webView.load(navigationAction.request)
                return
            }

            decisionHandler(.allow)
        }

        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            guard let url = navigationAction.request.url else { return nil }
            if isYapperHost(url) {
                webView.load(navigationAction.request)
            } else {
                openInDefaultBrowser(url)
            }
            return nil
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            browser.update(from: webView)
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            browser.update(from: webView)
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            browser.update(from: webView)
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            browser.update(from: webView)
        }

        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            browser.update(from: webView)
        }
    }
}
