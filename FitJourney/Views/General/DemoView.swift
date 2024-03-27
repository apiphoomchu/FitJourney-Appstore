//
//  SwiftUIView.swift
//
//
//  Created by Apiphoom Chuenchompoo on 25/2/2567 BE.
//

import SwiftUI
import AVKit

class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    
    init() {
        preloadVideoPlayer()
    }
    
    private func preloadVideoPlayer() {
        guard let path = Bundle.main.path(forResource: "demo", ofType: "mov") else {
            fatalError("video not found")
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        self.player = player
    }
}

struct TutorialsView: View {
    @StateObject private var viewModel = VideoPlayerViewModel()
    @Environment(\.dismiss) var dismiss
    @AppStorage("userState") var userState: UserState = .normal
    var body: some View {
        NavigationView{
            VStack {
                Text("FitJourney")
                    .foregroundStyle(.pink)
                    .font(.title)
                    .fontWeight(.bold)
                Text("Here's a sample video demonstrating the Jumping Jack exercise by FitJourney")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding([.leading,.trailing],10)
                Spacer()
                    .frame(maxHeight: 30)
                if let player = viewModel.player {
                    VideoPlayer(player: player)
                        .onAppear {
                            DispatchQueue.main.async {
                                player.play()
                            }
                        }
                        .aspectRatio(contentMode: .fit)
                }
            }     .navigationTitle("Tutorial")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }.foregroundStyle(Color(userState == .normal ? .red : .blue))
                    }
                }
        }
    }
}
