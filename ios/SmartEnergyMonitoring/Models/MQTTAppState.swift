//
//  MQTTAppState.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 29/12/2022.
//

import Combine
import Foundation

enum MQTTAppConnectionState {
    case connected
    case disconnected
    case connecting
    case connectedSubscribed
    case connectedUnSubscribed

    var description: String {
        switch self {
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .connecting:
            return "Connecting"
        case .connectedSubscribed:
            return "Subscribed"
        case .connectedUnSubscribed:
            return "Connected Unsubscribed"
        }
    }
    var isConnected: Bool {
        switch self {
        case .connected, .connectedSubscribed, .connectedUnSubscribed:
            return true
        case .disconnected,.connecting:
            return false
        }
    }
    
    var isSubscribed: Bool {
        switch self {
        case .connectedSubscribed:
            return true
        case .disconnected,.connecting, .connected,.connectedUnSubscribed:
            return false
        }
    }
}

final class MQTTAppState: ObservableObject {
    @Published var appConnectionState: MQTTAppConnectionState = .disconnected
    private var onReceive: (String, String) -> Void
    
    init(onReceive: @escaping (String, String) -> Void) {
        self.onReceive = onReceive
    }
    
    func setOnReceive(callback: @escaping (String, String) -> Void) {
        self.onReceive = callback
    }

    func setReceivedMessage(topic: String, message: String) {
        onReceive(topic, message)
    }

    func setAppConnectionState(state: MQTTAppConnectionState) {
        appConnectionState = state
    }
}
