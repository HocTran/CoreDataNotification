//
//  DataController.swift
//  CoreDataNotification
//
//  Created by HocTran on 11/30/16.
//  Copyright © 2016 Hoc Tran. All rights reserved.
//

import UIKit

import UIKit
import CoreData

class DataController: NSObject {
    static var `default` = DataController()
    var managedObjectContext: NSManagedObjectContext
    
    private override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "CoreDataNotification", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc
        
//        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docUrl = urls[urls.endIndex - 1]
            
            let storeUrl = docUrl.appendingPathComponent("CoreDataNotification.sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeUrl, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
//        }
    }
    
    func save() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
}
