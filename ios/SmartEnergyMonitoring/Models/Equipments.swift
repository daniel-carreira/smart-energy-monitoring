//
//  Equipments.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import Foundation

struct Equipments: Codable {
    var data: [Equipment]
}

struct Equipment: Codable, Identifiable {
    var id, userID: Int
    var name: String
    var division: Int
    var divisionName: String
    var type: Int
    var typeName, consumption, activity: String
    var equipmentTypeID, examples: Int
    var initStatusOn: String?
    var notifyWhenPassed: Int?
    var socket: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name, division
        case divisionName = "division_name"
        case type
        case typeName = "type_name"
        case consumption, activity
        case equipmentTypeID = "equipment_type_id"
        case examples
        case initStatusOn = "init_status_on"
        case notifyWhenPassed = "notify_when_passed"
        case socket
    }
}

struct DivisionShort: Codable, Identifiable, Hashable {
    var id: Int
    var name: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct EquipmentShort: Codable, Identifiable {
    var id: Int
    var name, consumption, type, activity, division: String
}

struct PostEquipment: Codable {
    var name, activity: String
    var consumption, equipmentTypeId, divisionId, standby: Int
    
    enum CodingKeys: String, CodingKey {
        case name
        case activity
        case consumption
        case standby
        case divisionId = "division_id"
        case equipmentTypeId = "equipment_type_id"
    }
}
