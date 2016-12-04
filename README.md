# CoreDataNotification

[![CI Status](http://img.shields.io/travis/HocTran/CoreDataNotification.svg?style=flat)](https://travis-ci.org/HocTran/CoreDataNotification)
[![Version](https://img.shields.io/cocoapods/v/CoreDataNotification.svg?style=flat)](http://cocoapods.org/pods/CoreDataNotification)
[![License](https://img.shields.io/cocoapods/l/CoreDataNotification.svg?style=flat)](http://cocoapods.org/pods/CoreDataNotification)
[![Platform](https://img.shields.io/cocoapods/p/CoreDataNotification.svg?style=flat)](http://cocoapods.org/pods/CoreDataNotification)

## About CoreDataNotification

It's light weight library support to handle Core Data Notification.

## How it works

### Listen any changes from Core Data.

Without CoreDataNotification
```swift
NotificationCenter.default.addObserver(token, selector: #selector(dataChanged(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: self)
```
and then
```swift
func dataChanged(notification: NSNotification) {
    //your code
}
```
With CoreDataNotification
```swift
let moc = DataController.default.managedObjectContext
moc.addNotificationBlock {
    //deal with change here
}
```

### Listen changes from Fetch result.
Without CoreDataNotification
```swift
//Declare your fetch result

override func viewDidLoad() {
    let moc = DataController.default.managedObjectContext
    let fetchRequest = NSFetchRequest<City>(entityName: "City")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

    SFetchedResultsController(fetchRequest: fetchRequestWithSort,
                      managedObjectContext: context,
                        sectionNameKeyPath: nil,
                                 cacheName: nil)
    fetchResultController?.delegate = self
}

//MARK: fetch controller delegate
func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
}

func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
}
```
With CoreDataNotification

```swift
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
```

## Requirements
 - Swift 3.0

## Installation

### CoreDataNotification
CoreDataNotification is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CoreDataNotification"
```

### RxSwift
Available support for RxSwift. To install it, add the following line to your Podfiel:

```ruby
pod "CoreDataNotification/RxSwift"
```
### How it works

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let moc = DataController.default.managedObjectContext
    moc.rx_notification()
        .subscribe(
        onNext: { _ in
            //deal with changes in core data
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
            }
            onDisposed: { _ in
                print("disposed")
            }
        )
        .addDisposableTo(disposeBag)
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

HocTran, tranhoc78@gmail.com

## License

CoreDataNotification is available under the MIT license. See the LICENSE file for more info.
