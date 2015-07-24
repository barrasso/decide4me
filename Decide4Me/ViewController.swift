//
//  ViewController.swift
//  Decide4Me
//
//  Created by Mark on 7/24/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

struct Decider {
    var allItems: [String]?
    var chosenItem: String?
}

class ViewController: UIViewController {
    
    var currentDecider: Decider?
    var numberOfItems: NSNumber?
    
    // MARK: Outlets
    @IBOutlet var numberOfItemsLabel: UILabel!
    
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var decideButton: UIButton!

    @IBOutlet var inputField0: UITextField!
    @IBOutlet var inputField1: UITextField!
    @IBOutlet var inputField2: UITextField!
    @IBOutlet var inputField3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
                
        // check nsdefaults for exisiting decider obj
        let defaults = NSUserDefaults.standardUserDefaults()
        if let decider = defaults.objectForKey("decider") as? Decider {
            println("Found existing decider...")
            currentDecider = decider
            
            // set values
            numberOfItems = currentDecider?.allItems?.count
            numberOfItemsLabel.text = numberOfItems?.stringValue
            for (var i = 0; i < numberOfItems?.integerValue; i++) {
                
            }
            
        } else {
            currentDecider = Decider()
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: Utility Functions
    
    func setupUI() {
        // set place holder text style
        inputField0.attributedPlaceholder = NSAttributedString(string: "Enter first choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        inputField1.attributedPlaceholder = NSAttributedString(string: "Enter second choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        inputField2.attributedPlaceholder = NSAttributedString(string: "Enter third choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        inputField3.attributedPlaceholder = NSAttributedString(string: "Enter fourth choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
    }

}

