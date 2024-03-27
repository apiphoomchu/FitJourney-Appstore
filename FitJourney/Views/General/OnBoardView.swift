//
//  OnBoardView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 20/2/2567 BE.
//

import SwiftUI

struct OnBoardView: View {
    @State private var isShowTutorials = false
    @State private var figureIndex = 0
    @State private var onBoardStep: OnBoardStep = .start
    @AppStorage("username") var username: String = ""
    @AppStorage("userHeight") var userHeightPers: Int = 0
    @AppStorage("userWeight") var userWeightPers: Int = 0
    @AppStorage("userState") var userState: UserState = .normal
    @AppStorage("goalMinute") private var goalMinute: Double = 0.0
    @AppStorage("goalCal") private var goalCal: Double = 0.0
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @State var userHeight = ""
    @State var userWeight = ""
    @State var goalMinutes = ""
    @State var goalCals = ""
    @State private var showInputAlert = false
    @FocusState private var focusedField: GeneralField?
    @ObservedObject private var keyboard = KeyboardResponder()
    var body: some View {
        VStack{
            HStack{
                Image(systemName: exercises[figureIndex].symbolName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45, height: 45)
                
            }
            Text("Welcome to FitJourney")
                .fontWeight(.bold)
                .font(.title)
            if(onBoardStep == .start){
                Spacer().frame(maxHeight: 40)
                VStack(alignment: .leading, spacing: 10){
                    ForEach(onboardData){ onboard in
                        HStack{
                            Image(systemName: onboard.symbolName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(onboard.color)
                            Spacer().frame(maxWidth: 20)
                            VStack(alignment: .leading, spacing: 5){
                                Text(onboard.title)
                                    .fontWeight(.semibold)
                                    .font(.title3)
                                Text(onboard.description)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .opacity(0.7)
                            }
                        }
                    }
                }
            }else if(onBoardStep == .fillInfo){
                VStack(alignment: .center){
                    Text("Before we continue, let's personalize your FitJourney")
                        .font(.footnote)
                        .fontWeight(.medium)
                    Spacer().frame(maxHeight: 20)
                    VStack(alignment: .leading, spacing: 20){
                        Section("Your Name"){
                            TextField("Name", text: $username)
                                .focused($focusedField, equals: GeneralField.name)
                                .textFieldStyle(CustomBorder())
                        }
                        .font(.footnote)
                        .fontWeight(.medium)
                        Picker(selection: $userState, label: EmptyView()){
                            Text("Normal").tag(UserState.normal)
                            Text("Rehabilitation").tag(UserState.rehab)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onTapGesture {
                            if(self.userState == .normal){
                                self.userState = .rehab
                            }else{
                                self.userState = .normal
                            }
                        }
                        HStack{
                            VStack(alignment: .leading){
                                Section("Your Height (cm)"){
                                    TextField("Height in centimeters", text: $userHeight)
                                        .focused($focusedField, equals: GeneralField.height)
                                        .textFieldStyle(CustomBorder())
                                        .keyboardType(.numberPad)
                                }
                            }
                            Spacer().frame(maxWidth: 15)
                            VStack(alignment: .leading){
                                Section("Your Weight (kg)"){
                                    TextField("Weight in kilograms", text: $userWeight)
                                        .focused($focusedField, equals: GeneralField.weight)
                                        .textFieldStyle(CustomBorder())
                                        .keyboardType(.numberPad)
                                    
                                }
                            }
                        }
                        .alert(isPresented: $showInputAlert) {
                            Alert(title: Text("Invalid Input"), message: Text("Please enter a valid integer value."), dismissButton: .default(Text("OK")))
                        }
                        .font(.footnote)
                        .fontWeight(.medium)
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                Button("Done") {
                                    focusedField = nil
                                }.foregroundStyle(.pink)
                            }
                        }
                        
                        HStack{
                            VStack(alignment: .leading){
                                Section("Your Target (mins)"){
                                    TextField("Fitivity in mins", text: $goalMinutes)
                                        .focused($focusedField, equals: GeneralField.mins)
                                        .textFieldStyle(CustomBorder())
                                        .keyboardType(.numberPad)
                                }
                            }
                            Spacer().frame(maxWidth: 15)
                            VStack(alignment: .leading){
                                Section("Your Target (cals)"){
                                    TextField("Calories in cals", text: $goalCals)
                                        .focused($focusedField, equals: GeneralField.cals)
                                        .textFieldStyle(CustomBorder())
                                        .keyboardType(.numberPad)
                                    
                                }
                            }
                        }
                        .alert(isPresented: $showInputAlert) {
                            Alert(title: Text("Invalid Input"), message: Text("Please enter a valid integer value."), dismissButton: .default(Text("OK")))
                        }
                        .font(.footnote)
                        .fontWeight(.medium)
                        
                    }
                }
                .padding(.bottom, keyboard.currentHeight)
                .edgesIgnoringSafeArea(.bottom)
                .animation(.easeOut(duration: 0.16))
            }
            else if(onBoardStep == .end){
                Button(action:{
                    isShowTutorials.toggle()
                    
                }){
                    Text("Need app tutorials? Click here!")
                        .foregroundStyle(userState == .normal ? .pink : .blue)
                        .underline()
                        .padding(.horizontal, 15)
                }
            }
            Spacer().frame(maxHeight: 40)
            Button(onBoardStep == .end ? "Get Start!":"Continue") {
                withAnimation {
                    if(onBoardStep == .fillInfo){
                        if(userHeight.isInt && userWeight.isInt && goalCals.isInt && goalMinutes.isInt){
                            userWeightPers = Int(userWeight) ?? 0
                            userHeightPers = Int(userHeight) ?? 0
                            goalCal = Double(Int(goalCals) ?? 0)
                            goalMinute = Double(Int(goalMinutes) ?? 0)
                            onBoardStep = .end
                        }else{
                            showInputAlert.toggle()
                        }
                    }
                    else if(onBoardStep == .end){
                        if(username.isEmpty){
                            username = "Cute Bird 🦤"
                        }
                        isFirstLaunch = false
                        onBoardStep = .start
                    }
                    else{
                        onBoardStep = .fillInfo
                    }
                }
            }
            .padding(.vertical,15)
            .padding(.horizontal, UIDevice.current.userInterfaceIdiom == .pad ? 150 : 90)
            .background(userState == .normal ? .pink : .blue)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .cornerRadius(15)
        }
        .sheet(isPresented: $isShowTutorials){
            TutorialsView()
        }
        .onTapGesture {
            self.hideKeyboard()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focusedField = .name
            }
        }
        .onAppear{
            if(userHeightPers != 0){
                userHeight = String(userHeightPers)
            }
            if(userWeightPers != 0){
                userWeight = String(userWeightPers)
            }
            if(goalCal != 0.0){
                goalCals = String(Int(goalCal))
            }
            if(goalMinute != 0.0){
                goalMinutes = String(Int(goalMinute))
            }
            func cycleExercises() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if figureIndex == exercises.count - 1 {
                        withAnimation {
                            figureIndex = 0
                        }
                    } else {
                        withAnimation {
                            figureIndex += 1
                        }
                    }
                    cycleExercises()
                }
            }
            cycleExercises()
        }
        .padding(30)
        .background(.ultraThinMaterial)
        .font(.system(.body, design: .rounded))
        .cornerRadius(15)
        .opacity(isFirstLaunch ? 1 : 0)
        .frame(maxWidth: 500)
    }
}

#Preview {
    OnBoardView()
}
