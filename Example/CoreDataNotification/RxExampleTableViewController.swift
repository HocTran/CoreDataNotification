//
//  RxExampleTableViewController.swift
//  CoreDataNotification
//
//  Created by HocTran on 12/1/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import RxSwift
import CoreDataNotification
import CoreData

class RxExampleTableViewController: TableViewController {

    var disposeBag = DisposeBag()
    
    deinit {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let moc = DataController.default.managedObjectContext
        moc.rx_notification()
            .subscribe(
                onNext: {
                    _ in
                    print("Data did dhanged")
            })
            .addDisposableTo(disposeBag)
        
        let fetchRequest = NSFetchRequest<City>(entityName: "City")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        moc.rx_notification(fetchRequest: fetchRequest)
            .catchError { error in
                print("++++++++ ERROR ++++++++")
                print(error)
                print("+++++++++++++++++++++++++")
                return Observable.just(CoreDataFetchResultChange<[City]>.initial([]))
            }
            .subscribe(
                onNext: { change in
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
                        
                    default:
                        break
                    }
            },
                onCompleted: { _ in
                    print("completed")
            },
                onDisposed: { _ in
                    print("disposed")
            }
            )
            .addDisposableTo(disposeBag)
    }
}
