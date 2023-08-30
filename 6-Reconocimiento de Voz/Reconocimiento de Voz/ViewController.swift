//
//  ViewController.swift
//  Reconocimiento de Voz
//
//  Created by Juan Gabriel Gomila Salas on 30/6/16.
//  Copyright © 2016 Juan Gabriel Gomila Salas. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet var textView: UITextView!
    var audioRecordingSession : AVAudioSession!
    var audioRecorder : AVAudioRecorder!
    
    let audioFileName : String = "audio-recordered.m4a"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingAudioSetup()
        //recognizeSpeech()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    @objc func recognizeSpeech(){
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized {
                
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechURLRecognitionRequest(url: self.directoryURL()!)
                
                recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                    if let error = error {
                        print("Algo ha ido mal: \(error.localizedDescription)")
                    } else {
                        self.textView.text = result?.bestTranscription.formattedString
                    }
                })
                
                
            } else {
                print("No tengo acceso para acceder al Speech Framework")
            }
            
        }
    }
    
    func recordingAudioSetup() {
        audioRecordingSession = AVAudioSession.sharedInstance()
        
        do {
            try audioRecordingSession.setCategory(AVAudioSession.Category.record)
            try audioRecordingSession.setActive(true)
            
            audioRecordingSession.requestRecordPermission({[unowned self] (allowed:Bool) in
                if allowed {
                    //Hay que empezar a grabar pues tenemos permiso para hacerlo
                    self.startRecording()
                } else {
                    print("Necesito permisos para utilizar el micrófono")
                }
            })
            
        } catch {
           print("Ha habido un error al configurar el audio recorder")
        }
    }
    
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for:.documentDirectory, in: .userDomainMask)
        let documentsDirectory = urls[0] as URL
        return documentsDirectory.appendingPathComponent(audioFileName)
    }
    
    
    func startRecording() {
        let settings = [AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 12000.0,
                        AVNumberOfChannelsKey: 1 as NSNumber,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: directoryURL()!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.stopRecording), userInfo: nil, repeats: false)
            
        } catch {
            print("no se ha podido grabar el audio correctamente")
        }
        
    }
    
    
    @objc func stopRecording(){
        audioRecorder.stop()
        audioRecorder = nil
        
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.recognizeSpeech), userInfo: nil, repeats: false)
    }
    
}

