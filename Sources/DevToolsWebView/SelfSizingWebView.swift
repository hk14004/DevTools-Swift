//
//  SelfSizingWebView.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

/// A `WKWebView` subclass that sizes itself to its content height via Auto Layout.
///
/// `SelfSizingWebView` continuously measures the height of `document.body` using a
/// JavaScript `ResizeObserver` and reports it through `intrinsicContentSize`. Auto
/// Layout reacts automatically — no manual frame management needed.
///
/// Because measurement is continuous rather than a one-shot read at load time, the
/// view tracks content that changes *after* the initial load: images and web fonts
/// settling in, DOM mutations, and reflow caused by width changes (e.g. device
/// rotation). It also shrinks correctly when shorter content is loaded into a view
/// that previously displayed something taller.
///
/// When content exceeds `maxHeight`, the view caps its height and enables its own
/// internal scrolling. When content fits, internal scrolling is disabled so the
/// view composes cleanly inside an outer `UIScrollView`.
///
/// # UIKit usage
/// ```swift
/// let webView = SelfSizingWebView()
/// webView.maxHeight = 500
/// webView.translatesAutoresizingMaskIntoConstraints = false
/// view.addSubview(webView)
///
/// NSLayoutConstraint.activate([
///     webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
///     webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
///     webView.topAnchor.constraint(equalTo: view.topAnchor),
///     // No height constraint — intrinsicContentSize drives the height
/// ])
///
/// webView.load(URLRequest(url: url))
/// ```
///
/// # Infinite height (inside a UIScrollView)
/// Pass `.infinity` to disable the height cap. The view expands to full content
/// height and never scrolls internally — let the outer scroll view handle it.
/// ```swift
/// webView.maxHeight = .infinity
/// ```
///
/// # Navigation callbacks
/// Use `onNavigationFinished` and `onError` instead of setting `navigationDelegate`
/// directly. The delegate is managed internally for content sizing; these closures
/// forward events without conflict.
/// ```swift
/// webView.onNavigationFinished = { webView in
///     print("Loaded, content height: \(webView.measuredContentHeight)pt")
/// }
/// webView.onError = { error in
///     print("Failed:", error)
/// }
/// ```
public final class SelfSizingWebView: WKWebView {

    // MARK: - Public properties

    /// Maximum height before internal scrolling kicks in.
    /// Pass `.infinity` when embedding inside a `UIScrollView` to expand fully.
    /// Defaults to `400`.
    public var maxHeight: CGFloat = 400 {
        didSet {
            updateScrollBehaviour()
            invalidateIntrinsicContentSize()
        }
    }

    /// Called after the page finishes loading and content height has been measured.
    public var onNavigationFinished: ((SelfSizingWebView) -> Void)?

    /// Called when navigation fails.
    public var onError: ((Error) -> Void)?

    /// Called whenever the measured content height changes.
    public var onContentHeightChanged: ((CGFloat) -> Void)?

    /// The most recently measured content height in points.
    /// Zero until the first page load completes.
    public internal(set) var measuredContentHeight: CGFloat = 0 {
        didSet {
            guard measuredContentHeight != oldValue else { return }
            updateScrollBehaviour()
            invalidateIntrinsicContentSize()
            onContentHeightChanged?(measuredContentHeight)
        }
    }

    // MARK: - intrinsicContentSize

    public override var intrinsicContentSize: CGSize {
        guard measuredContentHeight > 0 else {
            return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        let height = maxHeight == .infinity ? measuredContentHeight : min(measuredContentHeight, maxHeight)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    // MARK: - Init

    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = internalCoordinator
        internalCoordinator.owner = self
        installHeightObserver()
    }

    public convenience init(configuration: WKWebViewConfiguration = .init()) {
        self.init(frame: .zero, configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init(configuration:) instead.")
    }

    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: Self.heightMessageName)
    }

    // MARK: - Private

    private let internalCoordinator = NavigationCoordinator()

    /// Name of the script message channel the injected JavaScript posts heights to.
    private static let heightMessageName = "selfSizingContentHeight"

    /// Injects a `ResizeObserver` that reports `document.body.scrollHeight` whenever
    /// the body's size changes, plus once on `load`. A weak proxy handler avoids the
    /// retain cycle that a direct `WKScriptMessageHandler` would create (the
    /// userContentController retains its handlers).
    private func installHeightObserver() {
        let controller = configuration.userContentController
        controller.add(HeightMessageHandler(owner: self), name: Self.heightMessageName)

        let js = """
        (function() {
            function report() {
                var body = document.body;
                if (!body) { return; }
                window.webkit.messageHandlers.\(Self.heightMessageName).postMessage(body.scrollHeight);
            }
            if (typeof ResizeObserver !== 'undefined' && document.body) {
                new ResizeObserver(report).observe(document.body);
            }
            window.addEventListener('load', report);
            report();
        })();
        """
        controller.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        )
    }

    fileprivate func reportMeasuredHeight(_ height: CGFloat) {
        guard height > 0 else { return }
        measuredContentHeight = height
    }

    private func updateScrollBehaviour() {
        scrollView.isScrollEnabled = maxHeight != .infinity && measuredContentHeight > maxHeight
    }
}

// MARK: - Height message handler

/// Forwards JavaScript height messages to the owning web view.
///
/// Holds `owner` weakly so the `userContentController -> handler -> webView`
/// reference chain does not become a retain cycle.
private final class HeightMessageHandler: NSObject, WKScriptMessageHandler {

    weak var owner: SelfSizingWebView?

    init(owner: SelfSizingWebView) {
        self.owner = owner
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let height = (message.body as? NSNumber)?.doubleValue else { return }
        owner?.reportMeasuredHeight(CGFloat(height))
    }
}

// MARK: - Internal navigation coordinator

private final class NavigationCoordinator: NSObject, WKNavigationDelegate {

    weak var owner: SelfSizingWebView?

    /// Incremented on each new navigation so a slow measurement from a previous
    /// load can't overwrite the height of the page that's now showing.
    private var generation = 0

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        generation &+= 1
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let owner else { return }
        let current = generation
        Task { @MainActor [weak self, weak owner] in
            guard let self, let owner else { return }
            // The ResizeObserver normally reports first, but take an immediate
            // measurement too so height is available the moment loading finishes.
            if self.generation == current, let height = try? await owner.contentHeight() {
                owner.reportMeasuredHeight(height)
            }
            owner.onNavigationFinished?(owner)
        }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        owner?.onError?(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        owner?.onError?(error)
    }
}
