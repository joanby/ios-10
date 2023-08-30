//
//  ViewController.swift
//  Lugares
//
//  Created by Juan Gabriel Gomila Salas on 12/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UITableViewController { /*UIViewController, UITableViewDataSource, UITableViewDelegate*/
    
    var places : [Place] = []
    var searchResults : [Place] = []
    var fetchResultsController : NSFetchedResultsController<Place>!
    var searchController: UISearchController!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Buscar lugares..."
        self.searchController.searchBar.tintColor = UIColor.white
        self.searchController.searchBar.barTintColor = UIColor.darkGray
        
        
        
        let fetchRequest : NSFetchRequest<Place> = NSFetchRequest(entityName: "Place")
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        
        if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
            let context = container.viewContext
            self.fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchResultsController.delegate = self
            do {
                try fetchResultsController.performFetch()
                self.places = fetchResultsController.fetchedObjects!
                
                let defaults = UserDefaults.standard
                if !defaults.bool(forKey: "hasLoadedDefaultInfo") {
                    self.loadDefaultData()
                    defaults.set(true, forKey: "hasLoadedDefaultInfo")
                }
               
                
            } catch {
                print("Error: \(error)")
            }
            
        }
    
       
    }
    
    func loadDefaultData(){
        
        let names = ["Alexanderplatz", "Atomium", "Big Ben", "Cristo Redentor", "Torre Eiffel", "Gran Muralla","Torre de Pisa", "La Seu de Mallorca"]
        let types = ["Plaza", "Museo", "Monumento", "Monumento", "Monumento", "Monumento","Monumento", "Catedral"]
        let locations = ["Alexanderstraße 4 10178 Berlin Deutschland","Atomium Atomiumsquare 1 1020 Brussels Belgium" ,"London SW1A 0AA England",  "Cristo Redentor João Pessoa - PB Brasil",  "5 Avenue Anatole France 75007 Paris France", "Great Wall, Mutianyu Beijing China", "Leaning Tower of Pisa 56126 Pisa, Province of Pisa Italy", "La Seu Plaza de la Seu 5 07001 Palma Baleares, España"]
        let telephones = ["902022445","902022445","902022445","902022445","902022445","902022445","902022445","902022445"]
        let webs = ["https://www.disfrutaberlin.com/alexanderplatz",  "https://atomium.be/", "http://www.parliament.uk/bigben", "http://imaginariodejaneiro.com/10-curiosidades-sobre-la-estatua-del-cristo-redentor/", "http://www.toureiffel.paris/es.html", "http://www.nationalgeographic.com.es/historia/grandes-reportajes/la-gran-muralla-china_8272", "http://www.vivetoscana.com/la-torre-de-pisa-historia-y-curiosidades-de-uno-de-los-monumentos-mas-famosos-de-toscana/", "http://www.catedraldemallorca.info/principal/"]
        let images = [#imageLiteral(resourceName: "alexanderplatz"), #imageLiteral(resourceName: "atomium"), #imageLiteral(resourceName: "bigben"), #imageLiteral(resourceName: "cristoredentor"), #imageLiteral(resourceName: "torreeiffel"), #imageLiteral(resourceName: "murallachina"), #imageLiteral(resourceName: "torrepisa"), #imageLiteral(resourceName: "mallorca")]
        
        if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
            let context = container.viewContext
            
            for i in 0..<names.count {
                
                let place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context) as? Place
                
                place?.name = names[i]
                place?.type = types[i]
                place?.location = locations[i]
                place?.telephone = telephones[i]
                place?.website = webs[i]
                place?.rating = "rating"
                place?.image = images[i].pngData() as NSData?
                
                do {
                    try context.save()
                } catch {
                    print("Ha habido un error al guardar el lugar en Core Data")
                }
            }
        }
    }
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let hasViewedTutorial = defaults.bool(forKey: "hasViewedTutorial")
        
        if hasViewedTutorial {
            return
        }
        
        if let pageVC = storyboard?.instantiateViewController(withIdentifier: "WalkthroughController")  as? TutorialPageViewController {
            self.present(pageVC, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive {
            return self.searchResults.count
        } else {
            return self.places.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let place : Place!
        
        if self.searchController.isActive {
            place = self.searchResults[indexPath.row]
        } else {
            place = self.places[indexPath.row]
        }
        
        
        
        let cellID = "PlaceCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PlaceCell
        
        cell.thumbnailImageView.image = UIImage(data: place.image! as Data)
        cell.nameLabel.text = place.name
        cell.timeLabel.text = place.type
        cell.ingredientsLabel.text = place.location
        
    
        return cell
    }
    
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            self.places.remove(at: indexPath.row)
            
        }
        
        self.tableView.deleteRows(at: [indexPath], with: .fade)
        
    }*/
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        //Compartir
        let shareAction = UITableViewRowAction(style: .default, title: "Compartir") { (action, indexPath) in
            
            
            let place : Place!
            
            if self.searchController.isActive {
                place = self.searchResults[indexPath.row]
            } else {
                place = self.places[indexPath.row]
            }
            
            let shareDefaultText = "Estoy visitando \(place.name) en la App del curso de iOS 10 con Juan Gabriel"
            
            let activityController = UIActivityViewController(activityItems: [shareDefaultText, UIImage(data: place.image! as Data)!], applicationActivities: nil)
            self.present(activityController, animated: true, completion: nil)
        }
        
        shareAction.backgroundColor = UIColor(red: 30.0/255.0, green: 164.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        
        //Borrar
        let deleteAction = UITableViewRowAction(style: .default, title: "Borrar") { (action, indexPath) in
            if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
                let context = container.viewContext
                let placeToDelete = self.fetchResultsController.object(at: indexPath)
                context.delete(placeToDelete)
                
                do {
                    try context.save()
                } catch {
                    print("Error \(error)")
                }
        
            }
        }
        
        deleteAction.backgroundColor = UIColor(red: 202.0/255.0, green: 202.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        
        return [shareAction, deleteAction]
    }
    
    
    
    //MARK: - UITableViewDelegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let place : Place!
                
                if self.searchController.isActive {
                    place = self.searchResults[indexPath.row]
                } else {
                    place = self.places[indexPath.row]
                }
                
                let destinationViewController = segue.destination as! DetailViewController
                destinationViewController.place = place
                destinationViewController.hidesBottomBarWhenPushed = true
            }
        }
    }
    
    
    
    
    
    @IBAction func unwindToMainViewController(segue: UIStoryboardSegue) {
        
        if segue.identifier == "unwindToMainViewController" {
            if let addplaceVC = segue.source as? AddPlaceViewController {
                if let newPlace = addplaceVC.place {
                    self.places.append(newPlace)
                }
            }
        }
        
        
    }
    
    
    
    
    func filterContentFor(textToSearch: String) {
        
        self.searchResults = self.places.filter({ (place) -> Bool in
            let nameToFind = place.name.range(of: textToSearch, options: NSString.CompareOptions.caseInsensitive)
            return nameToFind != nil
        })
    
        
    }
    
}




extension ViewController : NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    private func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: AnyObject, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        case .update:
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }

        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        
        }
        
        self.places = controller.fetchedObjects as! [Place]
        
    }
    
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    
}





extension ViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            self.filterContentFor(textToSearch: searchText)
            self.tableView.reloadData()
        }
        
        
    }
}
