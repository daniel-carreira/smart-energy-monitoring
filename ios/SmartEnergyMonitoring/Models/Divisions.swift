//
//  Divisions.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import Foundation

struct Divisions: Codable {
    var data: [Division]
}

struct Division: Codable, Identifiable {
    var id: Int
    var name: String
}
