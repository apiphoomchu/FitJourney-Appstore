import SwiftUI
import CoreData
import Charts

struct ActivityGraphWeekView: View {
    @EnvironmentObject var weekStore: WeekStore
    @Environment(\.managedObjectContext) private var viewContext
    @State private var dataPoints: [ActivityDataPoint] = []
    
    @AppStorage("goalMinute") private var goalMinute: Double = 0.0
    @AppStorage("goalCal") private var goalCal: Double = 0.0
    @AppStorage("userState") var userState: UserState = .normal
    
    private var totalTime: Double {
        dataPoints.reduce(0) { $0 + $1.totalTimes }
    }
    
    private var totalCalories: Double {
        dataPoints.reduce(0) { $0 + $1.calories }
    }
    
    
    private var activities: [ActivityDataPoint] {
        dataPoints
    }
    
    var body: some View {
        VStack(spacing: 20) {
            GroupBox(label: Text("Total Time Exercised (in Week)")) {
                HStack {
                    Text("\(totalTime / 60, specifier: "%.2f") of \(goalMinute, specifier: "%.2f") Minutes")
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                }
                GraphViewWeek(data: dataPoints, valueType: .totalTime)
                    .frame(height: 130)
            }
            GroupBox(label: Text("Calories Burned (in Week)")) {
                HStack {
                    Text("\(totalCalories, specifier: "%.0f") of \(goalCal, specifier: "%.0f") cals")
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                }
                GraphViewWeek(data: dataPoints, valueType: .calories)
                    .frame(height: 130)
            }
            GroupBox(label: Text("Your Fitivty (in week)")) {
                if(!dataPoints.isEmpty){
                    List {
                        ForEach(dataPoints.sorted(by: { $0.date > $1.date })) { activity in
                            HStack {
                                Text(activity.activityType)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("Time: \(activity.totalTimes / 60, specifier: "%.0f") mins")
                                Text("Calories: \(activity.calories, specifier: "%.0f")")
                            }
                            .onAppear {
                                print("asasasas \(activity)")
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.white.opacity(0))
                        }
                        .padding(0)
                    }
                    .listStyle(.plain)
                    .background(.ultraThinMaterial.opacity(0))
                    .frame(height: 300)
                }else{
                    Text("No data available for this period")
                        .font(.body)
                        .fontWeight(.medium)
                        .padding()
                }
            }
            
            
        }
        .onAppear{
            fetchData()
        }
        .onChange(of: weekStore.selectedDate) { _ in
            fetchData()
        }
    }
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: weekStore.selectedDate))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        fetchRequest.predicate = NSPredicate(format: "dateAndTime >= %@ AND dateAndTime <= %@", startOfWeek as NSDate, endOfWeek as NSDate)
        
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

}

struct GraphViewWeek: View {
    var data: [ActivityDataPoint]
    var valueType: ValueType
    @AppStorage("userState") var userState: UserState = .normal
    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No data available for this period")
                    .font(.body)
                    .fontWeight(.medium)
                    .padding()
            } else {
                Chart(data) { point in
                    switch valueType {
                    case .totalTime:
                        BarMark(
                            x: .value("Date", point.time, unit: .day),
                            y: .value("Total Time", point.totalTimes / 60)
                        )
                    case .calories:
                        BarMark(
                            x: .value("Date", point.time, unit: .day),
                            y: .value("Calories", point.calories)
                        )
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.day().month())
                    }
                }
                .chartYAxis {
                    AxisMarks()
                }
                .foregroundStyle(userState == .normal ? .red : .blue)
            }
        }
    }
}


