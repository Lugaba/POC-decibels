//
//  ViewController.swift
//  POC-decibels
//
//  Created by Luca Hummel on 23/09/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var time = Timer()
    var decibel = 0 {
        didSet {
            decibelLabel.text = "\(decibel)"
        }
    }
    var decibelLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordButton = UIButton()
        recordButton.tintColor = .blue
        recordButton.setImage(UIImage(systemName: "circle"), for: .normal)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        view.addSubview(recordButton)
        
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        recordingSession = AVAudioSession.sharedInstance()
        
        decibelLabel.text = "0"
        view.addSubview(decibelLabel)
        decibelLabel.translatesAutoresizingMaskIntoConstraints = false
        decibelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        decibelLabel.topAnchor.constraint(equalTo: recordButton.bottomAnchor, constant: 10).isActive = true
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { allowed in
                DispatchQueue.main.async {
                    if allowed {
                        print("allowed")
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func loadRecordingUI() {
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.delegate = self
            audioRecorder.record()
            time = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(readDeci), userInfo: nil, repeats: true)
            
            
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        time.invalidate()
        
        audioRecorder.stop()
        audioRecorder = nil
        
        
    }
    
    @objc func readDeci() {
        audioRecorder.updateMeters()
        decibel = Int(audioRecorder.averagePower(forChannel: 0))
        print(decibel)
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            recordButton.tintColor = .red
            startRecording()
            print("comecou")
        } else {
            recordButton.tintColor = .blue
            finishRecording(success: true)
            print("parou")
        }
    }
    
    
}

