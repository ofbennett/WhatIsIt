//
//  ResultViewController.swift
//  WhatIsIt
//
//  Created by Oscar Bennett on 22/05/2020.
//  Copyright © 2020 Oscar Bennett. All rights reserved.
//

import UIKit
import AVFoundation

class ResultViewController: UIViewController {
    
    var selectedImage: UIImage?
    var itemIdentified: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        resultImage.image = selectedImage
        resultLabel.text = itemIdentified
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        sayAnswer(with: itemIdentified)
    }
    
    @IBOutlet weak var resultImage: UIImageView!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    func sayAnswer(with result: String?) {
        
        let fullSentence = "That looks like a \(result ?? "Nothing Found")"
        let utterance = AVSpeechUtterance(string: fullSentence)
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
