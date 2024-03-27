import Foundation
import AVFoundation
import Vision
import Combine

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]()
    @Published var currentExercise: String = ""
    @Published var isGoodForm = true
    @Published var exerciseCount = 0
    
    private var countAble = true
    
    let caloriesPerPushUp: Double = 0.29
    let caloriesPerSquat: Double = 0.32
    let caloriesPerLunge: Double = 0.25
    let caloriesPerSitUp: Double = 0.15
    let caloriesPerJumpingJack: Double = 0.2
    let caloriesPerBurpee: Double = 0.5
    let caloriesPerPlankToPushUp: Double = 0.35
    let caloriesPerHighKnee: Double = 0.24
    let caloriesPerRussianTwist: Double = 0.25
    let caloriesPerLegRaise: Double = 0.2
    
    var caloriesBurned: Double = 0.0
    
    var wasInStartPosition = false
    var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        $bodyParts
            .dropFirst()
            .sink { [weak self] bodyParts in self?.analyzeCurrentExercise(bodyParts: bodyParts) }
            .store(in: &subscriptions)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform([humanBodyRequest], on: sampleBuffer, orientation: .right)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation],
              let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
            self.analyzeCurrentExercise(bodyParts: self.bodyParts)
        }
    }
    
    var exerciseAnalysisMapping: [String: ([VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) -> Void] {
        [
            "Push-Ups": analyzePushUps,
            "Squats": analyzeSquats,
            "Lunges": analyzeLunges,
            "Jumping Jacks": analyzeJumpingJacks,
            "Lateral Raises": analyzeLateralRaises,
            "Front Raises": analyzeFrontRaises,
            "Arm Curls": analyzeArmCurls,
            "Shoulder Press":analyzeShoulderPress,
            "Arm Extensions":analyzeArmExtensions,
            "Upright Rows":analyzeUprightRows,
        ]
    }
    
    func analyzeCurrentExercise(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        switch currentExercise {
        case "Push-Ups", "Squats", "Lunges", "Jumping Jacks", "Leg Lifts","Knee Extensions",  "Arm Curls","Shoulder Press", "Arm Extensions", "Lateral Raises","Front Raises","Upright Rows":
            if let analysisFunction = exerciseAnalysisMapping[currentExercise] {
                analysisFunction(bodyParts)
            } else {
                print("No analysis function found for \(currentExercise)")
            }
        default:
            print("Exercise not recognized")
            break
        }
    }
    
    
    private func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
    
    private func calculateAngle(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
        let a = distanceBetween(p1: p1, p2: p2)
        let b = distanceBetween(p1: p2, p2: p3)
        let c = distanceBetween(p1: p1, p2: p3)
        let angle = acos((pow(a, 2) + pow(b, 2) - pow(c, 2)) / (2 * a * b))
        return angle * (180 / .pi)
    }
    
    
    
    private func analyzePushUps(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        // pass test
        let minimumConfidence: Float = 0.6
        if let shoulder = bodyParts[.rightShoulder], shoulder.confidence > minimumConfidence,
           let elbow = bodyParts[.rightElbow], elbow.confidence > minimumConfidence,
           let wrist = bodyParts[.rightWrist], wrist.confidence > minimumConfidence,
           let leftShoulder = bodyParts[.leftShoulder], leftShoulder.confidence > minimumConfidence,
           let leftElbow = bodyParts[.leftElbow], leftElbow.confidence > minimumConfidence,
           let leftWrist = bodyParts[.leftWrist], leftWrist.confidence > minimumConfidence {
            
            let rightAngle = calculateAngle(p1: shoulder.location, p2: elbow.location, p3: wrist.location)
            let leftAngle = calculateAngle(p1: leftShoulder.location, p2: leftElbow.location, p3: leftWrist.location)
            
            if (rightAngle < 160 && rightAngle > 20) || (leftAngle < 160 && leftAngle > 20) {
                if !wasInStartPosition {
                    wasInStartPosition = true
                }
            } else if (rightAngle >= 160 || leftAngle >= 160), wasInStartPosition {
                exerciseCount += countAble ? 1 : 0
                caloriesBurned += caloriesPerPushUp
                wasInStartPosition = false
            }
            isGoodForm = (rightAngle >= 160 || rightAngle > 20) || (leftAngle >= 160 || leftAngle > 20)
        }
    }
    
    
    private func analyzeSquats(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        let minimumConfidence: Float = 0.6
        if let rightHip = bodyParts[.rightHip], rightHip.confidence > minimumConfidence,
           let rightKnee = bodyParts[.rightKnee], rightKnee.confidence > minimumConfidence,
           let rightAnkle = bodyParts[.rightAnkle], rightAnkle.confidence > minimumConfidence,
           let leftHip = bodyParts[.leftHip], leftHip.confidence > minimumConfidence,
           let leftKnee = bodyParts[.leftKnee], leftKnee.confidence > minimumConfidence,
           let leftAnkle = bodyParts[.leftAnkle], leftAnkle.confidence > minimumConfidence {
            
            let rightAngle = calculateAngle(p1: rightHip.location, p2: rightKnee.location, p3: rightAnkle.location)
            let leftAngle = calculateAngle(p1: leftHip.location, p2: leftKnee.location, p3: leftAnkle.location)
            
            if (rightAngle < 110 && leftAngle < 110) && !wasInStartPosition {
                wasInStartPosition = true
            } else if (rightAngle >= 110 || leftAngle >= 110) && wasInStartPosition {
                exerciseCount += countAble ? 1 : 0
                caloriesBurned += caloriesPerSquat
                print(exerciseCount)
                wasInStartPosition = false
            }
            isGoodForm = (rightAngle < 120 && rightAngle >= 110) && (leftAngle < 120 && leftAngle >= 110)
        }
    }

    
    
    private func analyzeLunges(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        // pass test
        let minimumConfidence: Float = 0.6
        if let rightKnee = bodyParts[.rightKnee], rightKnee.confidence > minimumConfidence,
           let rightAnkle = bodyParts[.rightAnkle], rightAnkle.confidence > minimumConfidence,
           let rightHip = bodyParts[.rightHip], rightHip.confidence > minimumConfidence,
           let leftKnee = bodyParts[.leftKnee], leftKnee.confidence > minimumConfidence,
           let leftAnkle = bodyParts[.leftAnkle], leftAnkle.confidence > minimumConfidence,
           let leftHip = bodyParts[.leftHip], leftHip.confidence > minimumConfidence {
            
            let rightAngle = calculateAngle(p1: rightHip.location, p2: rightKnee.location, p3: rightAnkle.location)
            let leftAngle = calculateAngle(p1: leftHip.location, p2: leftKnee.location, p3: leftAnkle.location)
            
            if (rightAngle < 90 && leftAngle < 90) && !wasInStartPosition {
                wasInStartPosition = true
            } else if (rightAngle >= 90 || leftAngle >= 90) && wasInStartPosition {
                exerciseCount += countAble ? 1 : 0
                caloriesBurned += caloriesPerLunge
                wasInStartPosition = false
            }
            isGoodForm = (rightAngle < 160 && rightAngle > 60) && (leftAngle < 160 && leftAngle > 60)
        }
    }
    
    
    
    
    private func analyzeJumpingJacks(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        // pass test
        let minimumConfidence: Float = 0.6
        if let rightWrist = bodyParts[.rightWrist], rightWrist.confidence > minimumConfidence,
           let leftWrist = bodyParts[.leftWrist], leftWrist.confidence > minimumConfidence,
           let rightElbow = bodyParts[.rightElbow], rightElbow.confidence > minimumConfidence,
           let leftElbow = bodyParts[.leftElbow], leftElbow.confidence > minimumConfidence,
           let rightKnee = bodyParts[.rightKnee], rightKnee.confidence > minimumConfidence,
           let leftKnee = bodyParts[.leftKnee], leftKnee.confidence > minimumConfidence {
            
            
            let armsRaised = (rightWrist.location.y > rightElbow.location.y) && (leftWrist.location.y > leftElbow.location.y)
            let legsApart = (rightKnee.location.y < rightElbow.location.y) && (leftKnee.location.y < leftElbow.location.y)
            let inJumpingJackPosition = armsRaised && legsApart
            
            if inJumpingJackPosition && !wasInStartPosition {
                wasInStartPosition = true
            } else if !inJumpingJackPosition && wasInStartPosition {
                exerciseCount += countAble ? 1 : 0
                caloriesBurned += caloriesPerJumpingJack
                wasInStartPosition = false
            }
        }
    }
    
    private var wasInCurlPosition = false
    
    private func analyzeArmCurls(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        //passtest
        let minimumConfidence: Float = 0.6
        let caloriesPerArmCurl = 0.5
        
        if let rightShoulder = bodyParts[.rightShoulder], rightShoulder.confidence > minimumConfidence,
           let rightElbow = bodyParts[.rightElbow], rightElbow.confidence > minimumConfidence,
           let rightWrist = bodyParts[.rightWrist], rightWrist.confidence > minimumConfidence {
            
            let angle = calculateAngle(p1: rightShoulder.location, p2: rightElbow.location, p3: rightWrist.location)
            if angle > 45 && angle <= 90 && !wasInCurlPosition {
                wasInCurlPosition = true
                wasInStartPosition = false
            }
            
            if angle > 90 && angle <= 160 && wasInCurlPosition {
                wasInCurlPosition = false
                wasInStartPosition = true
                
                if countAble {
                    exerciseCount += 1
                    caloriesBurned += caloriesPerArmCurl
                    print("Arm Curl Completed: Count: \(exerciseCount), Calories Burned: \(caloriesBurned)")
                }
            }
        }
    }
    
    
    private var wasFullyExtended = false
    
    private func analyzeShoulderPress(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        //passtest
        let minimumConfidence: Float = 0.6
        let caloriesPerShoulderPress = 0.8
        
        if let leftShoulder = bodyParts[.leftShoulder], leftShoulder.confidence > minimumConfidence,
           let leftElbow = bodyParts[.leftElbow], leftElbow.confidence > minimumConfidence,
           let leftWrist = bodyParts[.leftWrist], leftWrist.confidence > minimumConfidence {
            
            let angle = calculateAngle(p1: leftShoulder.location, p2: leftElbow.location, p3: leftWrist.location)
            if angle > 160 && !wasFullyExtended {
                wasFullyExtended = true
            }
            
            else if angle <= 90 && wasFullyExtended {
                wasFullyExtended = false
                
                if countAble {
                    exerciseCount += 1
                    caloriesBurned += caloriesPerShoulderPress
                    print("Shoulder Press Full Cycle Completed: Count: \(exerciseCount), Calories Burned: \(caloriesBurned)")
                }
            }
        }
    }
    
    
    
    
    private var wasFullyContracted = false
    
    private func analyzeArmExtensions(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        //passtest
        let minimumConfidence: Float = 0.6
        let caloriesPerArmExtension = 0.4
        
        if let rightShoulder = bodyParts[.rightShoulder], rightShoulder.confidence > minimumConfidence,
           let rightElbow = bodyParts[.rightElbow], rightElbow.confidence > minimumConfidence,
           let rightWrist = bodyParts[.rightWrist], rightWrist.confidence > minimumConfidence {
            
            let angle = calculateAngle(p1: rightShoulder.location, p2: rightElbow.location, p3: rightWrist.location)
            
            if angle >= 130 && !wasFullyExtended {
                wasFullyExtended = true
                wasFullyContracted = false
            }
            else if angle < 80 && wasFullyExtended && !wasFullyContracted {
                wasFullyContracted = true
            }
            
            if wasFullyExtended && wasFullyContracted {
                exerciseCount += countAble ? 1 : 0
                caloriesBurned += caloriesPerArmExtension
                wasFullyExtended = false
                wasFullyContracted = false
                print("Arm Extension Cycle Completed: Angle is \(angle) degrees, Count: \(exerciseCount), Calories Burned: \(caloriesBurned)")
            }
        }
    }
    
    
    private func analyzeLateralRaises(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        //pass
        let minimumConfidence: Float = 0.6
        let caloriesPerLateralRaise = 0.5
        if let leftShoulder = bodyParts[.leftShoulder], leftShoulder.confidence > minimumConfidence,
           let leftElbow = bodyParts[.leftElbow], leftElbow.confidence > minimumConfidence,
           let leftWrist = bodyParts[.leftWrist], leftWrist.confidence > minimumConfidence,
           let rightShoulder = bodyParts[.rightShoulder], rightShoulder.confidence > minimumConfidence,
           let rightElbow = bodyParts[.rightElbow], rightElbow.confidence > minimumConfidence,
           let rightWrist = bodyParts[.rightWrist], rightWrist.confidence > minimumConfidence {
            
            let leftArmRaised = leftWrist.location.y < leftShoulder.location.y
            let rightArmRaised = rightWrist.location.y < rightShoulder.location.y
            
            if leftArmRaised && rightArmRaised && !wasInStartPosition {
                wasInStartPosition = true
            } else if (!leftArmRaised || !rightArmRaised) && wasInStartPosition {
                exerciseCount += 1
                caloriesBurned += caloriesPerLateralRaise
                wasInStartPosition = false
                print("Lateral Raise Completed: Count: \(exerciseCount), Calories Burned: \(caloriesBurned)")
            }
        }
    }
    
    
    
    private func analyzeFrontRaises(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        //pass
        let minimumConfidence: Float = 0.6
        let caloriesPerFrontRaise = 0.5
        if let leftShoulder = bodyParts[.leftShoulder], leftShoulder.confidence > minimumConfidence,
           let leftElbow = bodyParts[.leftElbow], leftElbow.confidence > minimumConfidence,
           let leftWrist = bodyParts[.leftWrist], leftWrist.confidence > minimumConfidence,
           let rightShoulder = bodyParts[.rightShoulder], rightShoulder.confidence > minimumConfidence,
           let rightElbow = bodyParts[.rightElbow], rightElbow.confidence > minimumConfidence,
           let rightWrist = bodyParts[.rightWrist], rightWrist.confidence > minimumConfidence {
            
            let leftAngle = calculateAngle(p1: leftShoulder.location, p2: leftElbow.location, p3: leftWrist.location)
            let rightAngle = calculateAngle(p1: rightShoulder.location, p2: rightElbow.location, p3: rightWrist.location)
            
            if (leftAngle > 70 && leftAngle < 110) && (rightAngle > 70 && rightAngle < 110) && !wasInStartPosition {
                wasInStartPosition = true
            } else if ((leftAngle <= 70 || leftAngle >= 110) || (rightAngle <= 70 || rightAngle >= 110)) && wasInStartPosition {
                exerciseCount += 1
                caloriesBurned += caloriesPerFrontRaise
                wasInStartPosition = false
                print("Front Raise Completed: Count: \(exerciseCount), Calories Burned: \(caloriesBurned)")
            }
        }
    }
    
    
    
    
    private func analyzeUprightRows(bodyParts: [VNHumanBodyPoseObservation.JointName: VNRecognizedPoint]) {
        let minimumConfidence: Float = 0.6
        let caloriesPerUprightRow = 0.6
        
        if let leftShoulder = bodyParts[.leftShoulder], leftShoulder.confidence > minimumConfidence,
           let leftElbow = bodyParts[.leftElbow], leftElbow.confidence > minimumConfidence,
           let rightShoulder = bodyParts[.rightShoulder], rightShoulder.confidence > minimumConfidence,
           let rightElbow = bodyParts[.rightElbow], rightElbow.confidence > minimumConfidence {
            
            let leftElbowHigher = leftElbow.location.y < leftShoulder.location.y
            let rightElbowHigher = rightElbow.location.y < rightShoulder.location.y
            
            if leftElbowHigher && rightElbowHigher && !wasInStartPosition {
                wasInStartPosition = true
            } else if (!leftElbowHigher || !rightElbowHigher) && wasInStartPosition {
                exerciseCount += 1
                caloriesBurned += caloriesPerUprightRow
                wasInStartPosition = false
                print("Upright Row Completed: Count: \(exerciseCount), Calories Burned: \(caloriesBurned)")
            }
        }
    }
    
    
    
    
}
extension PoseEstimator {
    func updateCurrentExercise(to newExercise: String) {
        DispatchQueue.main.async {
            self.currentExercise = newExercise
            self.exerciseCount = 0
            self.wasInStartPosition = false
            self.isGoodForm = true
        }
    }
    
    func stopCount(){
        countAble = false
    }
    
    func startCount(){
        countAble = true
    }
}

