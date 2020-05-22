//
//  ViewController.swift
//  WhatIsIt
//
//  Created by Oscar Bennett on 19/05/2020.
//  Copyright © 2020 Oscar Bennett. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    private var greetingNotDone = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let utterance = AVSpeechUtterance(string: "What would you like me to identify?")
        //        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //        utterance.rate = 0.1
        let synthesizer = AVSpeechSynthesizer()
        if greetingNotDone {
            synthesizer.speak(utterance)
            greetingNotDone = false
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
            if let ciimage = CIImage(image: selectedImage) {
                let itemIdentified = detect(image: ciimage)
                sayAnswer(with: itemIdentified)
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect (image: CIImage) -> String? {
        var topResult: String?
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2FP16().model) else {
            fatalError("Problem loading Model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Problem loading model results")
            }
            topResult = results.first?.identifier
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Problem handling request with error \(error)")
        }
        return topResult
    }
    
    func sayAnswer(with result: String?) {
        
        let fullSentence = "That looks like a \(result ?? "Nothing Found")"
        let utterance = AVSpeechUtterance(string: fullSentence)
        //        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //        utterance.rate = 0.1
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

