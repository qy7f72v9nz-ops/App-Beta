//
//  WeekOverviewView.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import SwiftUI

struct WeekOverviewView: View {
    @EnvironmentObject var dataManager: OvertimeDataManager

    var body: some View {
        VStack(spacing: 12) {
            // Week Header
            HStack {
                Text(weekRangeText)
                    .font(.headline)
                    .foregroundColor(.secondary)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Weekly Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(weeklyTotal)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }

            // Days of Week with Totals
            HStack(spacing: 8) {
                ForEach(dataManager.getWeekDates(), id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(dayLetter(for: date))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        Text(dayNumber(for: date))
                            .font(.caption)
                            .fontWeight(isToday(date) ? .bold : .regular)

                        Text(dailyTotal(for: date))
                            .font(.caption2)
                            .foregroundColor(hasOvertime(for: date) ? .blue : .gray)
                            .fontWeight(hasOvertime(for: date) ? .semibold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isToday(date) ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isToday(date) ? Color.blue : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }

    private var weekRangeText: String {
        let dates = dataManager.getWeekDates()
        guard let first = dates.first, let last = dates.last else { return "" }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let firstStr = formatter.string(from: first)
        let lastStr = formatter.string(from: last)

        return "\(firstStr) - \(lastStr)"
    }

    private var weeklyTotal: String {
        let totalMinutes = dataManager.getCurrentWeekTotal()
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, mins)
        } else {
            return String(format: "%dm", mins)
        }
    }

    private func dayLetter(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }

    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private func dailyTotal(for date: Date) -> String {
        let entry = dataManager.getOrCreateEntry(for: date)
        let total = entry.totalMinutes

        if total == 0 {
            return "-"
        }

        let hours = total / 60
        let mins = total % 60

        if hours > 0 {
            return "\(hours)h\(mins > 0 ? " \(mins)m" : "")"
        } else {
            return "\(mins)m"
        }
    }

    private func hasOvertime(for date: Date) -> Bool {
        let entry = dataManager.getOrCreateEntry(for: date)
        return entry.totalMinutes > 0
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
