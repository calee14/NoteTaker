//
//  ViewController.swift
//  NoteTaker
//
//  Created by Cappillen on 12/26/17.
//  Copyright © 2017 Cappillen. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {
    // connect the ui
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    //MARK: IBACTIONS and Cancel
    @IBAction func startButtonTapped(_ sender: UIButton) {
        self.recordAndRecognizeSpeech()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func recordAndRecognizeSpeech() {
        guard let node = audioEngine.inputNode as AVAudioInputNode! else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current local device
            return
        }
        if !myRecognizer.isAvailable {
            // A recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
            if let result = result {
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
            } else if let error = error {
                print(error)
            }
        })
    }
}

