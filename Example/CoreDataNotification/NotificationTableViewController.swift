//
//  NotificationTableViewController.swift
//  CoreDataNotification
//
//  Created by HocTran on 12/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import CoreDataNotification

class NotificationTableViewController: TableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //notification
        let moc = DataController.default.managedObjectContext
        let fetchRequest = NSFetchRequest<City>(entityName: "City")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        notificationToken = moc.addNotificationBlock(fetchRequest: fetchRequest) { change in
            switch change {
            case .initial(let list):
                self.cities = list
                self.tableView.reloadData()
            case .insert(let list, let insertion):
                self.cities = list
                self.tableView.insertRows(at: [insertion], with: .automatic)
                
            case .delete(let list, let deletion):
                self.cities = list
                self.tableView.deleteRows(at: [deletion], with: .automatic)
                
            case .update(let list, let modification):
                self.cities = list
                self.tableView.reloadRows(at: [modification], with: .automatic)
                
            case .move(let list, let from, let to):
                self.cities = list
                self.tableView.moveRow(at: from, to: to)
            case .error(let error):
                print("++++++++ ERROR ++++++++")
                print(error)
                print("+++++++++++++++++++++++++")
            }
        }
    }
}
