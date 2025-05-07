//
//  CoreDataManager.swift
//  Focus_Productivity
//
//  Created by Shashank Singh on 07/05/25.
//

import CoreData


class CoreDataHelper {
    static let shared = CoreDataHelper()
    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "FocusDataModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                // Error already handled by presenting an alert,
                // so we just print to the console for debugging.
                print("Error saving context: \(error)")
            }
        }
    }

    func mainContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
