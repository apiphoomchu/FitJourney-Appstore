import SwiftUI
import Charts
import CoreData

struct ContentView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("userHeight") var userHeightPers: Int = 0
    @AppStorage("userWeight") var userWeightPers: Int = 0
    @AppStorage("userState") var userState: UserState = .normal
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("goalMinute") private var goalMinute: Double = 0.0
    @AppStorage("goalCal") private var goalCal: Double = 0.0
    @State private var isShowFitivitySummary = false
    @State private var isShowFitivitySummaryWeek = false
    @State private var isExerciseViewPresented = false
    @State private var isShowSetting = false
    @State private var timerCount = 15
    @State private var timerStart = false
    @State private var isFinishExercise = false
    @State private var showTimer = false
    @State private var cameraAccessGranted: Bool = false
    @State private var isShowTutorials = false
    @StateObject var poseEstimator = PoseEstimator()
    @State private var chartData:[ChartDataPoint] = []
    
    @State private var dataPoints: [ActivityDataPoint] = []
    private var totalTime: Double {
        dataPoints.reduce(0) { $0 + $1.totalTimes / 60 }
    }
    
    private var totalCalories: Double {
        dataPoints.reduce(0) { $0 + $1.calories }
    }
    
    
    @State var selectedExercise: Exercise?
    @State var currentExercise: Exercise?
    @State private var showingDetail = false
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject var timerViewModel = TimerViewModel()
    
    
    let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 20), count: UIDevice.current.userInterfaceIdiom == .pad ? 2 : 1)
    
    
    var body: some View {
        if(isExerciseViewPresented){
            ZStack{
                ExerciseView(timerViewModel: timerViewModel, poseEstimator: poseEstimator, currentExercise: $currentExercise, isExerciseViewPresented: $isExerciseViewPresented, isFinishExercise: $isFinishExercise)
                CircleTimer(start: $timerStart, count: $timerCount, defaultTime: 5)
                    .background(.ultraThinMaterial)
                    .opacity(showTimer ? 1 : 0)
                    .onAppear {
                        self.timerStart = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                self.showTimer = false
                                self.poseEstimator.startCount()
                                timerViewModel.startTimer()
                            }
                            self.timerStart = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.timerCount = 5
                            }
                        }
                    }
            }.onAppear{
                showTimerOverlay()
            }
        }else{
            ZStack{
                GeometryReader { geometry in
                    ScrollView {
                        greetingSection
                        VStack {
                            if(UIDevice.current.userInterfaceIdiom == .pad){
                                HStack(spacing: 20) {
                                    workoutSection
                                        .frame(maxWidth: 300)
                                    if geometry.size.width > 1023 {
                                        landscapeAdditionalContent
                                        
                                    }
                                    StreakSectionView()
                                        .frame(minWidth: 370)
                                }
                                .frame(maxWidth: .infinity)
                                if geometry.size.width < 1023 {
                                    landscapeAdditionalContent
                                        .padding(.vertical, 10)
                                }
                            }else{
                                VStack(spacing: 20){
                                    workoutSection
                                    StreakSectionView()
                                        .frame(height: 200)
                                    landscapeAdditionalContent
                                        .padding(.top,10)
                                }
                            }
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(userState == .normal ? "Fitivity Classic" : "Fitivity Lite")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                }
                                Spacer()
                            }
                            .padding(.top)
                            if(userState == .normal){
                                exerciseHard
                            }else{
                                exerciseLight
                            }
                            Spacer().frame(height: 30)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(userState == .normal ? "Fitivity Lite" : "Fitivity Classic")
                                        .font(.system(size: 30))
                                        .fontWeight(.bold)
                                }
                                Spacer()
                            }
                            if(userState == .normal){
                                exerciseLight
                            }else{
                                exerciseHard
                            }
                        }
                    }
                    .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 30 : 20)
                    .padding(.top, 35)
                    .padding(.vertical, 30)
                    .font(.system(.body, design: .rounded))
                    .blur(radius: isFirstLaunch ? 30 : 0)
                    .disabled(isFirstLaunch)
                    .animation(.easeOut(duration: 0.8), value: isFirstLaunch)
                    .sheet(isPresented: $isShowSetting){
                        SettingView()
                    }
                    .sheet(isPresented: $isShowFitivitySummary){
                        FitivityView()
                    }
                    .sheet(isPresented: $isShowFitivitySummaryWeek){
                        FitivityWeekView()
                    }
                }
                OnBoardView()
            }
            .onAppear{
                fetchData()
                fetchDataWeek()
                CameraManager.requestCameraAccess { granted in
                             self.cameraAccessGranted = granted
                         }
            }
        }
    }
    
    var exerciseHard: some View {
        LazyVGrid(columns: columns,  spacing: 20) {
            ForEach(exercises) { exercise in
                Button(action: {
                    self.selectedExercise = exercise
                    self.showingDetail = true
                    self.currentExercise = exercise
                    self.poseEstimator.updateCurrentExercise(to: currentExercise!.name)
                    isFinishExercise = false
                }) {
                    VStack {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(RadialGradient(gradient: Gradient(colors: [userState == .normal ? .pink : Color("FitBlue"), userState == .normal ? Color("FitRed").opacity(0.5) : Color(.blue).opacity(0.5)]), center: .center, startRadius: 2, endRadius: 35))
                                Image(systemName: exercise.symbolName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .padding()
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 60, height: 60)
                            Spacer().frame(maxWidth: 30)
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(userState == .normal ? .red : Color("FitBlue"))
                                    Text(exercise.calBurned.rawValue)
                                }
                            }
                            .frame(width: 200, alignment: .leading)
                            Image(systemName: "chevron.right")
                        }
                        HStack {
                            ForEach(exercise.bodyPartsUsed, id: \.self) { bodyPart in
                                Text(bodyPart)
                                    .font(.caption)
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .background(userState == .normal ? .red.opacity(0.2) : .blue.opacity(0.2))
                                    .cornerRadius(10)
                                    .fontWeight(.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16).stroke(userState == .normal ? .red : .blue)
                                    )
                            }
                        }
                        .padding(.top, 2)
                        .frame(width: 300, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }.sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise, isExerciseViewPresented: $isExerciseViewPresented)
        }
        
    }
    
    var exerciseLight: some View {
        LazyVGrid(columns: columns,  spacing: 20) {
            ForEach(exerciselight) { exercise in
                Button(action: {
                    self.selectedExercise = exercise
                    self.showingDetail = true
                    self.currentExercise = exercise
                    self.poseEstimator.updateCurrentExercise(to: currentExercise!.name)
                    isFinishExercise = false
                }) {
                    VStack {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(RadialGradient(gradient: Gradient(colors: [userState == .normal ? .pink : Color("FitBlue"), userState == .normal ? Color("FitRed").opacity(0.5) : Color(.blue).opacity(0.5)]), center: .center, startRadius: 2, endRadius: 35))
                                Image(systemName: exercise.symbolName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                    .padding()
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 60, height: 60)
                            Spacer().frame(maxWidth: 30)
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .fontWeight(.semibold)
                                    .font(.title2)
                                HStack {
                                    Image(systemName: "flame.fill")
                                        .foregroundStyle(userState == .normal ? .red : Color("FitBlue"))
                                    Text(exercise.calBurned.rawValue)
                                }
                            }
                            .frame(width: 200, alignment: .leading)
                            Image(systemName: "chevron.right")
                        }
                        HStack {
                            ForEach(exercise.bodyPartsUsed, id: \.self) { bodyPart in
                                Text(bodyPart)
                                    .font(.caption)
                                    .padding(5)
                                    .padding(.horizontal, 10)
                                    .background(userState == .normal ? .red.opacity(0.2) : .blue.opacity(0.2))
                                    .cornerRadius(10)
                                    .fontWeight(.medium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16).stroke(userState == .normal ? .red : .blue)
                                    )
                            }
                        }
                        .padding(.top, 2)
                        .frame(width: 300, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(15)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }.sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise, isExerciseViewPresented: $isExerciseViewPresented)
        }
    }
    
    var greetingSection: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Hi \(username)")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                Text("Let's begin our workout")
                    .foregroundStyle(.gray)
            }
            Spacer()
            
            Button(action:{
                isShowSetting.toggle()
            }){
                ZStack{
                    Circle()
                        .frame(width: 45, height: 45)
                        .foregroundStyle(.gray)
                    Text(username.prefix(1))
                        .foregroundStyle(.white)
                        .font(.title2)
                        .fontWeight(.semibold)
                    ZStack{
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                        Image(systemName: "gear.circle.fill")
                            .foregroundStyle(.gray)
                            .frame(width: 13, height: 13)
                        
                    }          .offset(x:15, y:20)
                }
            }
            Spacer().frame(maxWidth: 20)
        }
        .padding(.top)
    }
    
    var workoutSection: some View {
        Button(action: {
            isShowFitivitySummary.toggle()
        }){
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "figure.run")
                        .font(.system(size: 25))
                        .foregroundStyle(userState == .normal ? .red : Color("FitBlue"))
                    Text("Today Fitivity")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(userState == .normal ? .red : Color("FitBlue"))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .frame(width: 10, height: 10)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                contentLayout
                
            }
            .padding(15)
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .frame(maxHeight: .infinity)
        }
        
    }
    
    var contentLayout: some View {
        VStack {
            if(UIDevice.current.userInterfaceIdiom == .pad){
                VStack{
                    mainContent
                    activityRings
                }
            }else{
                HStack{
                    mainContent
                    Spacer()
                    activityRings
                }
            }
        }
        .frame(minHeight: 0, maxHeight: .infinity, alignment: .top)
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
    func fetchData() {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
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
    
    
    func fetchDataWeek() {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        fetchRequest.predicate = NSPredicate(format: "dateAndTime >= %@ AND dateAndTime <= %@", startOfWeek as NSDate, endOfWeek as NSDate)
        
        do {
            let activities = try CoreDataStack.shared.managedObjectContext.fetch(fetchRequest)
            var caloriesByDay: [Int: Double] = [:]
            
            for activity in activities {
                let dayOfWeek = calendar.component(.weekday, from: activity.dateAndTime)
                caloriesByDay[dayOfWeek, default: 0] += activity.calories
            }
            let daysOfWeek = calendar.shortWeekdaySymbols
            chartData = daysOfWeek.enumerated().map { (index, day) -> ChartDataPoint in
                let dayOfWeek = index + 1
                let calories = caloriesByDay[dayOfWeek] ?? 0
                return ChartDataPoint(day: day, value: Int(calories))
            }
            
        } catch {
            print("Error fetching activities: \(error)")
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
                ZStack{
                    ActivityRingView(progress: timeProgress + 0.001, ringRadius: 100, thickness: 8, startColor: userState == .normal ? .red : .blue, endColor: userState == .normal ? .orange : .green, imageName: "")
                        .frame(width: 60, height: 60)
                    ActivityRingView(progress: calProgress + 0.001, ringRadius: 20, thickness: 7, startColor: .orange, endColor: .yellow, imageName: "")
                        .frame(width: 60, height: 60)
                    ActivityRingView(progress: combinedProgress + 0.001, ringRadius: 10, thickness: 7, startColor: .purple, endColor: .pink, imageName: "")
                        .frame(width: 60, height: 60)
                }
            }
        }
    }
    
    
    var landscapeAdditionalContent: some View {
        Button(action: {
            isShowFitivitySummaryWeek.toggle()
        }){
            VStack(alignment: .leading) {
                HStack{
                    Text("Weekly Summary")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .frame(width: 10, height: 10)
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                }
                Text("Your weekly insights.")
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .black.opacity(0.6))
                Chart(chartData) { dataPoint in
                    LineMark(
                        x: .value("Day", dataPoint.day),
                        y: .value("Value", dataPoint.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(userState == .normal ? .red : .blue)
                }
                .onAppear {
                    fetchData()
                }
                
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(15)
            .frame(maxHeight: .infinity)
        }
        
    }
    
    private func showTimerOverlay() {
        timerCount = 5
        showTimer = true
    }
    
}


struct ChartDataPoint: Identifiable {
    let id = UUID()
    var day: String
    var value: Int
}

struct CustomBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .stroke(Color.primary, lineWidth:2)
            )
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
