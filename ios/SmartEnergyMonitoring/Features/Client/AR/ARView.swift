//
//  ARView.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import SwiftUI
import WebKit

struct ARView: View {
    @EnvironmentObject var session: SessionManager
    
    var body: some View {
        ZStack {
            Theme.background.edgesIgnoringSafeArea(.top)
            WebView(accessToken: session.accessToken!)
        }
    }
}
