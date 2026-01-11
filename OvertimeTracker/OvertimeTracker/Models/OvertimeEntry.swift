//
//  OvertimeEntry.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import Foundation

struct OvertimeEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    var beforeContractedHours: Int // in minutes
    var afterContractedHours: Int // in minutes

    init(id: UUID = UUID(), date: Date, beforeContractedHours: Int = 0, afterContractedHours: Int = 0) {
        self.id = id
        self.date = date
        self.beforeContractedHours = beforeContractedHours
        self.afterContractedHours = afterContractedHours
    }

    var totalMinutes: Int {
        beforeContractedHours + afterContractedHours
    }

    var totalFormatted: String {
        formatMinutes(totalMinutes)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, mins)
        } else {
            return String(format: "%dm", mins)
        }
    }
}

struct WeekData: Identifiable {
    let id: UUID
    let weekStartDate: Date
    var entries: [OvertimeEntry]

    init(id: UUID = UUID(), weekStartDate: Date, entries: [OvertimeEntry] = []) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.entries = entries
    }

    var totalMinutes: Int {
        entries.reduce(0) { $0 + $1.totalMinutes }
    }

    var totalFormatted: String {
        formatMinutes(totalMinutes)
    }

    var weekEndDate: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
    }

    private func formatMinutes(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, mins)
        } else {
            return String(format: "%dm", mins)
        }
    }
}
