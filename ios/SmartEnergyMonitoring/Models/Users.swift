//
//  Users.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import Foundation

struct Users: Codable {
    var data: [UserClass]
}

struct User: Codable {
    var data: UserClass
}

struct UserClass: Codable, Identifiable {
    var id: Int
    var name, email, birthdate: String
    var divisions: [Division]?
    var type, energyPrice: String
    var getStarted, notifications: Int
    var noActivityStart, noActivityEnd: String
    var locked: Int

    enum CodingKeys: String, CodingKey {
        case id, name, email, birthdate, divisions, type
        case energyPrice = "energy_price"
        case getStarted = "get_started"
        case notifications
        case noActivityStart = "no_activity_start"
        case noActivityEnd = "no_activity_end"
        case locked
    }
}

struct PutUser: Codable {
    let name: String
    let birthdate: String
    let noActivityStart: String?
    let noActivityEnd: String?
    let energyPrice: Float
    
    enum CodingKeys: String, CodingKey {
        case name, birthdate
        case energyPrice = "energy_price"
        case noActivityStart = "no_activity_start"
        case noActivityEnd = "no_activity_end"
    }
}
