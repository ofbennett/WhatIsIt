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
    var itemIdentified: String?
    var greetingNotDone = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let utterance = AVSpeechUtterance(string: "What would you like me to identify change?")
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
                detect(image: ciimage)
                sayAnswer()
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect (image: CIImage) {
        
        
        guard let model = try? VNCoreMLModel(for: MobileNetV2FP16().model) else {
            fatalError("Problem loading Model")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Problem loading model results")
            }
            let topResult = results.first?.identifier
            print(topResult ?? "Nothing found")
            self.itemIdentified = topResult
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Problem handling request with error \(error)")
        }
    }
    
    func sayAnswer() {
        
        let fullSentence = "That looks like a \(itemIdentified ?? "Nothing Found")"
        let utterance = AVSpeechUtterance(string: fullSentence)
        //        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        //        utterance.rate = 0.1
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

