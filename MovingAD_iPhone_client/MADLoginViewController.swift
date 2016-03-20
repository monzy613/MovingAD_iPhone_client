//
//  MADLoginViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADLoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var loginView: DesignableView!
    @IBOutlet weak var accountTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!

    @IBOutlet weak var loginButton: DesignableButton!
    @IBAction func loginButtonPressed(sender: DesignableButton) {
        print("loginButtonPressed")
    }
    
    
    
    //textField delegage methods
    
    func textFieldDidEndEditing(textField: UITextField) {
        print("didend")
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == accountTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
            loginButtonPressed(loginButton)
        }
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
