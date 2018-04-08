//
//  OnboardingViewController.swift
//  quotesApp
//
//  Created by Stephen Samuelsen on 4/1/18.
//  Copyright © 2018 Unplugged Apps LLC. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    

    @IBOutlet weak var introButtonOutlet: SpringButton!
    
    @IBOutlet weak var textDisplay: UITextView!
    
    
    
    let myText = Array("Welcome to Quotability! I will be your personal assistant. Click me to expand the quote drawer and click me to dismiss the drawer".characters)        //text to be displayed about the app
    var myCounter = 0
    var timer:Timer?
    @objc func fireTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: "typeLetter", userInfo: nil, repeats: true)
    }
    @objc func typeLetter(){
        if myCounter < myText.count {
            textDisplay.text = textDisplay.text! + String(myText[myCounter])
            let randomInterval = Double((arc4random_uniform(2)+1))/20
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: randomInterval, target: self, selector: "typeLetter", userInfo: nil, repeats: false)
        } else {
            timer?.invalidate()
        }
        myCounter = myCounter + 1
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fireTimer()
        
    }
    
    @IBAction func introButtonPressed(_ sender: Any) {          //lets get started button
        introButtonOutlet.animation = "zoomOut"
        introButtonOutlet.curve = "linear"
        introButtonOutlet.force = 2.0
        introButtonOutlet.duration = 1.0
        introButtonOutlet.animate()
        
        UserDefaults.standard.set("Done", forKey: "firstStart")
        performSegue(withIdentifier: "onboarding", sender: self)
        
        
        
        
    }
    
    
    

}
