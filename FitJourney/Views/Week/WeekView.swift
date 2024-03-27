//
//  WeekView.swift
//  SquatCounter
//
//  Created by Apiphoom Chuenchompoo on 20/2/2567 BE.
//

import SwiftUI

struct WeekView: View {
    @EnvironmentObject var weekStore: WeekStore
    @AppStorage("userState") var userState: UserState = .normal
    var week: Week

    var body: some View {
        HStack {
            ForEach(0..<7) { i in
                VStack {
                    Text(self.formatDayOfWeek(week.dates[i]))
                        .font(.body)
                                 .fontWeight(.semibold)
                                 .frame(maxWidth:.infinity)
                    Spacer()
                        .frame(height: 4)
                        Text(week.dates[i].toString(format: "d"))
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(week.dates[i] == week.referenceDate ? .white : .primary)
                }
                .background(week.dates[i] == week.referenceDate ? userState == .normal ? .red.opacity(0.5) : .blue.opacity(0.5) : .clear)
                .cornerRadius(10)
                .onTapGesture {
                    withAnimation {
                        weekStore.selectedDate = week.dates[i]
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func formatDayOfWeek(_ date: Date) -> String {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "E"
          let dayOfWeek = dateFormatter.string(from: date).uppercased()
          return String(dayOfWeek.prefix(1))
      }
}
