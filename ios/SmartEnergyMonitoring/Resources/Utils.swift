//
//  Utils.swift
//  SmartEnergyMonitoring
//
//  Created by Daniel Soares Carreira on 27/12/2022.
//
import SwiftUI

func stringDateToPrettyStringDate(_ string: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'.000000Z'"
    let date = formatter.date(from: string)
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date!)
}

func unixTimestampToFormatedString(_ timestamp: Int?) -> String {
    guard timestamp != nil else { return "" }
    let date = Date(timeIntervalSince1970: Double(timestamp!))
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter.string(from: date)
}

func dateToFormatedString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM yyyy"
    return formatter.string(from: date)
}

func prettyTimeFromDateToNow(_ date: Date) -> String {
    let now = Date.now
    let diff = now.timeIntervalSince(date)
    
    return diff.description
}
