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

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Week Overview at Top
                    WeekOverviewView()
                        .padding(.horizontal)
                        .padding(.top)

                    Divider()
                        .padding(.vertical, 8)

                    // Daily Entries
                    VStack(spacing: 16) {
                        ForEach(dataManager.getWeekDates(), id: \.self) { date in
                            DayEntryCard(date: date)
                        }
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: { showingHistory = true }) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("View History")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            csvContent = dataManager.exportToCSV()
                            showingExport = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export to CSV")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: { showingClearAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear All Records")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Overtime Tracker")
            .navigationBarTitleDisplayMode(.inline)
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
