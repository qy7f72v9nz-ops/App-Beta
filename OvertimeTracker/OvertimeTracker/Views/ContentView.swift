//
//  ContentView.swift
//  OvertimeTracker
//
//  Created on 2026-01-11
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataManager: OvertimeDataManager
    @State private var showingHistory = false
    @State private var showingExport = false
    @State private var showingClearAlert = false
    @State private var csvContent = ""
    @State private var selectedDay: Date?

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

            ScrollView {
                VStack(spacing: 24) {
                    // App Title
                    Text("OVERTIME TRACKER")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 50)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                    // Week Overview at Top
                    WeekOverviewView()
                        .padding(.horizontal)

                    // Daily Entries
                    VStack(spacing: 12) {
                        ForEach(dataManager.getWeekDates(), id: \.self) { date in
                            DayEntryCard(
                                date: date,
                                isSelected: Binding(
                                    get: { Calendar.current.isDate(selectedDay ?? Date(), inSameDayAs: date) },
                                    set: { isSelected in
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            if isSelected {
                                                selectedDay = date
                                            } else if Calendar.current.isDate(selectedDay ?? Date(), inSameDayAs: date) {
                                                selectedDay = nil
                                            }
                                        }
                                    }
                                )
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 14) {
                        Button(action: { showingHistory = true }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 18))
                                Text("View History")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button(action: {
                            csvContent = dataManager.exportToCSV()
                            showingExport = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18))
                                Text("Export to CSV")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.2)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button(action: { showingClearAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                Text("Clear All Records")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red.opacity(0.6), Color.red.opacity(0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
            .sheet(isPresented: $showingExport) {
                ShareSheet(items: [csvContent])
            }
            .alert("Clear All Records", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    dataManager.clearAllRecords()
                }
            } message: {
                Text("Are you sure you want to delete all overtime records? This action cannot be undone.")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(OvertimeDataManager())
    }
}
