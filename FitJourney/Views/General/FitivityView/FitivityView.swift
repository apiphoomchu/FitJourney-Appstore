//
//  FitivityView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 20/2/2567 BE.
//

import SwiftUI
import CoreData

struct FitivityView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("userState") var userState: UserState = .normal
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var weekStore: WeekStore
    @State var showDatePicker: Bool = false
    @State private var activities: [Activity] = []
    @State private var dataPoints: [ActivityDataPoint] = []
    
    @AppStorage("goalMinute") private var goalMinute: Double = 0.0
    @AppStorage("goalCal") private var goalCal: Double = 0.0
    
    private var totalTime: Double {
        dataPoints.reduce(0) { $0 + $1.totalTimes } / 60
    }
    
    private var totalCalories: Double {
        dataPoints.reduce(0) { $0 + $1.calories }
    }

    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack(spacing: 25){
                    WeeksTabView() { week in
                        WeekView(week: week)
                    }
                    .frame(height: 60, alignment: .top)
                    if(UIDevice.current.userInterfaceIdiom == .pad){
                        HStack(spacing: 20){
                            Spacer()
                            activityRings
                            Divider()
                            mainContent
                            Spacer()
                        }
                    }else{
                        VStack(spacing: 20){
                            activityRings
                            mainContent
                        }
                    }
                    ActivityGraphView()
                }
            }   .navigationTitle("\(weekStore.selectedDate.monthToString()) \(weekStore.selectedDate.toString(format: "yyyy"))")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear{
                    fetchData()
                }
                .onChange(of: weekStore.selectedDate) { _ in
                    fetchData()
                }
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
                        .popover(isPresented: $showDatePicker) {
                                DatePicker("Select Date", selection: $weekStore.selectedDate)
                                    .datePickerStyle(GraphicalDatePickerStyle())
                                    .onChange(of: weekStore.selectedDate, perform: { _ in
                                        showDatePicker = false
                                    })
                                    .frame(width: 300)
                                    .accentColor(userState == .normal ? .red : .blue)
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
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: weekStore.selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(format: "dateAndTime >= %@ AND dateAndTime < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            let activities = try CoreDataStack.shared.managedObjectContext.fetch(fetchRequest)
            print("Fetched \(activities.count) results")
            self.dataPoints = activities.map { ActivityDataPoint(
                date: $0.dateAndTime,
                activityType: $0.exerciseType,
                time: $0.dateAndTime,
                calories: $0.calories,
                totalTimes: $0.time
            )}
        } catch {
            print("Error fetching activities: \(error), \(error.localizedDescription)")
            self.dataPoints = []
        }
    }
    
    var mainContent: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Active")
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text("\(totalTime, specifier: "%.0f") Mins")
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
            Divider().frame(height: 40)
            VStack(alignment: .leading) {
                Text("Burned")
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text("\(totalCalories, specifier: "%.0f") Cals")
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
            Divider().frame(height: 40)
            VStack(alignment: .leading) {
                Text("Goal")
                    .fontWeight(.semibold)
                    .font(.headline)
                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                Text("\((((goalMinute > 0.0 ? min(totalTime / goalMinute, 1.0) : 0.0) + (goalCal > 0.0 ? min(totalCalories / goalCal, 1.0 ) : 0.0))/2)*100, specifier: "%.0f") % active")
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
    }
    
    var activityRings: some View {
        let timeProgress = goalMinute > 0.0 ? min(totalTime / goalMinute, 1.0) : 0.0
        let calProgress = goalCal > 0.0 ? min(totalCalories / goalCal, 1.0 ) : 0.0
        let combinedProgress = (timeProgress + calProgress) / 2

        return HStack {
            if(UIDevice.current.userInterfaceIdiom == .pad){
                HStack(spacing: 30){
                    ActivityRingView(progress: timeProgress + 0.001, ringRadius: 100, thickness: 8, startColor: userState == .normal ? .red : .blue, endColor: userState == .normal ? .orange : .green, imageName: "figure.run")
                        .frame(width: 70, height: 70)
                    ActivityRingView(progress: calProgress + 0.001, ringRadius: 100, thickness: 8, startColor: .orange, endColor: .yellow, imageName: "flame.fill")
                        .frame(width: 70, height: 70)
                    ActivityRingView(progress: combinedProgress + 0.001, ringRadius: 100, thickness: 8, startColor: .purple, endColor: .pink, imageName: "trophy.fill")
                        .frame(width: 70, height: 70)
                }
            }else{
                HStack(spacing: 30){
                    ActivityRingView(progress: timeProgress + 0.001, ringRadius: 100, thickness: 8, startColor: userState == .normal ? .red : .blue, endColor: userState == .normal ? .orange : .green, imageName: "figure.run")
                        .frame(width: 60, height: 60)
                    ActivityRingView(progress: calProgress + 0.001, ringRadius: 100, thickness: 7, startColor: .orange, endColor: .yellow, imageName: "flame.fill")
                        .frame(width: 60, height: 60)
                    ActivityRingView(progress: combinedProgress + 0.001, ringRadius: 100, thickness: 7, startColor: .purple, endColor: .pink, imageName: "trophy.fill")
                        .frame(width: 60, height: 60)
                }
            }
        }
    }

    
    private var doneButton: some View {
        Button("Done") {
            dismiss()
        }.foregroundStyle(userState == .normal ? .red : .blue)
    }
}
