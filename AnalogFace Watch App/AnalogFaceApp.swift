//
//  AnalogFaceApp.swift
//  AnalogFace Watch App
//
//  Created by Takenori Kabeya on 2023/06/06.
//

import SwiftUI
import HealthKit

class WorkoutSession: NSObject, ObservableObject {
    var session: HKWorkoutSession?
    
    func start() {
        let healthStore = HKHealthStore()
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown

        do {
            self.session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        }
        catch {
            return
        }
        
        self.session?.startActivity(with: Date.now)
    }
}

@main
struct AnalogFace_Watch_AppApp: App {
    @StateObject var workoutSession: WorkoutSession = WorkoutSession()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutSession)
        }
    }
}
