//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/18/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import CoreData

struct CoreDataStack {
    
    private let model: NSManagedObjectModel
    let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    let dbURL: URL
    let context: NSManagedObjectContext
    
    init?(modelName: String) {
        
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("Unable to find \(modelName).")
            return nil
        }
        
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Unable to create an object from \(modelURL).")
            return nil
        }
        
        self.model = model
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
        let fileManager = FileManager.default
        
        guard let docURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to reach document directory.")
            return nil
        }
        
        let dbURL = docURL.appendingPathComponent("model.sqlite")
        
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
        } catch {
            print("Unable to add store at \(dbURL)")
        }
        
        self.dbURL = dbURL
        
    }
    
}

// MARK: Remove Data

extension CoreDataStack {
    
    func removeAllData() throws {
        try coordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
    }
    
}

// MARK: Save Data

extension CoreDataStack {
    
    func saveContext() throws {
        if context.hasChanges {
            try context.save()
        }
    }
    
    func save(every delay: TimeInterval) {
        
        if delay > 0 {
            do {
                try saveContext()
                print("Auto saved.")
            } catch {
                print("Error while autosaving...")
            }
            
            let nanoSeconds = UInt64(delay) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(nanoSeconds) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.save(every: delay)
            })
        }
        
    }
    
}
