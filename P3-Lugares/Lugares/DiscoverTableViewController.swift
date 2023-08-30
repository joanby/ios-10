//
//  DiscoverTableViewController.swift
//  Lugares
//
//  Created by Juan Gabriel Gomila Salas on 25/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit
import CloudKit

class DiscoverTableViewController: UITableViewController {

    @IBOutlet var spinner: UIActivityIndicatorView!

    
    var places: [CKRecord] = []
    var imageCache: NSCache = NSCache<CKRecord.ID, NSURL>()
    var lastCursor : CKQueryOperation.Cursor?
    var hasLoadedInfo: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        spinner.hidesWhenStopped = true
        spinner.center = self.view.center
        self.view.addSubview(spinner)
        spinner.startAnimating()
        
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.gray
        self.refreshControl?.backgroundColor = UIColor.white
        self.refreshControl?.addTarget(self, action: #selector(DiscoverTableViewController.loadDataFromiCloud), for: .valueChanged)
        
        self.loadDataFromiCloud()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Load default data
    
    @objc func loadDataFromiCloud(){
        
       
        
        let iCloudContainer = CKContainer.default()
        let publicDB = iCloudContainer.publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Place", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        //Load with Operational API
        let queryOperation = CKQueryOperation(query: query)
        queryOperation.desiredKeys = ["name", "location", "type"]
        queryOperation.queuePriority = .veryHigh
        queryOperation.resultsLimit = 3
        if self.lastCursor != nil {
            queryOperation.cursor = self.lastCursor
        } else if hasLoadedInfo{
            self.refreshControl?.endRefreshing()
            return
            /*self.places.removeAll()
            self.tableView.reloadData()*/
        }
        
        queryOperation.recordFetchedBlock = { (record: CKRecord?) in
            if let record = record {
                self.places.append(record)
            }
        }
        
        queryOperation.queryCompletionBlock = { (cursor: CKQueryOperation.Cursor?, error: Error?) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            self.hasLoadedInfo = true
            self.lastCursor = cursor
            
            OperationQueue.main.addOperation({
                self.refreshControl?.endRefreshing()
                self.spinner.stopAnimating()
                self.tableView.reloadData()
            })
            
        }
        
        publicDB.add(queryOperation)
        
        
        //Load with Convenience API
        /*publicDB.perform(query, inZoneWith: nil) { (results, error) in
            print("Consulta de Lugares completada")
            
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            if let results = results {
                self.places = results
                
                OperationQueue.main.addOperation({ 
                    self.tableView.reloadData()
                })
            }
        }*/
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as! FullPlaceCell

        // Configure the cell...
        
        let place = self.places[indexPath.row]
        
        if let name = place.object(forKey: "name") as? String {
            cell.nameLabel.text = name
        }
        
        if let name = place.object(forKey: "location") as? String {
            cell.placeLabel.text = name
        }
        
        if let name = place.object(forKey: "type") as? String {
            cell.typeLabel.text = name
        }
        
        cell.placeImageView.image = #imageLiteral(resourceName: "placeholder-image")
        
        
        
        if let imageFileURL = self.imageCache.object(forKey: place.recordID) {
            print("Imagen cargada de caché")
            cell.placeImageView.image = UIImage(data: NSData(contentsOf: imageFileURL as URL) as! Data)
        } else {
        
            let publicDB = CKContainer.default().publicCloudDatabase
            let fetchImageOperation = CKFetchRecordsOperation(recordIDs: [place.recordID])
            fetchImageOperation.desiredKeys = ["image"]
            fetchImageOperation.queuePriority = .veryHigh
            
            fetchImageOperation.perRecordCompletionBlock = { (record: CKRecord?, recordID: CKRecord.ID?, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                
                
                if let record = record {
                    OperationQueue.main.addOperation({
                        if let image = record.object(forKey: "image") {
                            let imageAsset = image as! CKAsset
                            self.imageCache.setObject(imageAsset.fileURL! as NSURL, forKey: place.recordID)
                            cell.placeImageView.image = UIImage(data: NSData(contentsOf: imageAsset.fileURL!)! as Data)
                        }
                    })
                }
            }
            
            
            publicDB.add(fetchImageOperation)
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
