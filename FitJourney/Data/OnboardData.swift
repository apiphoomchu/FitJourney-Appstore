//
//  OnboardData.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 8/2/2567 BE.
//

import Foundation
import SwiftUI

struct OnboardData: Identifiable{
    let id = UUID()
    let symbolName: String
    let title: String
    let description: String
    let color: Color
}

enum OnBoardStep{
    case start, fillInfo, end
}

let onboardData = [
    OnboardData(symbolName: "figure.run", title: "Fitness Tracker", description:"Track daily activities effortlessly, ideal for all fitness levels", color: .teal),
    OnboardData(symbolName: "figure.cooldown", title: "Rehabilitation Companion", description: "Supports recovery, efficiently helps regain full bodily function.", color: .purple),
    OnboardData(symbolName: "brain.fill", title: "Smart Recognition", description: "Uses Machine Learning for real-time exercise and activity identification.", color: .indigo)

]
