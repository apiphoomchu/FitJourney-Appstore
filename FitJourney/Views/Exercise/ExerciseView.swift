//
//  ExerciseView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 20/2/2567 BE.
//

import SwiftUI
import CoreData

struct ExerciseView: View {
    @AppStorage("bestStreak") private var bestStreak: Int = 0
    @AppStorage("currentStreak") private var currentStreak: Int = 0
    @ObservedObject var timerViewModel:TimerViewModel
    @StateObject var poseEstimator:PoseEstimator
    @AppStorage("userState") var userState: UserState = .normal
    @State private var isTimerPause = false
    @Binding var currentExercise: Exercise?
    @State private var isShowConfirmEndExercise = false
    @Binding var isExerciseViewPresented:Bool
    @Binding var isFinishExercise:Bool
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                CameraViewWrapper(poseEstimator: poseEstimator)
                StickFigureView(poseEstimator: poseEstimator, size: geo.size)
                VStack{
                    Spacer()
                    HStack{
                        Spacer()
                        VStack{
                            if(UIDevice.current.userInterfaceIdiom == .phone){
                                VStack(alignment: .leading){
                                    HStack{
                                        Image(systemName: "timer")
                                            .foregroundStyle(.yellow)
                                        Text(":")
                                        Text("\(timerViewModel.elapsedTimeStringShow)")
                                            .frame(width: 100 + CGFloat(Double(timerViewModel.elapsedTimeStringShow.count)), alignment: .leading)
                                        
                                        
                                    }
                                    .font(.title)
                                    Text("\(currentExercise!.calBurned.rawValue)")
                                        .font(.title)
                                }
                                .fontWeight(.semibold)
                                .padding(18)
                                .padding(.horizontal, 33)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                            }
                            HStack{
                                if(UIDevice.current.userInterfaceIdiom == .pad){
                                    VStack(alignment: .leading){
                                        HStack{
                                            Image(systemName: "timer")
                                                .foregroundStyle(.yellow)
                                            Text(":")
                                            Text("\(timerViewModel.elapsedTimeStringShow)")
                                                .frame(width: 200 + CGFloat(Double(timerViewModel.elapsedTimeStringShow.count)), alignment: .leading)
                                            
                                            
                                        }
                                        .font(.title)
                                        Text("\(currentExercise!.calBurned.rawValue)")
                                            .font(.title)
                                    }
                                    .fontWeight(.semibold)
                                    .padding(18)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(15)
                                }
                                
                                VStack(alignment: .leading){
                                    HStack{
                                        Text("\(String(format: "%.3f", poseEstimator.caloriesBurned))")
                                        Text("CAL")
                                            .font(.title2)
                                            .offset(y: -10)
                                            .foregroundStyle(userState == .normal ? .pink : .blue)
                                    }
                                    .font(.title)
                                    Text("\(currentExercise!.name): \(poseEstimator.exerciseCount)")
                                        .font(.title)
                                }
                                
                                .fontWeight(.semibold)
                                .padding(18)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                
                                VStack(alignment: .leading, spacing: 10){
                                    Button(action: {
                                        isTimerPause.toggle()
                                        if(isTimerPause){
                                            timerViewModel.pauseTimer()
                                            self.poseEstimator.stopCount()
                                        }else{
                                            timerViewModel.resumeTimer()
                                            self.poseEstimator.startCount()
                                        }
                                    }){
                                        ZStack{
                                            Circle()
                                                .fill(isTimerPause ? .green : .orange)
                                            Image(systemName: isTimerPause ? "play.fill" : "pause.fill")
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(.white)
                                        }.frame(width: 35, height: 35)
                                    }
                                    Button(action: {
                                        isShowConfirmEndExercise.toggle()
                                    }){
                                        
                                        ZStack{
                                            Circle()
                                                .fill(userState == .normal ? .red : .blue)
                                            Image(systemName: "xmark")
                                                .frame(width: 10, height: 10)
                                                .foregroundStyle(.white)
                                        }.frame(width: 35, height: 35)
                                    }
                                }
                                .fontWeight(.semibold)
                                .padding(18)
                                .background(.ultraThinMaterial)
                                .cornerRadius(15)
                                
                                
                            }.frame(width: geo.size.width - 50)
                        }
                        Spacer()
                    }
                    Spacer().frame(maxHeight: 50)
                    
                    
                }
            }
            .blur(radius: isFinishExercise ? 30 : 0)
            .animation(.easeInOut(duration: 0.5), value: isFinishExercise)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Summary")
                    .fontWeight(.bold)
                    .font(.title)
                exerciseIcon
                VStack(alignment: .leading, spacing: 14) {
                    Spacer().frame(maxHeight: 10)
                    Text("Workout Details")
                        .fontWeight(.bold)
                        .font(.title2)
                    GroupBox {
                        VStack(spacing: 6) {
                            HStack {
                                VStack {
                                    Text("Timing")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text(timerViewModel.elapsedTimeStringShow)
                                        .font(.title2)
                                        .foregroundStyle(.orange)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                VStack {
                                    Text("Count")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("\(poseEstimator.exerciseCount)")
                                        .font(.title2)
                                        .foregroundStyle(.teal)
                                        .fontWeight(.semibold)
                                }
                                Spacer()
                                VStack {
                                    Text("Calories Burns")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    Text("\(poseEstimator.caloriesBurned)")
                                        .font(.title2)
                                        .foregroundStyle(userState == .normal ? .red : .blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }.backgroundStyle(Color.clear)
                    Button(action: {
                        withAnimation{
                            timerViewModel.resetElapsedTimeString()
                            isTimerPause = false
                            isExerciseViewPresented = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Done")
                                .fontWeight(.bold)
                                .font(.title2)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(10)
                        .background(userState == .normal ? .pink : .blue)
                        .cornerRadius(15)
                    }
                }
            }
            .padding(30)
            .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 600 : 400)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .opacity(isFinishExercise ? 1 : 0)
            .animation(isFinishExercise ? .easeIn(duration: 0.5) : nil, value: isFinishExercise)
            
        }

        .alert("End Workout", isPresented: $isShowConfirmEndExercise, presenting: currentExercise) { _ in
            Button("Cancel", role: .cancel) {
            }
            Button("End", role: .destructive) {
                
                let activity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: CoreDataStack.shared.managedObjectContext) as! Activity
                timerViewModel.stopTimer()
                poseEstimator.stopCount()
                
                activity.time = Double(timerViewModel.elapsedTimeString) ?? 0.0
                activity.calories = poseEstimator.caloriesBurned
                activity.exerciseType = currentExercise?.name ?? ""
                activity.calBurnedType = currentExercise?.calBurned.rawValue ?? ""
                activity.activityCount = Int64(poseEstimator.exerciseCount)
                activity.dateAndTime = Date()
                
                do {
                    try CoreDataStack.shared.managedObjectContext.save()
                    print("Activity saved successfully!")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                
                do {
                    let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
                    
                    let activities = try CoreDataStack.shared.managedObjectContext.fetch(fetchRequest)
                    
                    for activity in activities {
                        print("""
                              Time: \(activity.time),
                              Calories: \(activity.calories),
                              Exercise Type: \(activity.exerciseType),
                              CalBurnedType: \(activity.calBurnedType),
                              Activity Count: \(activity.activityCount),
                              Date and Time: \(activity.dateAndTime)
                              """)
                    }
                    
                    if activities.isEmpty {
                        print("No activities found.")
                    }
                } catch {
                    print("Could not fetch activities: \(error)")
                }
                
                
                isFinishExercise = true
                
            }
        } message: { _ in
            Text("Are you sure you want to end the workout session?")
        }
    }
    
    private var exerciseIcon: some View {
        GroupBox {
            HStack {
                iconWithBackground
                Spacer().frame(maxWidth: 30)
                exerciseInfo
                Spacer()
            }
            .padding(.leading, 10)
        }   .backgroundStyle(Color.clear)
    }
    
    
    private var iconWithBackground: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [userState == .normal ? .pink : .blue, .black]), center: .center, startRadius: 2, endRadius: 300))
            Image(systemName: currentExercise!.symbolName)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .padding()
                .foregroundStyle(.white)
        }
        .frame(width: 60, height: 60)
    }
    
    private var exerciseInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currentExercise!.name)
                .font(.title)
                .fontWeight(.bold)
            bodyPartsUsed
            calorieBurned
        }
    }
    
    private var bodyPartsUsed: some View {
        HStack {
            ForEach(currentExercise!.bodyPartsUsed, id: \.self) { bodyPart in
                Text(bodyPart)
                    .font(.caption)
                    .padding(5)
                    .padding(.horizontal, 10)
                    .background(userState == .normal ? .pink.opacity(0.2) : .blue.opacity(0.2))
                    .cornerRadius(10)
                    .fontWeight(.medium)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(userState == .normal ? .red : .blue))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var calorieBurned: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundStyle(userState == .normal ? .red : .blue)
            Text("\(currentExercise!.calBurned.rawValue)")
                .fontWeight(.semibold)
        }
    }
}
