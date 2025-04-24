//
//  CoreDataManager.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-24.
//


import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "TrackMed")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data load error: \(error)") }
        }
    }
    
    func saveContext() {
        guard container.viewContext.hasChanges else { return }
        do {
            try container.viewContext.save()
        } catch {
            print("Core Data save error: \(error)")
        }
    }
}
