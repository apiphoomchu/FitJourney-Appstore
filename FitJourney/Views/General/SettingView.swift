//
//  SettingView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 12/2/2567 BE.
//

import SwiftUI

struct SettingView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("userHeight") var userHeightPers: Int = 0
    @AppStorage("userWeight") var userWeightPers: Int = 0
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    @AppStorage("userState") var userState: UserState = .normal
    @AppStorage("goalMinute") private var goalMinute: Double = 0.0
    @AppStorage("goalCal") private var goalCal: Double = 0.0
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: GeneralField?
    @State private var showInputAlert = false
    @State private var showResetConfirm = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                VStack{
                    Spacer().frame(maxHeight: 40)
                    VStack{
                        ZStack{
                            Circle()
                                .frame(width: 110, height: 110)
                                .foregroundStyle(.white)
                            Circle()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(.gray)
                            Text(username.prefix(1))
                                .foregroundStyle(.white)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                    }
                    Text(username)
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                    VStack(alignment: .leading){
                        Section(header: Text("General Info").fontWeight(.semibold).font(.title2)){
                            GroupBox{
                                HStack{
                                    Text("Username")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    TextField("Name", text: $username)
                                        .focused($focusedField, equals: GeneralField.name)
                                        .frame(maxWidth: 200)
                                        .multilineTextAlignment(.trailing)
                                }
                            }
                            GroupBox{
                                HStack{
                                    Text("Height")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    TextField("Height in centimeters", value: $userHeightPers, formatter: NumberFormatter())
                                        .focused($focusedField, equals: GeneralField.height)
                                        .frame(maxWidth: 200)
                                        .multilineTextAlignment(.trailing)
                                    
                                    Text("Cm")
                                        .fontWeight(.semibold)
                                    
                                }
                            }
                            GroupBox{
                                HStack{
                                    Text("Weight")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    TextField("Weight in kilograms", value: $userWeightPers, formatter: NumberFormatter())
                                        .focused($focusedField, equals: GeneralField.weight)
                                        .frame(maxWidth: 200)
                                        .multilineTextAlignment(.trailing)
                                    
                                    Text("Kg")
                                        .fontWeight(.semibold)
                                }
                            }
                            GroupBox{
                                HStack{
                                    Text("Your state")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Picker(selection: $userState, label: EmptyView()){
                                        Text("Normal").tag(UserState.normal)
                                        Text("Rehabilitation").tag(UserState.rehab)
                                    }
                                    .frame(maxWidth: 200)
                                    .pickerStyle(SegmentedPickerStyle())
                                }
                            }
                            GroupBox{
                                HStack{
                                    Text("Your Fitivity Time Target (Mins)")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    TextField("Fitivity in mins", value: $goalMinute, formatter: NumberFormatter())
                                        .focused($focusedField, equals: GeneralField.mins)
                                        .frame(maxWidth: 200)
                                        .multilineTextAlignment(.trailing)
                                    
                                    Text("Mins")
                                        .fontWeight(.semibold)
                                }
                            }
                            GroupBox{
                                HStack{
                                    Text("Your Calories Target (Cals)")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    TextField("Calaories in mins", value: $goalCal, formatter: NumberFormatter())
                                        .focused($focusedField, equals: GeneralField.cals)
                                        .frame(maxWidth: 200)
                                        .multilineTextAlignment(.trailing)
                                    
                                    Text("Mins")
                                        .fontWeight(.semibold)
                                }
                            }

                        }
                        Spacer().frame(minHeight: 40, maxHeight: 50)
                        Section(header: Text("Settings").fontWeight(.semibold).font(.title2)){
                            GroupBox{
                                HStack{
                                    Text("Show Welcome Screen")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action:{
                                        dismiss()
                                        isFirstLaunch = true
                                    }){
                                        Text("Show")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(userState == .normal ? .red : .blue)
                                    }
                                }
                            }
                            GroupBox{
                                HStack{
                                    Text("Rest All Data")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Button(action:{
                                        showResetConfirm.toggle()
                                    }){
                                        Text("Reset")
                                            .fontWeight(.bold)
                                            .foregroundStyle(.red)
                                    }
                                }
                            }
                        }
                    }.padding(.vertical,10)
                        .padding(.horizontal,20)
                        .alert(isPresented: $showInputAlert) {
                            Alert(title: Text("Invalid Input"), message: Text("Please enter a valid integer value."), dismissButton: .default(Text("OK")))
                        }
                        .alert(isPresented: $showResetConfirm) {
                            Alert(
                                title: Text("Reset Data"),
                                message: Text("Are you sure you want to reset all data? This action cannot be undone."),
                                primaryButton: .destructive(Text("Reset")) {
                                    CoreDataStack.shared.resetAllCoreData()
                                },
                                secondaryButton: .cancel()
                            )
                        }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        doneButton
                    }
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


#Preview {
    SettingView()
}
