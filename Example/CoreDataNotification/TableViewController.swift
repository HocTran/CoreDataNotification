//
//  TableViewController.swift
//  CoreDataNotification
//
//  Created by HocTran on 11/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import CoreData
import CoreDataNotification

class TableViewController: UITableViewController {

    var notificationToken: CoreDataNotificationToken?
    var cities = Array<City>()
    
    deinit {
        notificationToken?.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
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

    @IBAction func addCity(sender: Any) {
        let alert = UIAlertController(title: "City name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.addCity(name: text)
            }
        })
        present(alert, animated: true, completion: nil)
    }
    
    func addCity(name: String) {
        let moc = DataController.default.managedObjectContext
        let city = NSEntityDescription.insertNewObject(forEntityName: "City", into: moc) as! City
        city.id = NSUUID().uuidString
        city.name = name
        DataController.default.save()
    }
    
    func delete(city: City) {
        let moc = DataController.default.managedObjectContext
        moc.delete(city)
        DataController.default.save()
    }
    
    func changeName(indexPath: IndexPath, newName: String) {
        cities[indexPath.row].name = newName
        DataController.default.save()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = cities[indexPath.row].name

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            delete(city: cities[indexPath.row])
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "New name", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self.changeName(indexPath: indexPath, newName: text)
            }
        })
        present(alert, animated: true, completion: nil)
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
