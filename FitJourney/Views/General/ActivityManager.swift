//
//  File.swift
//  
//
//  Created by Apiphoom Chuenchompoo on 23/2/2567 BE.
//

import Foundation
import CoreData
import SwiftUI

class ActivityManager: ObservableObject {
    @Published var dataPoints: [ActivityDataPoint] = []
    @Published var userActivityHighlights: [Int] = []
    @Published var currentStreak: Int = 0
    @AppStorage("bestStreak") var bestStreak: Int = 0
    
    func fetchData() {
        let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest() as! NSFetchRequest<Activity>
        let calendar = Calendar.current
        var datesWithActivity = Set<Date>()
        
        let startDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        
        fetchRequest.predicate = NSPredicate(format: "dateAndTime >= %@ AND dateAndTime < %@", startDate as NSDate, endDate as NSDate)
        
        do {
            let activities = try CoreDataStack.shared.managedObjectContext.fetch(fetchRequest)
            datesWithActivity = Set(activities.compactMap { $0.dateAndTime })
            
            self.dataPoints = activities.map { ActivityDataPoint(
                date: $0.dateAndTime,
                activityType: $0.exerciseType,
                time: $0.dateAndTime,
                calories: $0.calories,
                totalTimes: $0.time
            )}
            
            self.userActivityHighlights = calculateActivityHighlights(dates: datesWithActivity)
            print(userActivityHighlights)
            self.currentStreak = calculateCurrentStreak(dates: datesWithActivity)
            if self.currentStreak > self.bestStreak {
                self.bestStreak = self.currentStreak
            }
            
            print("Fetched \(activities.count) results")
        } catch {
            print("Error fetching activities: \(error), \(error.localizedDescription)")
            self.dataPoints = []
        }
    }
    
    private func calculateActivityHighlights(dates: Set<Date>) -> [Int] {
        let calendar = Calendar.current
        var highlights: [Int] = []
        
        for date in dates {
            if let dayOfWeek = calendar.dateComponents([.weekday], from: date).weekday {
                highlights.append((dayOfWeek + 5) % 7)
            }
        }
        print(Array(Set(highlights)))
        
        return (Array(Set(highlights)))
    }
    
    private func calculateCurrentStreak(dates: Set<Date>) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while dates.contains(currentDate) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }
}
