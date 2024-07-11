//
//  SwiftUIWebView.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 07/12/2022.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let webView: WKWebView
    let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
        webView = WKWebView(frame: .zero)
        webView.load(URLRequest(url: URL(string: "https://smartenergymonitoring.dei.estg.ipleiria.pt/ar?token=\(accessToken)")!))
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        webView.load(URLRequest(url: URL(string: "https://smartenergymonitoring.dei.estg.ipleiria.pt/ar?token=\(accessToken)")!))
    }
}
