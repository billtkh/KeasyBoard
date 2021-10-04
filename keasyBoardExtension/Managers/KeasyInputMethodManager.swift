//
//  KeasyInputMethodManager.swift
//  keasyBoardExtension
//
//  Created by Bill Tsang on 4/10/2021.
//

import Foundation
import CoreData

class KeasyInputMethodManager: NSObject {
    static let shared = KeasyFontManager()
    
    func preloadData() {
        let sourceSqliteURLs = [
            Bundle.main.url(forResource: "DataModel", withExtension: "sqlite"),
            Bundle.main.url(forResource: "DataModel", withExtension: "sqlite-wal"),
            Bundle.main.url(forResource: "DataModel", withExtension: "sqlite-shm")
        ]
        
        let destSqliteURLs = [
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/DataModel.sqlite"),
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/DataModel.sqlite-wal"),
            URL(fileURLWithPath: NSPersistentContainer.defaultDirectoryURL().relativePath + "/DataModel.sqlite-shm")]

        for index in 0...sourceSqliteURLs.count-1 {
            do {
                try FileManager.default.copyItem(at: sourceSqliteURLs[index]!, to: destSqliteURLs[index])
            } catch {
                print("Could not preload data")
            }
        }
    }
    
    var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            let sourceSqliteURLs = [
                NSBundle.mainBundle().URLForResource("CoreDataDemo", withExtension: "sqlite")!,
                NSBundle.mainBundle().URLForResource("CoreDataDemo", withExtension: "sqlite-wal")!,
                NSBundle.mainBundle().URLForResource("CoreDataDemo", withExtension: "sqlite-shm")!
            ]
            
            let destSqliteURLs = [
                self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite"),
                self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite-wal"),
                self.applicationDocumentsDirectory.URLByAppendingPathComponent("CoreDataDemo.sqlite-shm")
            ]
            
            var error:NSError? = nil
            for var index = 0; index < sourceSqliteURLs.count; index++ {
                NSFileManager.defaultManager().copyItemAtURL(sourceSqliteURLs[index], toURL: destSqliteURLs[index], error: &error)
            }
        }
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
}
