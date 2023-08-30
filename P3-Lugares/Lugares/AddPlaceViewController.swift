//
//  AddPlaceViewController.swift
//  Lugares
//
//  Created by Juan Gabriel Gomila Salas on 12/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit
import CoreData
import CloudKit

class AddPlaceViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var textfieldName: UITextField!
    
    @IBOutlet var textfieldType: UITextField!
    
    @IBOutlet var textfieldDirection: UITextField!
    
    @IBOutlet var textfieldTelephone: UITextField!
    
    @IBOutlet var textfieldWebsite: UITextField!
    
    @IBOutlet var button1: UIButton!
    
    @IBOutlet var button2: UIButton!
    
    @IBOutlet var button3: UIButton!
    
    
    var rating : String?
    
    var place : Place?
    
    
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.textfieldName.delegate = self
        self.textfieldType.delegate = self
        self.textfieldDirection.delegate = self
        self.textfieldTelephone.delegate = self
        self.textfieldWebsite.delegate = self
        
        
    }
    
    let defaultColor = UIColor(red: 236.0/255.0, green: 134.0/255.0, blue: 144.0/255.0, alpha: 1.0)
    let selectedColor = UIColor.red
    
    @IBAction func ratingPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            self.rating = "dislike"
            self.button1.backgroundColor = selectedColor
            self.button2.backgroundColor = defaultColor
            self.button3.backgroundColor = defaultColor
        case 2:
            self.rating = "good"
            self.button1.backgroundColor = defaultColor
            self.button2.backgroundColor = selectedColor
            self.button3.backgroundColor = defaultColor
        case 3:
            self.rating = "great"
            self.button1.backgroundColor = defaultColor
            self.button2.backgroundColor = defaultColor
            self.button3.backgroundColor = selectedColor
        default:
            break
        }
        
    }
    
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
    
        if let name = self.textfieldName.text,
            let type = self.textfieldType.text,
            let direction = self.textfieldDirection.text,
            let telephone = self.textfieldTelephone.text,
            let website = self.textfieldWebsite.text,
            let theImage = self.imageView.image,
            let rating = self.rating{

            if let container = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
                let context = container.viewContext
            
                self.place = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context) as? Place
            
                self.place?.name = name
                self.place?.type = type
                self.place?.location = direction
                self.place?.telephone = telephone
                self.place?.website = website
                self.place?.rating = rating
                self.place?.image = theImage.pngData() as NSData?
                
                self.savePlaceToiCloud(place: self.place)
                
                
                do {
                    try context.save()
                } catch {
                    print("Ha habido un error al guardar el lugar en Core Data")
                }
                
            
            }
            
            
            
            
            self.performSegue(withIdentifier: "unwindToMainViewController", sender: self)

            
        } else {
            
            let alertController = UIAlertController(title: "Falta algún dato", message: "Revisa que lo tengas todo configurado", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    
    func savePlaceToiCloud(place: Place!) {
        
        let record  = CKRecord(recordType: "Place")
        record.setValue(place.name, forKey: "name")
        record.setValue(place.type, forKey: "type")
        record.setValue(place.location, forKey: "location")
        record.setValue(place.telephone, forKey: "telephone")
        record.setValue(place.website, forKey: "website")
        
        
        let originalImage = UIImage(data: place.image! as Data)!
        let scaleFactor = (originalImage.size.width > 1024) ? 1024/originalImage.size.width : 1.0
        let scaledImage = UIImage(data: place.image! as Data, scale: scaleFactor)
        
        
        do{
            
            let imagePath = self.getDocumentsDirectory().appendingPathComponent(place.name)
            
            if let imageJPEG = scaledImage!.jpegData(compressionQuality: 0.8) {
                try imageJPEG.write(to: imagePath, options: [.atomicWrite])
            }
            
            
            let imageAsset = CKAsset(fileURL: imagePath)
            record.setValue(imageAsset, forKey: "image")
            
            
            let publicDB = CKContainer.default().publicCloudDatabase
            publicDB.save(record) { (record, error) in
                if error != nil {
                    print(error)
                }
                
                do {
                    try FileManager.default.removeItem(at: imagePath)
                } catch {
                    print("Hemos fallado al guardar el objeto en iCloud")
                }
            }
        }catch {
            print("Error al guardar la imagen")
        }
        
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Hay que gestionar la selección de la imagen del lugar
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        }
        
        
        
        
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.imageView.image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.clipsToBounds = true
        
        let leadingConstraint = NSLayoutConstraint(item: self.imageView, attribute: .leading, relatedBy: .equal, toItem: self.imageView.superview, attribute: .leading, multiplier: 1, constant: 0)
        leadingConstraint.isActive = true
        
        let trailingConstraint = NSLayoutConstraint(item: self.imageView, attribute: .trailing, relatedBy: .equal, toItem: self.imageView.superview, attribute: .trailing, multiplier: 1, constant: 0)
        trailingConstraint.isActive = true
        
        let topConstraint = NSLayoutConstraint(item: self.imageView, attribute: .top, relatedBy: .equal, toItem: self.imageView.superview, attribute: .top, multiplier: 1, constant: 0)
        topConstraint.isActive = true
        
        let bottomConstraint = NSLayoutConstraint(item: self.imageView, attribute: .bottom, relatedBy: .equal, toItem: self.imageView.superview, attribute: .bottom, multiplier: 1, constant: 0)
        bottomConstraint.isActive = true
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
