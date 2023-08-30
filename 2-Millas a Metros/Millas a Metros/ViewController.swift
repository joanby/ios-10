//
//  ViewController.swift
//  Millas a Metros
//
//  Created by Juan Gabriel Gomila Salas on 29/6/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var distanceTextField: UITextField!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    @IBOutlet var resultLabel: UILabel!
    
    let mileUnit : Double = 1.609
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        resultLabel.text = "Escribe la distancia a convertir"
        
        distanceTextField.delegate = self
        self.hideKeyboardWhenTappingAround()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @IBAction func convertPressed(_ sender: UIButton) {
        
        let selectedIndex = segmentedControl.selectedSegmentIndex

         if let textFieldStr = distanceTextField.text, let textFieldVal = Double(textFieldStr) {
        
            if selectedIndex == 0 {
                let convertedValue = textFieldVal / mileUnit
                reloadView(textFieldVal: textFieldVal, convertedValue: convertedValue)
            
            } else if selectedIndex == 1 {
                let convertedValue = textFieldVal * mileUnit
                reloadView(textFieldVal: textFieldVal, convertedValue: convertedValue)
            } else {
                print("Ningún caso debe estar aquí")
            }
        } else {
            resultLabel.text = "Escribe algún número"
        }
        
    }
    
    func reloadView(textFieldVal : Double, convertedValue : Double){
        let initValue = String(format: "%.2f", textFieldVal)
        let endValue  = String(format: "%.2f", convertedValue)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            resultLabel.text = "\(initValue) km = \(endValue) millas"
        } else {
            resultLabel.text = "\(initValue) millas = \(endValue) km"
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    

}


extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



extension UIViewController {
    
    func hideKeyboardWhenTappingAround() {
        let tap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}


