//
//  ViewController.swift
//  NoteTaker
//
//  Created by Cappillen on 12/26/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController , SFSpeechRecognitionTaskDelegate {
    // connect the ui
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    //MARK: IBACTIONS and Cancel
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            self.cancelRecording()
            isRecording = false
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
        }
        
    }
    
    // give updates when the microphone is recieving audio
    let audioEngine = AVAudioEngine()
    // do the speech recognition
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    // locates speech as the user speaks in real time
    // TODO: use SFSpeechURLRecognitionRequest if audio was pre-recorded
    let request = SFSpeechAudioBufferRecognitionRequest()
    // used to manage, cancel, or stop the current recognition task
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
    // loop y/n
    var loopEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loopDelay()
//        let when = DispatchTime.now() + 2
//        DispatchQueue.main.asyncAfter(deadline: when) {
//
//        }
        self.requestSpeechAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func loopDelay() {
        delay(2) {
            [weak self] in
            if self?.loopEnabled == true {
                // do stuff here
                print("I'm High")
                // recall the function
                self!.loopDelay()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelRecording() {
        audioEngine.stop()
        if let node = audioEngine.inputNode as AVAudioInputNode! {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }
    func recordAndRecognizeSpeech() {
        guard let node = audioEngine.inputNode as AVAudioInputNode? else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        // starting the audioEngine to record
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio angine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current local device
            self.sendAlert(message: "Speech recognition is not supported for you current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            // A recognizer is not available right now
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
        
        print("hi")
        self.cancelRecording()
        print(self.detectedTextLabel.text!)
        self.detectedTextLabel.text?.removeAll()
        self.recordAndRecognizeSpeech()
    }
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                }
            }
        }
    }
    
    func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

