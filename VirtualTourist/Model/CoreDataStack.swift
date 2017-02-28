//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/18/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import CoreData

struct CoreDataStack {
    
    // MARK: Properties
    
    private let model: NSManagedObjectModel
    let coordinator: NSPersistentStoreCoordinator
    private let modelURL: URL
    let dbURL: URL
    let context: NSManagedObjectContext
    let persistingContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    
    // MARK: Initializer
    
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
        
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = persistingContext
        
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = context
        
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
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
    }
    
}

// MARK: Background Context Operations

extension CoreDataStack {
    
    func performBackgroundBatchOperations(batch: @escaping (NSManagedObjectContext) -> Void) {
        
        // This method I used for creating new objects in the background
        
        backgroundContext.perform {
            
            batch(self.backgroundContext)
            
            do {
                try self.backgroundContext.save()
            } catch {
                print("Error saving in background context: \(error)")
            }
        }
        
    }
    
}

// MARK: Save Data

extension CoreDataStack {
    
    func save() {
        
        context.performAndWait {
            
            if self.context.hasChanges {
                do {
                    try self.context.save()
                } catch {
                    print("Error in main context saving: \(error.localizedDescription)")
                }
            
            
                self.persistingContext.perform {
                    do {
                        try self.persistingContext.save()
                    } catch {
                        print("Error in the saving context: \(error.localizedDescription)")
                    }
                }
            }
        }
        
    }
    
    func save(every delay: TimeInterval) {
        
        if delay > 0 {
            
            save()
            
            let nanoSeconds = UInt64(delay) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(nanoSeconds) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
                self.save(every: delay)
            })
        }
        
    }
    
}
