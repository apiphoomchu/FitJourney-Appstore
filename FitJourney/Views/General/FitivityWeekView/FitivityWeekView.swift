//
//  FitivityView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 20/2/2567 BE.
//

import SwiftUI
import CoreData

struct FitivityWeekView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("userState") var userState: UserState = .normal
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weekStore: WeekStore
    @State var showDatePicker: Bool = false
    @State private var activities: [Activity] = []
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 25){
                    WeeksTabView() { week in
                        WeekView(week: week)
                    }
                    .frame(height: 60, alignment: .top)
                    ActivityGraphWeekView()
                }
            }   .navigationTitle("\(weekStore.selectedDate.monthToString()) \(weekStore.selectedDate.toString(format: "yyyy"))")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        doneButton
                    }
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            showDatePicker = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .sheet(isPresented: $showDatePicker) {
                            VStack {
                                DatePicker("Select Date", selection: $weekStore.selectedDate)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .cornerRadius(15)
                                    .shadow(color: .black, radius: 5)
                                    .padding()
                                    .presentationDetents([.height(400), .fraction(20), .medium, .large])
                                    .onChange(of: weekStore.selectedDate, perform: { _ in
                                        showDatePicker = false
                                    })
                            }
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            withAnimation {
                                weekStore.selectToday()
                            }
                        } label: {
                            Text("Today")
                                .font(.system(size: 14))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(7)
                                .background(userState == .normal ? .red.opacity(0.5) : .blue.opacity(0.5))
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10)
        }
    }
    
    private var doneButton: some View {
        Button("Done") {
            dismiss()
        }.foregroundStyle(userState == .normal ? .red : .blue)
    }
}
