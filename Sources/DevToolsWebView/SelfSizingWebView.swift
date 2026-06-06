//
//  SelfSizingWebView.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import WebKit

/// A `WKWebView` subclass that sizes itself to its content height via Auto Layout.
///
/// After the page finishes loading, `SelfSizingWebView` reads the content height
/// via JavaScript and reports it through `intrinsicContentSize`. Auto Layout reacts
/// automatically — no manual frame management needed.
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
    public private(set) var measuredContentHeight: CGFloat = 0 {
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
    }

    public convenience init(configuration: WKWebViewConfiguration = .init()) {
        self.init(frame: .zero, configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init(configuration:) instead.")
    }

    // MARK: - Private

    private let internalCoordinator = NavigationCoordinator()

    private func updateScrollBehaviour() {
        scrollView.isScrollEnabled = maxHeight != .infinity && measuredContentHeight > maxHeight
    }
}

// MARK: - Internal navigation coordinator

private final class NavigationCoordinator: NSObject, WKNavigationDelegate {

    weak var owner: SelfSizingWebView?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let owner else { return }
        Task { @MainActor [weak owner] in
            guard let owner else { return }
            if let height = try? await owner.contentHeight() {
                owner.measuredContentHeight = height
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
