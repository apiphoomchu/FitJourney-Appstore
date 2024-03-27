import SwiftUI
import UIKit

struct StickFigureView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    @AppStorage("userState") var userState: UserState = .normal
    var size: CGSize

    private func filterOutInvalidPoints(_ points: [CGPoint]) -> [CGPoint] {
        return points.filter { point in
            return point != CGPoint(x: 0.0, y: 1.0)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(BodyLine.allCases, id: \.self) { line in
                    Path { path in
                        let points = self.pointsForBodyLine(line)
                        let filteredPoints = filterOutInvalidPoints(points)
                        guard let firstPoint = filteredPoints.first else { return }
                        let correctedFirstPoint = CGPoint(x: (1 - firstPoint.x) * geometry.size.width, y: (1 - firstPoint.y) * geometry.size.height)
                        path.move(to: correctedFirstPoint)
                        filteredPoints.dropFirst().forEach { point in
                            let correctedPoint = CGPoint(x: (1 - point.x) * geometry.size.width, y: (1 - point.y) * geometry.size.height)
                            path.addLine(to: correctedPoint)
                        }
                    }
                    .stroke(userState == .normal ? .pink : .blue, lineWidth: 5.0)
                }

                ForEach(BodyLine.allCases, id: \.self) { line in
                    let points = self.pointsForBodyLine(line)
                    let filteredPoints = filterOutInvalidPoints(points)
                    ForEach(filteredPoints, id: \.self) { point in
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .position(x: (1 - point.x) * geometry.size.width, y: (1 - point.y) * geometry.size.height)
                    }
                }
            }
            .rotationEffect(.degrees(UIDevice.current.orientation.isLandscape ? 90 : 0))
        }
    }

    private func pointsForBodyLine(_ line: BodyLine) -> [CGPoint] {
        switch line {
        case .rightLeg:
            return [poseEstimator.bodyParts[.rightAnkle]?.location,
                    poseEstimator.bodyParts[.rightKnee]?.location,
                    poseEstimator.bodyParts[.rightHip]?.location,
                    poseEstimator.bodyParts[.root]?.location].compactMap { $0 }
        case .leftLeg:
            return [poseEstimator.bodyParts[.leftAnkle]?.location,
                    poseEstimator.bodyParts[.leftKnee]?.location,
                    poseEstimator.bodyParts[.leftHip]?.location,
                    poseEstimator.bodyParts[.root]?.location].compactMap { $0 }
        case .rightArm:
            return [poseEstimator.bodyParts[.rightWrist]?.location,
                    poseEstimator.bodyParts[.rightElbow]?.location,
                    poseEstimator.bodyParts[.rightShoulder]?.location,
                    poseEstimator.bodyParts[.neck]?.location].compactMap { $0 }
        case .leftArm:
            return [poseEstimator.bodyParts[.leftWrist]?.location,
                    poseEstimator.bodyParts[.leftElbow]?.location,
                    poseEstimator.bodyParts[.leftShoulder]?.location,
                    poseEstimator.bodyParts[.neck]?.location].compactMap { $0 }
        case .torso:
            return [poseEstimator.bodyParts[.root]?.location,
                    poseEstimator.bodyParts[.neck]?.location,
                    poseEstimator.bodyParts[.nose]?.location].compactMap { $0 }
        }
    }
}

enum BodyLine: CaseIterable {
    case rightLeg, leftLeg, rightArm, leftArm, torso
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}
