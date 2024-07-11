//
//  UserStats.swift
//  SmartEnergyMonitoring
//
//  Created by Fábio Cordeiro Gaspar on 24/11/2022.
//

import Foundation

struct UserStat: Codable {
    let timestamp, value: String
    
    func toUserStatData() -> UserStatData {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: self.timestamp) ?? Date.now
        return UserStatData(consumption: Double(value)!, timestamp: date)
    }
}

typealias UserStats = [UserStat]

struct UserStatData: Identifiable {
    let id = UUID()
    let consumption: Double
    let timestamp: Date
    
    init(consumption: Double, timestamp: Date) {
        self.consumption = consumption
        self.timestamp = timestamp
    }
}
