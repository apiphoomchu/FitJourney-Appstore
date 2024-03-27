import SwiftUI

struct CircleTimer: View {
    @Binding var start: Bool
    @Binding var count: Int
    let defaultTime: Int
    @State private var to: CGFloat = 1
    @State private var time = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var fadeOut = false 
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.06).edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(Color.black.opacity(0.09), style: StrokeStyle(lineWidth: 35, lineCap: .round))
                        .frame(width: 280, height: 280)
                    
                    Circle()
                        .trim(from: 0, to: self.to)
                        .stroke(self.count > defaultTime * 2 / 3 ? Color.green : self.count > defaultTime / 3 ? Color.yellow : Color.red, style: StrokeStyle(lineWidth: 35, lineCap: .round))
                        .frame(width: 280, height: 280)
                        .rotationEffect(.init(degrees: -90))
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    
                    VStack {
                        Text("\(self.count)")
                            .font(.system(size: 72))
                            .fontWeight(.bold)
                        if count >= 5 {
                            Text("Ready?")
                                .font(.title)
                                .fontWeight(.medium)
                                .transition(.opacity)
                        } else if count >= 2 {
                            Text("Set!")
                                .font(.title)
                                .fontWeight(.medium)
                                .transition(.opacity)
                        } else if count >= 1 {
                            Text("Go!")
                                .font(.title)
                                .fontWeight(.medium)
                                .transition(.opacity)
                        }
                    }
                }
            }
        }
        .opacity(fadeOut ? 0 : 1)
        .onReceive(self.time) { _ in
            self.updateTimer()
        }
        .onChange(of: count) { newValue in
            if newValue == 0 {
                withAnimation {
                    self.fadeOut = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.resetTimer()
                }
            }
        }
    }
    
    private func updateTimer() {
        if self.start {
            if self.count > 0 {
                self.count -= 1
                withAnimation(.default) {
                    self.to = CGFloat(self.count) / CGFloat(defaultTime)
                }
            }
        }
    }
    
    func resetTimer() {
        self.count = defaultTime
        self.to = 1.0
        self.start = false
        self.fadeOut = false
    }
}
