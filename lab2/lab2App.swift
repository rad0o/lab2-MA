//
//  lab2App.swift
//  lab2
//
//  Created by radoo on 03.11.2022.
//

import SwiftUI

@main
struct lab2App: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            AlbumsListView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
