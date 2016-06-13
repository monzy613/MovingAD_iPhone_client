//
//  MADLoginViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

extension MBProgressHUD {
    class func validationHUD(withView view: UIView, text: String) {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Text
        hud.labelText = text
        hud.hide(true, afterDelay: 1.0)
    }
}

class MADLoginViewController: UIViewController, UITextFieldDelegate {
    var loginViewOriginCenter: CGPoint?
    
    //hud
    var hud: MBProgressHUD?
    
    @IBOutlet weak var forgetPasswordButton: UIButton!
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
            hud?.labelText = "登录中"
            Alamofire.request(.POST, MADURL.login, parameters: [
                MADURL.param.phone: account!,
                MADURL.param.password: password!]).responseJSON {
                    res in
                    if res.result.error != nil {
                        self.hud?.mode = .Text
                        self.hud!.labelText = "登录失败"
                        self.hud?.hide(true, afterDelay: 1)
                        return
                    }
                    let json = JSON(res.result.value ?? [])
                    print(res.result.value)
                    if let status = json["status"].string {
                        if status == "210" {
                            self.hud?.mode = .Text
                            self.hud!.labelText = "登录失败"
                            self.hud?.hide(true, afterDelay: 1)
                            return
                        }
                    }
                    print("loginSuccess: \(json)")
                    MADData.save(value: account, withKey: .Account)
                    MADData.save(value: password, withKey: .Password)
                    MADUserInfo.currentUserInfo = MADUserInfo(json: json)
                    self.hud?.hideHUD(withText: "登录成功", andDelay: 0.3)
                    let tabBarController = MADTabViewController()
                    self.presentViewController(tabBarController, animated: true, completion: nil)
                    Alamofire.request(.GET, MADURL.get_records, parameters: nil).responseJSON(completionHandler: { (res) in
                        let json = JSON(res.result.value ?? [])
                        print(json)
                    })
            }
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
    
    @IBAction func forgetPasswordButtonPressed(sender: UIButton) {
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
            let newCenterY = keyboardFrame.origin.y - loginView.frame.height / 2
            MZAnim.animConstraint(constraint: loginViewCenterYConstraint, destConstant: Float(newCenterY - loginViewOriginCenter!.y))
        }
    }
    
    func keyboardWillHide(notif: NSNotification) {
        MZAnim.animConstraint(constraint: loginViewCenterYConstraint, destConstant: 0)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if checkLogin() {
            return
        }
        loginViewOriginCenter = loginView.center
        initObservers()
    }


    private func checkLogin() -> Bool {
        if let account = MADData.getValue(withKey: .Account), let password = MADData.getValue(withKey: .Password) {
            accountTextField.text = account
            passwordTextField.text = password
            loginButtonPressed(loginButton)
            return true
        }
        return false
    }
}
