//
//  ViewController.swift
//  HelloWorld
//
//  Created by Juan Gabriel Gomila Salas on 22/6/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var helloLabel: UILabel!
    
    @IBOutlet var nameTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        helloLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: UIButton) {
    
        /*let alertController : UIAlertController = UIAlertController(title: "Hola, me has pulsado",
                                                                    message: "¡Hemos pulsado el botón de pantalla!", preferredStyle: .alert)
        
        let okAction : UIAlertAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)*/
        
        let theText = nameTextField.text!
        
        helloLabel.text = "Hola \(theText), ¿Cómo estás?"
    
    }

}
