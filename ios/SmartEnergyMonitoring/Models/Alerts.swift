//
//  Alerts.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import Foundation

struct Alerts: Codable {
    var data: [Alert]
}

struct Alert: Codable, Identifiable {
    var id, userID: Int
    var alert, timestamp: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case alert, timestamp
    }
}
