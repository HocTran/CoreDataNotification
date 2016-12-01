//
//  CoreDataNotification+RxSwift.swift
//  Pods
//
//  Created by HocTran on 12/1/16.
//
//

import CoreData
import CoreDataNotification
import RxSwift

/**
 Provide NSManagedObjectContext notification to Observable type
 */
public extension NSManagedObjectContext {
    /**
     Provide an Observable relect to data change in NSManagedObjectContext
     - return: Observable<Void>
     
     Example:
     
     ```
     let moc = DataController.default.managedObjectContext
     moc.rx_notification()
        .subscribe(
            onNext: { _ in
                print("Data did dhanged")
            }
        )
        .addDisposableTo(disposeBag)
     ```
     */
    public func rx_notification() -> Observable<Void> {
        return Observable.create{ [weak self] observer in
            let token = self?.addNotificationBlock { _, _ in
                observer.onNext()
            }
            
            return Disposables.create {
                token?.stop()
            }
        }
    }
    
    /**
     Provide an Observable relect to fetch result change for particular fetch request
     - return: Observable<CoreDataFetchResultChange<[T]>>
     
     For example, for a simple one-section table view, you can do the following:
     
     ```
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
                        self.tableView.reloadData()
                    case .insert(let list, let insertion):
                        self.tableView.insertRows(at: [insertion], with: .automatic)
                    case .delete(let list, let deletion):
                        self.tableView.deleteRows(at: [deletion], with: .automatic)
                    case .update(let list, let modification):
                        self.tableView.reloadRows(at: [modification], with: .automatic)
                    case .move(let list, let from, let to):
                        self.tableView.moveRow(at: from, to: to)
                    default:
                        break
                }
            }
        )
        .addDisposableTo(disposeBag)
     ```
     */
    public func rx_notification<T: NSManagedObject>(fetchRequest: NSFetchRequest<T>) -> Observable<CoreDataFetchResultChange<[T]>> {

        return Observable.create { [weak self] observer in
            let token = self?.addNotificationBlock(fetchRequest: fetchRequest) { change in
                switch change {
                case .error(let error):
                    observer.onError(error)
                default:
                    observer.onNext(change)
                }
            }
            
            return Disposables.create {
                token?.stop()
            }
        }
    }
}
