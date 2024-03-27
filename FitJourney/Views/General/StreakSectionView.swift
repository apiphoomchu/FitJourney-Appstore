import SwiftUI
import CoreData

struct StreakSectionView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("bestStreak") private var bestStreak: Int = 0
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @State private var mostactiveday = ""
    @State private var mostactivedayfreq = 0
    @State private var achievedDays: [Int] = []
    @State private var activities: [Activity] = []
    @State private var dataPoints: [ActivityDataPoint] = []

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        HStack{
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Exercises This Week")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                Text("This week you exercise \(dataPoints.count) times!")
                                    .fontWeight(.medium)
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                        }
                        StreakView(days: ["S","M", "T", "W", "T", "F", "S"], currentStreak: currentStreak, bestStreak: bestStreak, achievedDays: Array(Set(achievedDays)))
                            .frame(height: 70)
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("Most active day is \(mostactiveday)")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.gray)
                    }
                    Spacer()
                }
            }
            .onAppear{
                fetchData()
            }
            .padding(.vertical, 20)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 10 : 1)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .frame(maxHeight: .infinity)
        }
    }


    func fetchData() {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        fetchRequest.predicate = NSPredicate(format: "dateAndTime >= %@ AND dateAndTime <= %@", startOfWeek as NSDate, endOfWeek as NSDate)
        
        do {
            let activities = try CoreDataStack.shared.managedObjectContext.fetch(fetchRequest)
            print("Fetched \(activities.count) results")

            let groupedActivities = Dictionary(grouping: activities, by: { (activity: Activity) -> Int in
                let weekDay = calendar.component(.weekday, from: activity.dateAndTime)
                return weekDay
            })

            let mostActiveDay = groupedActivities.max(by: { $0.value.count < $1.value.count })?.key
            let mostActiveDayName = mostActiveDay.flatMap { calendar.weekdaySymbols[$0 - 1] }
            let mostActiveDayAdjusted = mostActiveDay.map { $0 - 1 }
            
            mostactiveday = mostActiveDayName ?? "Sunday"
            mostactivedayfreq = groupedActivities[mostActiveDay ?? 0]?.count ?? 0
            achievedDays.append(mostActiveDayAdjusted ?? 0)
            
            print("Most active day: \(mostActiveDayName ?? "Unknown") with \(groupedActivities[mostActiveDay ?? 0]?.count ?? 0) activities")
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

struct StreakView: View {
    var days: [String]
    var currentStreak: Int
    var bestStreak: Int
    var achievedDays: [Int]
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            ForEach(0..<days.count, id: \.self) { index in
                DayView(day: days[index],
                        isAchieved: achievedDays.contains(index),
                        colorScheme: colorScheme)
            }
        }
    }
}

struct DayView: View {
    var day: String
    var isAchieved: Bool
    var colorScheme: ColorScheme
    @AppStorage("userState") var userState: UserState = .normal

    var body: some View {
        VStack {
            Text(day)
                .foregroundColor(colorScheme == .dark ? (isAchieved ? .white : .black) : .black)
                .fontWeight(.semibold)
            Image(systemName: isAchieved ? "star.fill" : "star")
                .foregroundColor(isAchieved ? userState == .normal ? .red : .blue : .gray)
        }
        .padding(8)
        .background(isAchieved ? userState == .normal ? .red.opacity(0.3) : .blue.opacity(0.3) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10).stroke(isAchieved ? userState == .normal ? .red : .blue : Color.gray, lineWidth: 2)
        )
    }
}
