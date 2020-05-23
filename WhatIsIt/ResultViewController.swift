//
//  ResultViewController.swift
//  WhatIsIt
//
//  Created by Oscar Bennett on 22/05/2020.
//  Copyright © 2020 Oscar Bennett. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import CoreData

class ResultViewController: UIViewController {
    
    var selectedImage: UIImage?
    var itemsIdentified: [VNClassificationObservation]?
    private let numItemsToShow = 5
    private var topItem: String?
    private var topConfidence: Float?
    var oldResult = false
    var finalResultText: String = ""
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if oldResult {
            loadOldResult()
        } else {
            loadNewResult()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let topConfidence = topConfidence {
            if topConfidence > Float(0.3) {
                sayAnswer(with: topItem)
            } else {
                sayNothingFound()
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        let newResult = SavedResult(context: context)
        newResult.resultString = finalResultText
        guard let imageData = selectedImage?.jpegData(compressionQuality: 1.0) else {
            fatalError("No image data to save")
        }
        newResult.image = imageData
        newResult.timeStamp = Date()
        saveItems()
        saveButton.isEnabled = false
        saveButton.title = "Result Saved"
    }
    
    func loadNewResult(){
        resultImage.image = selectedImage
        resultLabel.text = ""
        if let items = itemsIdentified {
            for i in 0...numItemsToShow {
                print(items[i].confidence, items[i].identifier)
                let percent = String(format: "%.1f" ,items[i].confidence * 100)+"%"
                let simpleItem = items[i].identifier.split(separator: ",")[0]
                if i == 0 {
                    topItem = String(simpleItem)
                    topConfidence = items[i].confidence
                }
                if percent.count == 5 {
                    finalResultText.append(contentsOf: percent + "   ")
                } else {
                    finalResultText.append(contentsOf: percent + "     ")
                }
                finalResultText.append(contentsOf: simpleItem + "\n")
            }
            resultLabel.text = finalResultText
        }
    }
    
    func loadOldResult(){
        resultImage.image = selectedImage
        resultLabel.text = finalResultText
        saveButton.isEnabled = false
        saveButton.tintColor = UIColor.clear
    }
    
    func sayAnswer(with result: String?) {
        
        let fullSentence = "That looks like a \(result ?? "Nothing Found")"
        let utterance = AVSpeechUtterance(string: fullSentence)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    func sayNothingFound() {
        let utterance = AVSpeechUtterance(string: "I'm not sure what that is")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch {
            print("Problem saving items, \(error)")
        }
    }

}
