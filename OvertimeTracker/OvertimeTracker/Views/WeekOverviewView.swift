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
        VStack(spacing: 16) {
            // Week Header
            HStack {
                Text(weekRangeText)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("WEEKLY TOTAL")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .tracking(1)
                    Text(weeklyTotal)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
            }

            // Days of Week with Totals
            HStack(spacing: 6) {
                ForEach(dataManager.getWeekDates(), id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(dayLetter(for: date))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white.opacity(0.9))

                        Text(dayNumber(for: date))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)

                        Text(dailyTotal(for: date))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(hasOvertime(for: date) ? 1.0 : 0.5))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isToday(date)
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.25)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.1)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(isToday(date) ? 0.5 : 0.2), lineWidth: 1.5)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
