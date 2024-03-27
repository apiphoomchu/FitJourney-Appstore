//
//  ExerciseDetailView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 3/2/2567 BE.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    @AppStorage("userState") var userState: UserState = .normal
    @Binding var isExerciseViewPresented:Bool
    @StateObject var poseEstimator = PoseEstimator()
    @State private var cameraAccessGranted: Bool = false
    @State private var isShowCameraGrant: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    exerciseIcon
                    descriptionSection
                    attentionSection
                    technicalAttension
                    startExerciseButton
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Fitivity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    doneButton
                }
            }
        }.onAppear{
            CameraManager.requestCameraAccess { granted in
                self.cameraAccessGranted = granted
            }
        }
        .alert(isPresented: $isShowCameraGrant) {
            Alert(
                title: Text("Camera Access Denied"),
                message: Text("Please enable camera access in your settings."),
                primaryButton: .default(Text("Settings"), action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }),
                secondaryButton: .cancel()
            )
        }
    }
     
    private var exerciseIcon: some View {
        GroupBox {
            HStack {
                iconWithBackground
                Spacer().frame(maxWidth: 30)
                exerciseInfo
                Spacer()
            }.padding(.leading, 10)
        }
    }
    
    private var iconWithBackground: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(gradient: Gradient(colors: [userState == .normal ? .pink : .blue, .black]), center: .center, startRadius: 2, endRadius: 300))
            Image(systemName: exercise.symbolName)
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
            Text(exercise.name)
                .font(.title)
                .fontWeight(.bold)
            bodyPartsUsed
            calorieBurned
        }
    }
    
    private var technicalAttension: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Technical Attention")
                .font(.title2)
                .fontWeight(.bold)
                GroupBox {
                    HStack{
                        VStack(alignment: .leading, spacing: 8) {
                            Text("∘ Point your camera towards you to ensure a clear view for exercise analysis.")
                            Text("∘ Use this app in a well-lit environment to improve the app's ability to recognize your movements accurately.")
                            Text("∘ No equipment is needed to perform the exercises, making it easy to work out anywhere.")
                            Text("∘ Ensure you have enough space around you to perform exercises safely without restrictions.")
                        }
                        .font(.footnote)
                        Spacer()
                    }
                }
            }
    }
    
    private var bodyPartsUsed: some View {
        HStack {
            ForEach(exercise.bodyPartsUsed, id: \.self) { bodyPart in
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
            Text("\(exercise.calBurned.rawValue)")
                .fontWeight(.semibold)
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.title2)
                .fontWeight(.bold)
            GroupBox {
                HStack{
                    Text(exercise.description)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
    }
    
    private var attentionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Attention")
                .font(.title2)
                .fontWeight(.bold)
            GroupBox {
                HStack{
                    VStack(alignment: .leading){
                        ForEach(exercise.attentions, id: \.self) { attentions in
                            Text("∘ " + attentions)
                                .font(.footnote)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private var startExerciseButton: some View {
        Button("Start Exercise") {
            if(cameraAccessGranted){
                self.isExerciseViewPresented = true
                dismiss()
            }else{
                isShowCameraGrant.toggle()
            }
        }
        .padding(.vertical,15)
        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
        .controlSize(.large)
        .background(userState == .normal ? .pink : .blue)
        .fontWeight(.bold)
        .foregroundStyle(.white)
        .cornerRadius(15)
        
    }
    
    private var doneButton: some View {
        Button("Done") {
            dismiss()
        }.foregroundStyle(userState == .normal ? .red : .blue)
    }
}
