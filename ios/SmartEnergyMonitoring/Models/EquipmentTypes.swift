//
//  EquipmentTypes.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import Foundation

struct EquipmentTypes: Codable {
    var data: [EquipmentType]
}

struct EquipmentType: Codable, Identifiable {
    var id: Int
    var name: String
    var activity: Activity
}

enum Activity: String, Codable {
    case No = "No"
    case Yes = "Yes"
}
