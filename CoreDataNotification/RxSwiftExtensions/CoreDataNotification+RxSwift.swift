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
 
 */
public extension NSManagedObjectContext {
    /**
     
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
