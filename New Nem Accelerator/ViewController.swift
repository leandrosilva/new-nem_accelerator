//
//  ViewController.swift
//  New Nem Accelerator
//
//  Created by Leandro Silva on 7/22/15.
//  Copyright (c) 2015 The Daddy. All rights reserved.
//

import UIKit
import AVFoundation;

class ViewController: UIViewController {
    
    // MARK: Globals
    let BLUE_COLOR = UIColor(red: 50/255, green: 130/255, blue: 250/255, alpha: 1)
    let GREEN_COLOR = UIColor.greenColor()
    let LIGHT_GRAY_COLOR = UIColor.lightGrayColor()
    let GRAY_COLOR = UIColor.grayColor()
    let RED_COLOR = UIColor.redColor()
    
    let BUZZ_URL = NSBundle.mainBundle().URLForResource("buzz", withExtension: "mp3")
    
    var engineIsOn = false
    
    var fuelWatcher = NSTimer()
    var refuelAgent = NSTimer()
    
    var arrowBlinker = NSTimer()
    var leftArrowIsBlinking = false
    var rightArrowIsBlinking = false
    
    var avPlayer:AVAudioPlayer!
    
    // MARK: Properties
    @IBOutlet weak var speedometerLabel: UILabel!
    @IBOutlet weak var fuelProgressView: UIProgressView!
    @IBOutlet weak var ignitionButton: UIButton!
    @IBOutlet weak var acceleratorSlider: UISlider!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var refuelButton: UIButton!
    @IBOutlet weak var refuelActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // UI customization
        let transform = CGAffineTransformMakeRotation(CGFloat(M_PI * -0.5))
        acceleratorSlider.transform = transform
        
        // UI Behavior
        checkDisplayState()
        
        fuelWatcher = NSTimer.scheduledTimerWithTimeInterval(1 * 60, target:self, selector: Selector("watchFuelAvailability"), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkDisplayState() {
        acceleratorSlider.userInteractionEnabled = engineIsOn
        leftArrowButton.userInteractionEnabled = engineIsOn
        rightArrowButton.userInteractionEnabled = engineIsOn
        refuelButton.userInteractionEnabled = !engineIsOn
        
        if engineIsOn {
            ignitionButton.tintColor = RED_COLOR
            speedometerLabel.textColor = BLUE_COLOR
            fuelProgressView.tintColor = BLUE_COLOR
            leftArrowButton.setTitleColor(BLUE_COLOR, forState: UIControlState.Normal)
            rightArrowButton.setTitleColor(BLUE_COLOR, forState: UIControlState.Normal)
        } else {
            ignitionButton.tintColor = BLUE_COLOR
            speedometerLabel.text = "---"
            speedometerLabel.textColor = LIGHT_GRAY_COLOR
            fuelProgressView.tintColor = LIGHT_GRAY_COLOR
            leftArrowButton.setTitleColor(GRAY_COLOR, forState: UIControlState.Normal)
            rightArrowButton.setTitleColor(GRAY_COLOR, forState: UIControlState.Normal)
        }
        
        refuelActivityIndicatorView.hidden = true
    }
    
    func watchFuelAvailability() {
        if engineIsOn {
            fuelProgressView.progress = fuelProgressView.progress - 0.05
            
            if fuelProgressView.progress > 0.5 {
                fuelProgressView.tintColor = BLUE_COLOR
            } else if fuelProgressView.progress > 0.2 {
                fuelProgressView.tintColor = GRAY_COLOR
            } else {
                fuelProgressView.tintColor = RED_COLOR
            }
        }
    }
    
    @IBAction func ignition(sender: UIButton) {
        if acceleratorSlider.value <= 0 {
            engineIsOn = !engineIsOn
            
            resetArrowBlinker()
            checkDisplayState()
        }
    }
    
    @IBAction func accelerate(sender: UISlider) {
        speedometerLabel.text = String(stringInterpolationSegment: Int(sender.value))
    }
    
    @IBAction func refuel(sender: UIButton) {
        refuelActivityIndicatorView.hidden = false
        refuelActivityIndicatorView.startAnimating()
        
        ignitionButton.userInteractionEnabled = false

        refuelAgent = NSTimer.scheduledTimerWithTimeInterval(5, target:self, selector: Selector("completeRefuel"), userInfo: nil, repeats: true)
    }
    
    func completeRefuel() {
        fuelProgressView.progress = 1

        refuelActivityIndicatorView.stopAnimating()
        refuelActivityIndicatorView.hidden = true

        refuelAgent.invalidate()
        
        ignitionButton.userInteractionEnabled = true
    }
    
    @IBAction func leftArrowBlink(sender: UIButton) {
        if engineIsOn {
            if leftArrowIsBlinking {
                resetArrowBlinker()
            } else {
                resetArrowBlinker()
                leftArrowIsBlinking = true
                
                arrowBlinker = NSTimer.scheduledTimerWithTimeInterval(0.7, target:self, selector: Selector("blinkLeftArrow"), userInfo: nil, repeats: true)
            }
        }
    }

    @IBAction func rightArrowBlink(sender: UIButton) {
        if engineIsOn {
            if rightArrowIsBlinking {
                resetArrowBlinker()
            } else {
                resetArrowBlinker()
                rightArrowIsBlinking = true
                
                arrowBlinker = NSTimer.scheduledTimerWithTimeInterval(0.7, target:self, selector: Selector("blinkRightArrow"), userInfo: nil, repeats: true)
            }
        }
    }
    
    func blinkLeftArrow() {
        if leftArrowButton.titleLabel?.text == "<" {
            leftArrowButton.setTitleColor(GREEN_COLOR, forState: UIControlState.Normal)
            leftArrowButton.setTitle("<<", forState: UIControlState.Normal)
        } else {
            leftArrowButton.setTitleColor(BLUE_COLOR, forState: UIControlState.Normal)
            leftArrowButton.setTitle("<", forState: UIControlState.Normal)
        }
    }
    
    func blinkRightArrow() {
        if rightArrowButton.titleLabel?.text == ">" {
            rightArrowButton.setTitleColor(GREEN_COLOR, forState: UIControlState.Normal)
            rightArrowButton.setTitle(">>", forState: UIControlState.Normal)
        } else {
            rightArrowButton.setTitleColor(BLUE_COLOR, forState: UIControlState.Normal)
            rightArrowButton.setTitle(">", forState: UIControlState.Normal)
        }
    }
    
    func resetArrowBlinker() {
        arrowBlinker.invalidate()

        leftArrowButton.setTitle("<", forState: UIControlState.Normal)
        leftArrowButton.setTitleColor(BLUE_COLOR, forState: UIControlState.Normal)
        leftArrowIsBlinking = false
        
        rightArrowButton.setTitle(">", forState: UIControlState.Normal)
        rightArrowButton.setTitleColor(BLUE_COLOR, forState: UIControlState.Normal)
        rightArrowIsBlinking = false
    }
    
    @IBAction func buzz(sender: UIButton) {
        var error: NSError?
        
        avPlayer = AVAudioPlayer(contentsOfURL: BUZZ_URL, error: &error)
        
        if avPlayer == nil {
            if let e = error {
                println(e.localizedDescription)
            }
        } else {
            avPlayer.prepareToPlay()
            avPlayer.play()
        }
    }
}
