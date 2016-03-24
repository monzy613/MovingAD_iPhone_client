//
//  MADLoginViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

extension MBProgressHUD {
    class func validationHUD(withView view: UIView, text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Text
        hud.label.text = text
        hud.hideAnimated(true, afterDelay: 1.0)
    }
}

class MADLoginViewController: UIViewController, UITextFieldDelegate {
    var loginViewOriginCenter: CGPoint?
    
    //hud
    var hud: MBProgressHUD?
    
    @IBOutlet weak var loginViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginView: DesignableView!
    @IBOutlet weak var accountTextField: DesignableTextField!
    @IBOutlet weak var passwordTextField: DesignableTextField!

    @IBOutlet weak var loginButton: DesignableButton!
    @IBAction func loginButtonPressed(sender: DesignableButton) {
        let account = accountTextField.text
        let password = passwordTextField.text
        let phoneNumberValidation = MADInputValidation.phoneNumber(phonenumber: account)
        let passwordValidation = MADInputValidation.password(pwd: password)
        
        if phoneNumberValidation == .Valid && passwordValidation == .Valid {
            hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
            hud!.mode = .Indeterminate
            hud?.label.text = "登录中"
            MADNetwork.Post(url: MADURL.login,
                            parameters: [
                                MADURL.param.account: account!,
                                MADURL.param.password: password!],
                            onSuccess: {
                                print("login success")
                                self.hud?.hideAnimated(true)
                                self.performSegueWithIdentifier("LoginSuccessSegue", sender: self)
                            },
                            onFailure: {
                                self.hud?.mode = .Text
                                self.hud!.label.text = "登录失败"
                                self.hud?.hideAnimated(true, afterDelay: 1)
                                print("login failed")
                            })
        } else {
            MBProgressHUD.validationHUD(withView: view, text: "请输入正确手机号和密码")
        }
    }
    
    @IBAction func dismissButtonPressed(sender: UIButton) {
        view.endEditing(true)
        loginView.animation = "zoomOut"
        loginView.animate()
        dismissViewControllerAnimated(true, completion: {})
    }
    
    
    //textField delegage methods
    
    func textFieldDidEndEditing(textField: UITextField) {
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
    
    func initObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MADLoginViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MADLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardDidShow(notif: NSNotification) {
        if let userInfo = notif.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            print("keyboardFrame: \(keyboardFrame)")
            let newCenterY = keyboardFrame.origin.y - loginView.frame.height / 2
            MZAnim.animConstraint(constraint: loginViewCenterYConstraint, destConstant: Float(newCenterY - loginViewOriginCenter!.y))
        }
    }
    
    func keyboardWillHide(notif: NSNotification) {
        MZAnim.animConstraint(constraint: loginViewCenterYConstraint, destConstant: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginViewOriginCenter = loginView.center
        initObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
