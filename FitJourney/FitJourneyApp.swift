import SwiftUI

@main
struct FitJourneyApp: App {
    
    @StateObject var weekStore: WeekStore = WeekStore()
    let persistenceController = CoreDataStack.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .ignoresSafeArea(.all)
                .environmentObject(weekStore)
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
