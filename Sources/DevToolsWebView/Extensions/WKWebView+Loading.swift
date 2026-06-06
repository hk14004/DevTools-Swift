//
//  WKWebView+Loading.swift
//  DevToolsWebView
//
//  Created by Hardijs on 04/06/2026.
//

import Combine
import WebKit

public extension WKWebView {

    /// Emits the estimated load progress as a value between `0.0` and `1.0`.
    ///
    /// Useful for driving a `UIProgressView` or a SwiftUI `ProgressView`.
    ///
    /// # UIKit
    /// ```swift
    /// webView.loadingProgressPublisher
    ///     .receive(on: DispatchQueue.main)
    ///     .sink { progress in
    ///         progressView.setProgress(Float(progress), animated: true)
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    ///
    /// # SwiftUI (via WebView callback)
    /// ```swift
    /// WebView(url: url, onLoadingProgressChanged: { progress in
    ///     self.progress = progress
    /// })
    /// ```
    var loadingProgressPublisher: AnyPublisher<Double, Never> {
        publisher(for: \.estimatedProgress)
            .eraseToAnyPublisher()
    }

    /// Emits `true` when the web view is loading and `false` when it finishes.
    ///
    /// ```swift
    /// webView.isLoadingPublisher
    ///     .receive(on: DispatchQueue.main)
    ///     .sink { isLoading in
    ///         spinner.isHidden = !isLoading
    ///     }
    ///     .store(in: &cancellables)
    /// ```
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        publisher(for: \.isLoading)
            .eraseToAnyPublisher()
    }
}
