//
//  ViewController.swift
//  GloryDays
//
//  Created by Juan Gabriel Gomila Salas on 5/7/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit

import AVFoundation
import Photos
import Speech


class ViewController: UIViewController {

    @IBOutlet var infoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func askForPermissions(_ sender: UIButton) {
        self.askForPhotosPermissions()
    }

    
    func askForPhotosPermissions() {
        PHPhotoLibrary.requestAuthorization { [unowned self] (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.askForRecordPermissions()
                } else {
                    self.infoLabel.text = "Nos has denegado el permiso de fotos. Por favor, actívalo en los Ajustes de tu dispositvo para continuar."
                }
            }
        }
    }
    
    
    func askForRecordPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission { [unowned self] (allowed) in
            DispatchQueue.main.async {
                if allowed {
                    self.askForTranscriptionPermissions()
                } else {
                    self.infoLabel.text = "Nos has denegado los permisos de grabación de audio. Por favor actívalos en los Ajustes de tu dispositivo para continuar."
                }
            }
        }
    }
    
    
    func askForTranscriptionPermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] (authStatus) in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.authorizationCompleted()
                } else {
                    self.infoLabel.text = "Nos has denegado los permisos de transcripción de texto. Por favor, actívalos en los Ajustes de tu dispositivo para continuar."
                }
            }
        }
    }
    
    func authorizationCompleted() {
        dismiss(animated: true)
    }
    
    

}

