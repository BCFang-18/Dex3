//
//  Dex3App.swift
//  Dex3
//
//  Created by Baicheng Fang on 5/4/24.
//

import SwiftUI/Users/baichengfang/Documents/LearnSwiftUI/Sec4 Dex3/Dex3/Dex3/ContentView.swift

@main
struct Dex3App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
