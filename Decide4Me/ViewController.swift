//
//  ViewController.swift
//  Decide4Me
//
//  Created by Mark on 7/24/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    var numberOfItems: NSNumber?
    
    var firstItem: String?
    var secondItem: String?
    var thirdItem: String?
    var fourthItem: String?
    
    var chosenItem: String?
    
    // MARK: Outlets
    @IBOutlet var numberOfItemsLabel: UILabel!
    
    @IBOutlet var minusButton: UIButton!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    @IBOutlet var decideButton: UIButton!

    @IBOutlet var inputField0: UITextField!
    @IBOutlet var inputField1: UITextField!
    @IBOutlet var inputField2: UITextField!
    @IBOutlet var inputField3: UITextField!
    
    @IBOutlet var checkImage0: UIImageView!
    @IBOutlet var checkImage1: UIImageView!
    @IBOutlet var checkImage2: UIImageView!
    @IBOutlet var checkImage3: UIImageView!
    
    @IBOutlet var divider0: UIImageView!
    @IBOutlet var divider1: UIImageView!
    @IBOutlet var divider2: UIImageView!
    @IBOutlet var divider3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // set delegates
        inputField0.delegate = self
        inputField1.delegate = self
        inputField2.delegate = self
        inputField3.delegate = self
        
        self.setupUI()
                
        // check nsdefaults for exisiting decider obj
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let chosen: AnyObject = defaults.objectForKey("chosen") {
            chosenItem = chosen as? String
            println("Found existing decision...\(chosenItem)")
            
            // set previous inputs
            numberOfItems = defaults.objectForKey("number") as? NSNumber
            numberOfItemsLabel.text = numberOfItems?.stringValue
            
            firstItem = defaults.objectForKey("first") as? String
            secondItem = defaults.objectForKey("second") as? String
            inputField0.text = firstItem
            inputField1.text = secondItem
            
            if let thirdItem = defaults.objectForKey("third") as? String {
                inputField2.text = thirdItem
            } else {
                divider2.hidden = true
                checkImage2.hidden = true
                inputField2.hidden = true
                inputField2.userInteractionEnabled = false
            }
            if let fourthItem = defaults.objectForKey("fourth") as? String {
                inputField3.text = fourthItem
            } else {
                divider3.hidden = true
                checkImage3.hidden = true
                inputField3.hidden = true
                inputField3.userInteractionEnabled = false
            }

        } else {
            // reset to default
            resetUI()
            for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(key.description)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Utility Functions
    
    func resetUI() {
        
        numberOfItems = 2
        checkImage0.hidden = true
        checkImage1.hidden = true
        clearButton.hidden = true
        
        // hide third and fourth elements
        divider2.hidden = true
        divider3.hidden = true
        checkImage2.hidden = true
        checkImage3.hidden = true
        inputField2.hidden = true
        inputField3.hidden = true
        inputField2.userInteractionEnabled = false
        inputField3.userInteractionEnabled = false
    }
    
    func setupUI() {

        // set place holder text style
        inputField0.attributedPlaceholder = NSAttributedString(string: "Enter first choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        inputField1.attributedPlaceholder = NSAttributedString(string: "Enter second choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        inputField2.attributedPlaceholder = NSAttributedString(string: "Enter third choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        inputField3.attributedPlaceholder = NSAttributedString(string: "Enter fourth choice", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // set tags
        inputField0.tag = 0
        inputField1.tag = 1
        inputField2.tag = 2
        inputField3.tag = 3
    }
    
    func decide4me() -> String {
        
        if self.numberOfItems?.integerValue == 2 {
            var choose = arc4random() % 2
            if choose == 0 {
                inputField0.textColor = UIColor.greenColor()
                return inputField0.text
            } else {
                inputField1.textColor = UIColor.greenColor()
                return inputField1.text
            }
        } else if self.numberOfItems?.integerValue == 3 {
            var choose = arc4random() % 3
            switch (choose) {
            case 0:
                inputField0.textColor = UIColor.greenColor()
                return inputField0.text
            case 1:
                inputField1.textColor = UIColor.greenColor()
                return inputField1.text
            case 2:
                inputField2.textColor = UIColor.greenColor()
                return inputField2.text
            default:
                return ""
            }
        } else {
            var choose = arc4random() % 4
            switch (choose) {
            case 0:
                inputField0.textColor = UIColor.greenColor()
                return inputField0.text
            case 1:
                inputField1.textColor = UIColor.greenColor()
                return inputField1.text
            case 2:
                inputField2.textColor = UIColor.greenColor()
                return inputField2.text
            case 3:
                inputField3.textColor = UIColor.greenColor()
                return inputField3.text
            default:
                return ""
            }
        }
    }
    
    // MARK: UITextField Delegate Functions
    
    func textFieldDidEndEditing(textField: UITextField) {
        var trimmedText = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if textField.text == "" || trimmedText == "" {
            // show input error
            textField.textColor = UIColor.redColor()
            switch(textField.tag) {
            case 0:
                checkImage0.hidden = true
            case 1:
                checkImage1.hidden = true
            case 2:
                checkImage2.hidden = true
            case 3:
                checkImage3.hidden = true
            default:
                break
            }
        } else {
            // show input success
            textField.textColor = UIColor.whiteColor()
            switch(textField.tag) {
            case 0:
                checkImage0.hidden = false
            case 1:
                checkImage1.hidden = false
            case 2:
                checkImage2.hidden = false
            case 3:
                checkImage3.hidden = false
            default:
                break
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.inputField0 {
            self.inputField1.becomeFirstResponder()
        } else if textField == self.inputField1 && numberOfItems == 2 {
            self.inputField1.resignFirstResponder()
        } else if textField == self.inputField1 && (numberOfItems == 3 || numberOfItems == 4) {
            self.inputField2.becomeFirstResponder()
        } else if textField == self.inputField2 && numberOfItems == 3 {
            self.inputField2.resignFirstResponder()
        } else if textField == self.inputField2 && numberOfItems == 4 {
            self.inputField3.becomeFirstResponder()
        } else if textField == self.inputField3 {
            self.inputField3.resignFirstResponder()
        }
        return true
    }

    // MARK: Button Actions
    
    @IBAction func clearButtonTapped(sender: AnyObject) {
        resetUI()
        
        chosenItem = ""
        firstItem = ""
        secondItem = ""
        thirdItem = ""
        fourthItem = ""
        inputField0.text = ""
        inputField1.text = ""
        inputField0.textColor = UIColor.whiteColor()
        inputField1.textColor = UIColor.whiteColor()
        inputField2.textColor = UIColor.whiteColor()
        inputField3.textColor = UIColor.whiteColor()
        numberOfItems = 2
        numberOfItemsLabel.text = numberOfItems?.stringValue
        
        for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key.description)
        }
    }
    
    @IBAction func plusButtonTapped(sender: AnyObject) {
        
        switch(self.numberOfItems!.integerValue) {
        case 2:
            self.numberOfItems = 3
            divider2.hidden = false
            inputField2.hidden = false
            clearButton.hidden = false
            inputField2.userInteractionEnabled = true
        case 3:
            self.numberOfItems = 4
            divider3.hidden = false
            inputField3.hidden = false
            clearButton.hidden = false
            inputField3.userInteractionEnabled = true
        default:
            break
        }
        
        self.numberOfItemsLabel.text = self.numberOfItems?.stringValue
    }
    
    
    @IBAction func minusButtonTapped(sender: AnyObject) {
        switch(self.numberOfItems!.integerValue) {
        case 3:
            self.numberOfItems = 2
            divider2.hidden = true
            checkImage2.hidden = true
            inputField2.text = ""
            inputField2.hidden = true
            inputField2.userInteractionEnabled = false
        case 4:
            self.numberOfItems = 3
            divider3.hidden = true
            checkImage3.hidden = true
            inputField3.text = ""
            inputField3.hidden = true
            inputField3.userInteractionEnabled = false
        default:
            break
        }
        
        self.numberOfItemsLabel.text = self.numberOfItems?.stringValue
    }
    
    
    @IBAction func decideButtonTapped(sender: AnyObject) {
        // clear
        chosenItem = ""
        inputField0.textColor = UIColor.whiteColor()
        inputField1.textColor = UIColor.whiteColor()
        inputField2.textColor = UIColor.whiteColor()
        inputField3.textColor = UIColor.whiteColor()
        for key in NSUserDefaults.standardUserDefaults().dictionaryRepresentation().keys {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(key.description)
        }

        switch (self.numberOfItems!.integerValue) {
        case 2:
            var trimmedText0 = inputField0.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            var trimmedText1 = inputField1.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if inputField0.text != "" && inputField1.text != "" && trimmedText0 != "" && trimmedText1 != "" {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(decide4me(), forKey: "chosen")
                defaults.setObject(numberOfItems, forKey: "number")
                defaults.setObject(inputField0.text, forKey: "first")
                defaults.setObject(inputField1.text, forKey: "second")
            }
        case 3:
            var trimmedText0 = inputField0.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            var trimmedText1 = inputField1.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            var trimmedText2 = inputField2.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if inputField0.text != "" && inputField1.text != "" && inputField2.text != "" && trimmedText0 != "" && trimmedText1 != "" && trimmedText2 != "" {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(decide4me(), forKey: "chosen")
                defaults.setObject(numberOfItems, forKey: "number")
                defaults.setObject(inputField0.text, forKey: "first")
                defaults.setObject(inputField1.text, forKey: "second")
                defaults.setObject(inputField2.text, forKey: "third")
            }
        case 4:
            var trimmedText0 = inputField0.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            var trimmedText1 = inputField1.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            var trimmedText2 = inputField2.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            var trimmedText3 = inputField3.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if inputField0.text != "" && inputField1.text != "" && inputField2.text != "" && inputField3.text != "" && trimmedText0 != "" && trimmedText1 != "" && trimmedText2 != "" && trimmedText3 != "" {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(decide4me(), forKey: "chosen")
                defaults.setObject(numberOfItems, forKey: "number")
                defaults.setObject(inputField0.text, forKey: "first")
                defaults.setObject(inputField1.text, forKey: "second")
                defaults.setObject(inputField2.text, forKey: "third")
                defaults.setObject(inputField3.text, forKey: "fourth")
            }
        default:
            break
        }
    }
}

