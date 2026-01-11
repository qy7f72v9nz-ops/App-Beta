//
//  HistoryView.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: OvertimeDataManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.4, green: 0.2, blue: 0.8),
                    Color(red: 0.2, green: 0.4, blue: 0.9),
                    Color(red: 0.3, green: 0.6, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Text("HISTORY")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                }
                .padding()
                .background(Color.clear)

                ScrollView {
                    let weeks = dataManager.getAllWeeks()

                    if weeks.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 70))
                                .foregroundColor(.white.opacity(0.6))
                            Text("No History Available")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("Start tracking your overtime to see history here")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 100)
                    } else {
                        VStack(spacing: 14) {
                            ForEach(weeks) { week in
                                WeekHistoryCard(week: week)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct WeekHistoryCard: View {
    let week: WeekData
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Week Header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weekRange)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("\(week.entries.count) day\(week.entries.count == 1 ? "" : "s") logged")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("TOTAL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        Text(week.totalFormatted)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .padding(.leading, 8)
                }
                .padding()
            }
            .buttonStyle(.plain)

            // Expanded Details
            if isExpanded {
                VStack(spacing: 12) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal)

                    VStack(spacing: 10) {
                        ForEach(week.entries.sorted(by: { $0.date < $1.date })) { entry in
                            HStack {
                                Text(dayName(for: entry.date))
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 90, alignment: .leading)

                                Text(dateFormatted(entry.date))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))

                                Spacer()

                                VStack(alignment: .trailing, spacing: 3) {
                                    if entry.beforeContractedHours > 0 {
                                        Text("Before: \(formatMinutes(entry.beforeContractedHours))")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    if entry.afterContractedHours > 0 {
                                        Text("After: \(formatMinutes(entry.afterContractedHours))")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }

                                Text(entry.totalFormatted)
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 70, alignment: .trailing)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }

    private var weekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let start = formatter.string(from: week.weekStartDate)
        let end = formatter.string(from: week.weekEndDate)

        return "\(start) - \(end)"
    }

    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private func dateFormatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
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
