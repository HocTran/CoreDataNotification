//
//  NotificationToken.swift
//  CoreDataNotification
//
//  Created by HocTran on 11/30/16.
//  Copyright © 2016 Hoc Tran. All rights reserved.
//

import UIKit
import CoreData

//MARK: - Notification Token For Database
/**
 Create instance trigger notification when ```NSManagedObjectContext``` changed.
 */
public class CoreDataNotificationToken: NSObject {
    
    ///Stop trigger notification
    public func stop() {
        NotificationCenter.default.removeObserver(self)
    }
    
    public typealias NotificationBlock = (String, NSManagedObjectContext) -> Void
    private var contextChangedBlock: NotificationBlock?
    
    ///Create instance with observer block
    public convenience init(_ changedBlock: NotificationBlock?) {
        self.init()
        self.contextChangedBlock = changedBlock
    }
    
    ///Handle changed in ```NSManagedObjectContext```
    public func dataChanged(notification: Notification) {
        if let context = notification.object as? NSManagedObjectContext {
            contextChangedBlock?(notification.name.rawValue, context)
        }
    }
}

//MARK: - Notification Token For Fetch Database Result
/**
 A `CoreDataFetchResultChange` value encapsulates information about changes to fetch result
 that are reported by CoreData notifications.
 
 The arrays of indices in the `.update` case follow `UITableView`'s batching
 conventions, and can be passed as-is to a table view's batch update functions after being converted to index paths.
 For example, for a simple one-section table view, you can do the following:
 
 ```swift
 self.notificationToken = managedObjectContext.addNotificationBlock(fetchRequest) { changes in
     switch changes {
         case .initial:
         // Results are now populated and can be accessed without blocking the UI
         self.tableView.reloadData()
            break
         // Query results have changed, so apply them to the TableView
         case .insert(_, let insertion):
            self.tableView.insertRowsAtIndexPaths([modification], withRowAnimation: .Automatic)
         case .update(_, let modification):
            self.tableView.reloadRowsAtIndexPaths([modification], withRowAnimation: .Automatic)
         case .delete(_, let deletion):
            self.tableView.deleteRowsAtIndexPaths([modification], withRowAnimation: .Automatic)
         case .error(let err):
            // An error occurred while opening the Realm file on the background worker thread
            fatalError("\(err)")
            break
     }
 }
 ```
 */
public enum CoreDataFetchResultChange<T> {
    /**
     `.initial` indicates that the initial run of the query has completed (if applicable), and the collection can now be
     used without performing any blocking work.
     - parameter T: Fetched objects in controller.
     */
    case initial(T)
    
    /**
     `.insert` indicates that a write transaction has been committed which insert object
     
     - parameter T:             Fetched objects in controller.
     - parameter insertion:     The indexpath in the new collection which were added in this version.
     */
    case insert(T, insertion: IndexPath)
    
    /**
     `.delete` indicates that a write transaction has been committed which insert object
     
     - parameter T:             Fetched objects in controller.
     - parameter deletion:      The indexpath in the new collection which were removed in this version.
     */
    case delete(T, deletion: IndexPath)
    
    /**
     `.update` indicates that a write transaction has been committed which insert object
     
     - parameter T:             Fetched objects in controller.
     - parameter modification:  The indexpath in the new collection which were modified in this version.
     */
    case update(T, modification: IndexPath)
    
    /**
     `.move` indicates that a write transaction has been committed which insert object
     
     - parameter T:     Fetched objects in controller.
     - parameter from:  The source indexpath in the new collection which were moved in this version.
     - parameter to:    The destination indexpath in the new collection which were moved in this version.
     */
    case move(T, from: IndexPath, to: IndexPath)
    
    /**
     If an error occurs, notification blocks are called one time with a `.error` result and an `NSError` containing
     details about the error. This can only currently happen if the Realm is opened on a background worker thread to
     calculate the change set.
     */
    case error(Error)
}

//MARK: - Notification Token For Database
/**
 Create instance trigger notification when fetch data result changed.
 */
public class CoreDataFetchNotification<T: NSManagedObject>: CoreDataNotificationToken, NSFetchedResultsControllerDelegate {
    public typealias CoreDataFetchNotificationBlock = (CoreDataFetchResultChange<[T]>) -> Void
    private var changedBlock: CoreDataFetchNotificationBlock?
    private var fetchResultController: NSFetchedResultsController<T>?
    
    ///Stop trigger notification
    public override func stop() {
        super.stop()
        fetchResultController?.delegate = nil
    }
    
    /**
     `.init` create instance with notification block
     
     - parameter fetchRequest:  Fetch request, instance contains filter (NSPredicate), sort descriptions, etc.
     - parameter context:       `NSManagedObjectContext` context the fetch working on.
     - parameter changedBlock:  Observer changed.
     */

    public convenience init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext, changedBlock: CoreDataFetchNotificationBlock? = nil) {
        self.init()
        self.changedBlock = changedBlock
        
        //sort is required for fetch controller
        let fetchRequestWithSort = fetchRequest
        if fetchRequestWithSort.sortDescriptors == nil {
            fetchRequestWithSort.sortDescriptors = []
        }
        
        fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequestWithSort,
                                                                managedObjectContext: context,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        fetchResultController?.delegate = self
        do {
            try fetchResultController?.performFetch()
            if let initialValues = fetchResultController?.fetchedObjects {
                changedBlock?(CoreDataFetchResultChange.initial(initialValues))
            }
        } catch {
            changedBlock?(CoreDataFetchResultChange.error(error))
        }
    }
    
    //MARK: fetch controller delegate
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        
        guard let fetchedObjects = controller.fetchedObjects as? [T] else {
            return
        }
        
        switch(type) {
        case .insert:
            if let idx = newIndexPath {
                changedBlock?(CoreDataFetchResultChange.insert(fetchedObjects, insertion: idx))
            }
            
        case .delete:
            if let idx = indexPath {
                changedBlock?(CoreDataFetchResultChange.delete(fetchedObjects, deletion: idx))
            }
            
        case .update:
            if let idx = indexPath {
                changedBlock?(CoreDataFetchResultChange.update(fetchedObjects, modification: idx))
            }
            
        case .move:
            if let fromIdx = indexPath, let toIdx = newIndexPath {
                changedBlock?(CoreDataFetchResultChange.move(fetchedObjects, from: fromIdx, to: toIdx))
            }
        }
    }
}

//MARK: - NSManagedObjectContext + notification
public extension NSManagedObjectContext {
    ///Add notification for whole database with observer block
    public func addNotificationBlock(_ block: @escaping CoreDataNotificationToken.NotificationBlock) -> CoreDataNotificationToken {
        let token = CoreDataNotificationToken(block)
        NotificationCenter.default.addObserver(token, selector: #selector(CoreDataNotificationToken.dataChanged(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self)
        return token
    }
    
    ///Add notification for fetch request with observer block
    public func addNotificationBlock<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>,
                              _ block: @escaping (CoreDataFetchResultChange<[T]>) -> Void) -> CoreDataFetchNotification<T> {
        let token = CoreDataFetchNotification(fetchRequest: fetchRequest, context: self, changedBlock: block)
        return token
    }
}
