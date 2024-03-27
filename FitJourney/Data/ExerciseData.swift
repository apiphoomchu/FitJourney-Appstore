//
//  ExerciseData.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 3/2/2567 BE.
//

import Foundation

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let symbolName: String
    let bodyPartsUsed: [String]
    let calBurned: CalBurned
    let description: String
    let attentions: [String]
    
    enum CalBurned: String {
        case Low, Medium, High
    }
}

let exercises = [
    Exercise(
        name: "Push-Ups",
        symbolName: "figure.wrestling",
        bodyPartsUsed: ["Chest", "Shoulders"],
        calBurned: .Medium,
        description: "Push-ups are a classic exercise that targets the chest, shoulders, and triceps for building upper body strength.",
        attentions: [
            "Keep your body in a straight line from head to heels.",
            "Don't let your hips sag or lift too high.",
            "Elbows should bend at a 45-degree angle from your body."
        ]
    ),
    Exercise(
        name: "Squats",
        symbolName: "figure.arms.open",
        bodyPartsUsed: ["Quads", "Hamstrings"],
        calBurned: .Medium,
        description: "Squats are a fundamental exercise for strengthening the entire lower body and core.",
        attentions: [
            "Keep your feet flat on the ground.",
            "Don't let your knees go past your toes.",
            "Maintain an upright posture throughout the movement."
        ]
    ),
    Exercise(
        name: "Lunges",
        symbolName: "figure.strengthtraining.functional",
        bodyPartsUsed: ["Quads", "Hamstrings"],
        calBurned: .Medium,
        description: "Lunges are a versatile exercise that can enhance balance, coordination, and the strength of leg muscles.",
        attentions: [
            "Align your knee over your ankle in the forward leg.",
            "Keep the back heel lifted during the lunge.",
            "Avoid letting the forward knee move inward or outward."
        ]
    ),
    Exercise(
        name: "Jumping Jacks",
        symbolName: "figure.mixed.cardio",
        bodyPartsUsed: ["Legs", "Arms"],
        calBurned: .High,
        description: "Jumping jacks are a full-body workout that can improve endurance and burn calories.",
        attentions: [
            "Land softly on the balls of your feet.",
            "Keep your knees slightly bent to absorb impact.",
            "Coordinate arm and leg movements fluidly."
        ]
    ),
]

let exerciselight = [
    Exercise(
        name: "Arm Curls",
        symbolName: "figure.arms.open",
        bodyPartsUsed: ["Biceps"],
        calBurned: .Low,
        description: "Arm curls primarily target the biceps, aiding in the strengthening and mobility of the elbow joint.",
        attentions: [
            "Keep your elbows close to your torso.",
            "Do not swing your arms; control the movement.",
            "Fully extend your arms at the bottom of the curl."
        ]
    ),
    Exercise(
        name: "Shoulder Press",
        symbolName: "figure.strengthtraining.traditional",
        bodyPartsUsed: ["Shoulders", "Triceps"],
        calBurned: .Medium,
        description: "The shoulder press focuses on the upper body strength, emphasizing shoulder mobility and stability.",
        attentions: [
            "Press the weights upward until your arms are fully extended.",
            "Keep your core engaged throughout the movement.",
            "Do not arch your back as you press the weights."
        ]
    ),
    Exercise(
        name: "Arm Extensions",
        symbolName: "figure.taichi",
        bodyPartsUsed: ["Triceps"],
        calBurned: .Low,
        description: "Arm extensions help in triceps strengthening and promote full elbow joint extension.",
        attentions: [
            "Keep your elbows pointing forward, moving only your forearms.",
            "Control the weight as you lower it back down.",
            "Ensure full extension for maximum triceps engagement."
        ]
    ),
    Exercise(
        name: "Lateral Raises",
        symbolName: "figure",
        bodyPartsUsed: ["Deltoids"],
        calBurned: .Low,
        description: "Lateral Raises primarily target the deltoid muscles in the shoulders, improving shoulder mobility and strength. The exercise involves lifting weights out to the sides of the body up to shoulder height, then lowering them back down.",
        attentions: [
            "Keep your core engaged and stand upright to ensure proper posture.",
            "Lift the weights to the side with a slight bend in the elbows to protect the joints.",
            "Avoid lifting the weights above shoulder height to reduce the risk of injury."
        ]
    ),

    Exercise(
        name: "Front Raises",
        symbolName: "figure.martial.arts",
        bodyPartsUsed: ["Deltoids", "Serratus Anterior"],
        calBurned: .Low,
        description: "Front Raises target the anterior deltoid muscles and the serratus anterior, enhancing shoulder strength and stability. This exercise is performed by lifting weights straight in front of you up to shoulder height, then lowering them back down.",
        attentions: [
            "Maintain a slight bend in the elbows throughout the movement to protect the joints.",
            "Ensure a controlled motion without swinging the weights to maximize muscle engagement.",
            "Keep your back straight and avoid using momentum to lift the weights."
        ]
    ),

    Exercise(
        name: "Upright Rows",
        symbolName: "figure.strengthtraining.traditional",
        bodyPartsUsed: ["Shoulders", "Traps"],
        calBurned: .Medium,
        description: "Upright Rows are effective for targeting the upper back and shoulder muscles, involving an upward rowing motion with weights. This exercise strengthens the trapezius and deltoid muscles by lifting the weights straight up along the front of the body, with the elbows leading the movement.",
        attentions: [
            "Keep the weights close to your body as you lift.",
            "Lead with your elbows to ensure proper form and maximize engagement of the target muscles.",
            "Avoid shrugging your shoulders excessively or using too much weight, which can lead to strain."
        ]
    )


]


