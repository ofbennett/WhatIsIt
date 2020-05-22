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

class WelcomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var resultsButton: UIButton!
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func resultsButtonPressed(_ sender: UIButton) {
    }
    
//    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    private var greetingNotDone = true
    private var itemIdentified: String?
    private var selectedImageToDisplay: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WhatIsIt?"
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        takePhotoButton.layer.cornerRadius = takePhotoButton.frame.height / 3
        resultsButton.layer.cornerRadius = resultsButton.frame.height / 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let utterance = AVSpeechUtterance(string: "What would you like me to identify?")
        let synthesizer = AVSpeechSynthesizer()
        if greetingNotDone {
            synthesizer.speak(utterance)
            greetingNotDone = false
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ResultViewController
        destinationVC.itemIdentified = itemIdentified
        destinationVC.selectedImage = selectedImageToDisplay
    }
        
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if let ciimage = CIImage(image: selectedImage) {
                itemIdentified = detect(image: ciimage)
                selectedImageToDisplay = selectedImage
                performSegue(withIdentifier: "goToResult", sender: self)
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
    
}

