//
//  AdminStats.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 31/12/2022.
//

import Foundation

struct AdminStatsUsers: Codable {
    var clients, producers, admins: Int
}

struct AdminStats: Codable {
    var observations, consumptions, alerts: Int
}
