import Foundation
import Combine

class TimerViewModel: ObservableObject {
    private var timer: DispatchSourceTimer?
    private var startTime: DispatchTime?
    private var counter: Int = 0
    private var isPaused: Bool = false
    
    @Published var elapsedTimeString: String = "0.000"
    @Published var elapsedTimeStringShow: String = "0.000"
    
    func startTimer() {
        let queue = DispatchQueue(label: "com.timer.millisecond")
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: .now(), repeating: .milliseconds(1))
        startTime = .now()
        
        timer?.setEventHandler(handler: { [weak self] in
            guard let self = self else { return }
            guard !self.isPaused else { return }
            
            self.counter += 1
            let elapsedTime = Double(self.counter) / 1000
            DispatchQueue.main.async {
                self.updateElapsedTime(elapsedTime)
            }
        })
        
        timer?.resume()
    }
    
    func stopTimer() {
        timer?.cancel()
        timer = nil
        counter = 0
        isPaused = false
    }
    
    func resetElapsedTimeString(){
        elapsedTimeString = "0.000"
        elapsedTimeStringShow = "0.000"
    }
    
    func getIsPaused() -> Bool{
        return isPaused
    }
    
    func pauseTimer() {
        isPaused = true
    }
    
    func resumeTimer() {
        isPaused = false
    }
    
    private func updateElapsedTime(_ timeInSeconds: Double) {
        elapsedTimeString = String(format: "%.3f", timeInSeconds)
        if timeInSeconds < 60 {
            elapsedTimeStringShow = String(format: "%.3f", timeInSeconds)
        } else if timeInSeconds < 3600 {
            let minutes = Int(timeInSeconds / 60)
            let seconds = Int(timeInSeconds.truncatingRemainder(dividingBy: 60))
            elapsedTimeStringShow = String(format: "%02d:%02d", minutes, seconds)
        } else {
            let hours = Int(timeInSeconds / 3600)
            let minutes = Int((timeInSeconds.truncatingRemainder(dividingBy: 3600)) / 60)
            elapsedTimeStringShow = String(format: "%02d:%02d:%.3f", hours, minutes, timeInSeconds.truncatingRemainder(dividingBy: 60))
        }
    }
}
