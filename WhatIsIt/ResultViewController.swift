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

class ResultViewController: UIViewController {
    
    var selectedImage: UIImage?
    var itemsIdentified: [VNClassificationObservation]?
    private let numItemsToShow = 5
    private var topItem: String?
    private var topConfidence: Float?

    override func viewDidLoad() {
        super.viewDidLoad()
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
                    resultLabel.text?.append(contentsOf: percent + "   ")
                } else {
                    resultLabel.text?.append(contentsOf: percent + "     ")
                }
                resultLabel.text?.append(contentsOf: simpleItem + "\n")
            }
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
    
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
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

}
