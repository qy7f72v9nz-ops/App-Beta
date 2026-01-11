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
    @Binding var isSelected: Bool

    @State private var beforeMinutes: Int = 0
    @State private var afterMinutes: Int = 0
    @State private var showingSaved = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Day Header - Always Visible
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isSelected.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dayName)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text(dateFormatted)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    if totalMinutes > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("TOTAL")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .tracking(1)
                            Text(totalFormatted)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .rotationEffect(.degrees(isSelected ? 180 : 0))
                        .animation(.spring(response: 0.3), value: isSelected)
                }
                .padding()
            }

            // Expanded Content
            if isSelected {
                VStack(alignment: .leading, spacing: 20) {
                    Divider()
                        .background(Color.white.opacity(0.3))
                        .padding(.horizontal)

                    // Before Contracted Hours
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Before Contracted Hours")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        TimeInputView(minutes: $beforeMinutes, label: "Before")
                            .padding(.horizontal)
                    }

                    // After Contracted Hours
                    VStack(alignment: .leading, spacing: 12) {
                        Text("After Contracted Hours")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        TimeInputView(minutes: $afterMinutes, label: "After")
                            .padding(.horizontal)
                    }

                    // Save Button
                    Button(action: saveEntry) {
                        HStack(spacing: 10) {
                            Image(systemName: showingSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                                .font(.system(size: 18))
                            Text(showingSaved ? "Saved!" : "Save Overtime")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            showingSaved
                                ? LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                : LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.35), Color.white.opacity(0.25)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .disabled(showingSaved)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isSelected
                        ? LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.6, green: 0.3, blue: 1.0),
                                Color(red: 0.4, green: 0.5, blue: 1.0)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            gradient: Gradient(colors: [Color.white.opacity(0.25), Color.white.opacity(0.15)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                )
                .shadow(color: Color.black.opacity(isSelected ? 0.25 : 0.1), radius: isSelected ? 12 : 5, x: 0, y: isSelected ? 6 : 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(isSelected ? 0.5 : 0.2), lineWidth: isSelected ? 2 : 1)
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
        formatter.dateFormat = "MMMM d"
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
            HStack(spacing: 10) {
                Image(systemName: "clock.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                Text(timeFormatted)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )

            // Edit Button
            Button(action: {
                hours = minutes / 60
                mins = minutes % 60
                showingPicker = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
        }
        .sheet(isPresented: $showingPicker) {
            NavigationView {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.2, blue: 0.8),
                            Color(red: 0.3, green: 0.5, blue: 0.95)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    VStack(spacing: 30) {
                        Text("Set Time")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.top, 40)

                        HStack(spacing: 30) {
                            // Hours Picker
                            VStack(spacing: 12) {
                                Text("HOURS")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1.5)
                                Picker("Hours", selection: $hours) {
                                    ForEach(0..<24) { hour in
                                        Text("\(hour)")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .tag(hour)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 120, height: 180)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }

                            // Minutes Picker
                            VStack(spacing: 12) {
                                Text("MINUTES")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                                    .tracking(1.5)
                                Picker("Minutes", selection: $mins) {
                                    ForEach(0..<60) { minute in
                                        Text("\(minute)")
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                                            .tag(minute)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 120, height: 180)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }

                        Spacer()

                        HStack(spacing: 16) {
                            Button("Cancel") {
                                showingPicker = false
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.white.opacity(0.2))
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )

                            Button("Done") {
                                minutes = hours * 60 + mins
                                showingPicker = false
                            }
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.4), Color.white.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
                .navigationBarHidden(true)
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
