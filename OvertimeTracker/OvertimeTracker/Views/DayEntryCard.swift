//
//  DayEntryCard.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import SwiftUI

struct DayEntryCard: View {
    @EnvironmentObject var dataManager: OvertimeDataManager
    let date: Date

    @State private var beforeMinutes: Int = 0
    @State private var afterMinutes: Int = 0
    @State private var showingSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Day Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayName)
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(dateFormatted)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if totalMinutes > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(totalFormatted)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
            }

            Divider()

            // Before Contracted Hours
            VStack(alignment: .leading, spacing: 8) {
                Text("Before Contracted Hours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TimeInputView(minutes: $beforeMinutes, label: "Before")
            }

            // After Contracted Hours
            VStack(alignment: .leading, spacing: 8) {
                Text("After Contracted Hours")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TimeInputView(minutes: $afterMinutes, label: "After")
            }

            // Save Button
            Button(action: saveEntry) {
                HStack {
                    Image(systemName: showingSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    Text(showingSaved ? "Saved!" : "Save")
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(showingSaved ? Color.green : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .disabled(showingSaved)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .onAppear {
            loadEntry()
        }
    }

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }

    private var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }

    private var totalMinutes: Int {
        beforeMinutes + afterMinutes
    }

    private var totalFormatted: String {
        let hours = totalMinutes / 60
        let mins = totalMinutes % 60

        if hours > 0 {
            return String(format: "%dh %02dm", hours, mins)
        } else {
            return String(format: "%dm", mins)
        }
    }

    private func loadEntry() {
        let entry = dataManager.getOrCreateEntry(for: date)
        beforeMinutes = entry.beforeContractedHours
        afterMinutes = entry.afterContractedHours
    }

    private func saveEntry() {
        let entry = OvertimeEntry(
            date: date,
            beforeContractedHours: beforeMinutes,
            afterContractedHours: afterMinutes
        )
        dataManager.updateEntry(entry)

        withAnimation {
            showingSaved = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showingSaved = false
            }
        }
    }
}

struct TimeInputView: View {
    @Binding var minutes: Int
    let label: String

    @State private var showingPicker = false
    @State private var hours: Int = 0
    @State private var mins: Int = 0

    var body: some View {
        HStack(spacing: 12) {
            // Display Current Time
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.blue)
                Text(timeFormatted)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)

            // Edit Button
            Button(action: {
                hours = minutes / 60
                mins = minutes % 60
                showingPicker = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showingPicker) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Set Time")
                        .font(.headline)
                        .padding(.top)

                    HStack(spacing: 20) {
                        // Hours Picker
                        VStack {
                            Text("Hours")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Hours", selection: $hours) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                        }

                        // Minutes Picker
                        VStack {
                            Text("Minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("Minutes", selection: $mins) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)").tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 100)
                        }
                    }

                    Spacer()
                }
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingPicker = false
                    },
                    trailing: Button("Done") {
                        minutes = hours * 60 + mins
                        showingPicker = false
                    }
                )
            }
        }
    }

    private var timeFormatted: String {
        if minutes == 0 {
            return "0m"
        }

        let h = minutes / 60
        let m = minutes % 60

        if h > 0 {
            return String(format: "%dh %02dm", h, m)
        } else {
            return String(format: "%dm", m)
        }
    }
}
