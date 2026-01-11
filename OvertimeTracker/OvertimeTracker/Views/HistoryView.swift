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
        NavigationView {
            List {
                let weeks = dataManager.getAllWeeks()

                if weeks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No History Available")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Start tracking your overtime to see history here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(weeks) { week in
                        WeekHistoryCard(week: week)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
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
        VStack(alignment: .leading, spacing: 12) {
            // Week Header
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(weekRange)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text("\(week.entries.count) day\(week.entries.count == 1 ? "" : "s") logged")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(week.totalFormatted)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
            }
            .buttonStyle(.plain)

            // Expanded Details
            if isExpanded {
                Divider()

                VStack(spacing: 8) {
                    ForEach(week.entries.sorted(by: { $0.date < $1.date })) { entry in
                        HStack {
                            Text(dayName(for: entry.date))
                                .font(.subheadline)
                                .frame(width: 80, alignment: .leading)

                            Text(dateFormatted(entry.date))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                if entry.beforeContractedHours > 0 {
                                    Text("Before: \(formatMinutes(entry.beforeContractedHours))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                if entry.afterContractedHours > 0 {
                                    Text("After: \(formatMinutes(entry.afterContractedHours))")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Text(entry.totalFormatted)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(width: 70, alignment: .trailing)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
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
