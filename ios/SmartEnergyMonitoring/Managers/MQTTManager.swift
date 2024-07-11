//
//  MQTTBrokerManager.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 27/12/2022.
//

import SwiftUI
import CocoaMQTT
import Combine

@MainActor
final class MQTTManager: ObservableObject {
    private var mqttClient: CocoaMQTT?
    private var userID: Int = 0
    private var host: String = "broker.emqx.io"
    
    private var anyCancellable: AnyCancellable?
    @Published var currentAppState = MQTTAppState(onReceive: { (topic, message) -> Void in
        print("Topic: \(topic), Message: \(message)")
    })
    
    // Private Init
    private init() {
        // Workaround to support nested Observables, without this code changes to state is not propagated
        anyCancellable = currentAppState.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: Shared Instance
    private static let _shared = MQTTManager()

    // MARK: - Accessors
    class func shared() -> MQTTManager {
        return _shared
    }

    func initializeMQTT(userID: Int) {
        self.userID = userID
        
        // If any previous instance exists then clean it
        if mqttClient != nil {
            mqttClient = nil
        }

        mqttClient = CocoaMQTT(clientID: "CocoaMQTT-\(userID)-" + String(ProcessInfo().processIdentifier), host: host, port: 1883)
        mqttClient?.keepAlive = 65534
        mqttClient?.delegate = self
    }

    func connect() {
        if let success = mqttClient?.connect(), success {
            currentAppState.setAppConnectionState(state: .connecting)
        } else {
            currentAppState.setAppConnectionState(state: .disconnected)
        }
    }

    func subscribe(topic: String) {
        mqttClient?.subscribe(topic, qos: .qos1)
    }

    func publish(topic: String, with message: String) {
        mqttClient?.publish(topic, withString: message, qos: .qos1)
    }

    func disconnect() {
        mqttClient?.disconnect()
    }

    func unSubscribe(topic: String) {
        mqttClient?.unsubscribe(topic)
    }
    
    func currentHost() -> String? {
        return host
    }
    
    func isSubscribed() -> Bool {
       return currentAppState.appConnectionState.isSubscribed
    }
    
    func isConnected() -> Bool {
        return currentAppState.appConnectionState.isConnected
    }
    
    func connectionStateMessage() -> String {
        return currentAppState.appConnectionState.description
    }
    
    func setOnReceive(callback: @escaping (String, String) -> Void) {
        self.currentAppState.setOnReceive(callback: callback)
    }
}

extension MQTTManager: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics topics: NSDictionary, failed: [String]) {
        TRACE("topic: \(topics)")
        currentAppState.setAppConnectionState(state: .connectedSubscribed)
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        TRACE("topic: \(topics)")
        currentAppState.setAppConnectionState(state: .connectedUnSubscribed)
    }

    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        TRACE("ack: \(ack)")
        if ack == .accept {
            self.subscribe(topic: "\(self.userID)/power")
            self.subscribe(topic: "\(self.userID)/observation")
            currentAppState.setAppConnectionState(state: .connected)
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string.description), topic: \(message.topic.description)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        TRACE("id: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        TRACE("message: \(message.string.description), topic: \(message.topic.description)")
        currentAppState.setReceivedMessage(topic: message.topic.description, message: message.string.description)
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        TRACE("topic: \(topic)")
        currentAppState.setAppConnectionState(state: .connectedUnSubscribed)
    }

    func mqttDidPing(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        TRACE()
    }

    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        TRACE("\(err.description)")
        currentAppState.setAppConnectionState(state: .disconnected)
    }
}

extension MQTTManager {
    func TRACE(_ message: String = "", fun: String = #function) {
        let names = fun.components(separatedBy: ":")
        var prettyName: String
        if names.count == 1 {
            prettyName = names[0]
        } else {
            prettyName = names[1]
        }

        if fun == "mqttDidDisconnect(_:withError:)" {
            prettyName = "didDisconect"
        }

        print("[TRACE] [\(prettyName)]: \(message)")
    }
}

extension Optional {
    // Unwrap optional value for printing log only
    var description: String {
        if let wraped = self {
            return "\(wraped)"
        }
        return ""
    }
}
