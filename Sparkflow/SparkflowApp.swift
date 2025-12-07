//
//  SparkflowApp.swift
//  Sparkflow
//
//  Created by Luyi Zhang on 12/6/25.
//

import SwiftUI

@main
struct SparkflowApp: App {
    @StateObject private var noteStore = NoteStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(noteStore)
                .onAppear {
                    noteStore.load()
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .inactive {
                        noteStore.save()
                    }
                }
        }
    }
}
