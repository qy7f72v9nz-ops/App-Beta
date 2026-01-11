//
//  OvertimeDataManager.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import Foundation
import Combine

class OvertimeDataManager: ObservableObject {
    @Published var entries: [OvertimeEntry] = []

    private let saveKey = "OvertimeEntries"

    init() {
        loadEntries()
    }

    // MARK: - Current Week Operations

    func getCurrentWeekEntries() -> [OvertimeEntry] {
        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start else {
            return []
        }

        // Adjust to Monday start
        let mondayStart = getMondayOfWeek(for: weekStart)
        let sundayEnd = calendar.date(byAdding: .day, value: 6, to: mondayStart)!

        return entries.filter { entry in
            entry.date >= mondayStart && entry.date <= sundayEnd
        }.sorted { $0.date < $1.date }
    }

    func getOrCreateEntry(for date: Date) -> OvertimeEntry {
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)

        if let existing = entries.first(where: { calendar.isDate($0.date, inSameDayAs: normalizedDate) }) {
            return existing
        }

        let newEntry = OvertimeEntry(date: normalizedDate)
        return newEntry
    }

    func updateEntry(_ entry: OvertimeEntry) {
        let calendar = Calendar.current

        if let index = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }

        saveEntries()
    }

    func deleteEntry(for date: Date) {
        let calendar = Calendar.current
        entries.removeAll { calendar.isDate($0.date, inSameDayAs: date) }
        saveEntries()
    }

    // MARK: - Week History

    func getAllWeeks() -> [WeekData] {
        let calendar = Calendar.current
        var weekDict: [Date: [OvertimeEntry]] = [:]

        for entry in entries {
            let weekStart = getMondayOfWeek(for: entry.date)
            if weekDict[weekStart] == nil {
                weekDict[weekStart] = []
            }
            weekDict[weekStart]?.append(entry)
        }

        return weekDict.map { WeekData(weekStartDate: $0.key, entries: $0.value) }
            .sorted { $0.weekStartDate > $1.weekStartDate }
    }

    func getCurrentWeekTotal() -> Int {
        getCurrentWeekEntries().reduce(0) { $0 + $1.totalMinutes }
    }

    // MARK: - Data Management

    func clearAllRecords() {
        entries = []
        saveEntries()
    }

    func exportToCSV() -> String {
        var csv = "Date,Day,Before Contracted (mins),After Contracted (mins),Total (mins)\n"

        let sortedEntries = entries.sorted { $0.date < $1.date }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"

        for entry in sortedEntries {
            let dateStr = dateFormatter.string(from: entry.date)
            let dayStr = dayFormatter.string(from: entry.date)
            csv += "\(dateStr),\(dayStr),\(entry.beforeContractedHours),\(entry.afterContractedHours),\(entry.totalMinutes)\n"
        }

        return csv
    }

    // MARK: - Persistence

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([OvertimeEntry].self, from: data) {
            entries = decoded
        }
    }

    // MARK: - Helper Methods

    private func getMondayOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)

        var mondayComponents = DateComponents()
        mondayComponents.yearForWeekOfYear = components.yearForWeekOfYear
        mondayComponents.weekOfYear = components.weekOfYear
        mondayComponents.weekday = 2 // Monday

        return calendar.date(from: mondayComponents) ?? date
    }

    func getWeekDates() -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = getMondayOfWeek(for: now)

        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
    }
}
