//
//  MADForgetPasswordViewController.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 5/17/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD

enum ButtonState {
    case PhoneNumber
    case VerifyCode
}

class MADForgetPasswordViewController: UIViewController {
    @IBOutlet weak var phoneTextField: DesignableTextField!
    @IBOutlet weak var leadingConstraintToPhoneTextField: NSLayoutConstraint!
    @IBOutlet weak var submitButton: DesignableButton!

    var verifyCodeTextField: UITextField!
    var currentState = ButtonState.PhoneNumber

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func sendVerifyCodeButtonPressed(sender: DesignableButton) {
        switch currentState {
        case .PhoneNumber:
            let validation = MADInputValidation.phoneNumber(phonenumber: phoneTextField.text!)
            if validation != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validation.rawValue)
                break
            }
            Alamofire.request(.GET, MADURL.get_login_code(phoneTextField.text!), parameters: nil).responseJSON(completionHandler: {
                res in
                if res.result.error != nil {
                    MBProgressHUD.validationHUD(withView: self.view, text: "网络错误")
                    return
                }
                let json = JSON(res.result.value ?? [])
                if let status = json["status"].string {
                    if status == "300" {
                        //success
                        MBProgressHUD.validationHUD(withView: self.view, text: "验证码已发送")
                        // show verify code textfield
                        let submitButtonFrame = self.submitButton.frame
                        let vTextFieldFrame = CGRectMake(submitButtonFrame.origin.x, submitButtonFrame.origin.y, submitButtonFrame.width * 0.3, submitButtonFrame.height)

                        self.verifyCodeTextField = UITextField(frame: vTextFieldFrame)
                        self.verifyCodeTextField.leftView = UIView(frame: CGRectMake(0, 0, 5, 10))
                        self.verifyCodeTextField.backgroundColor = UIColor.whiteColor()
                        self.verifyCodeTextField.layer.cornerRadius = 5.0
                        self.verifyCodeTextField.placeholder = "验证码"
                        self.verifyCodeTextField.font = self.phoneTextField.font
                        self.view.addSubview(self.verifyCodeTextField!)
                        self.submitButton.setTitle("登录验证", forState: .Normal)
                        self.phoneTextField.enabled = false
                        self.currentState = .VerifyCode
                        self.verifyCodeTextField.becomeFirstResponder()
                        MZAnim.move(object: self.verifyCodeTextField!, destPoint: CGPointMake(vTextFieldFrame.midX, vTextFieldFrame.midY))
                        MZAnim.size(object: self.verifyCodeTextField!, destSize: vTextFieldFrame.size)
                        MZAnim.animConstraint(constraint: self.leadingConstraintToPhoneTextField, destConstant: Float(vTextFieldFrame.size.width + 8))
                        return
                    } else if status == "210" {
                        MBProgressHUD.validationHUD(withView: self.view, text: "帐号不存在")
                        return
                    }
                }
                MBProgressHUD.validationHUD(withView: self.view, text: "迷之错误")
            })
        case .VerifyCode:
            let validation = MADInputValidation.verifyNumber(verifyNumber: verifyCodeTextField.text!)
            if validation != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validation.rawValue)
                break
            }
            Alamofire.request(.POST, MADURL.check_login_code, parameters: ["login_code" : verifyCodeTextField.text!]).responseJSON(completionHandler: {
                res in
                if res.result.error != nil {
                    MBProgressHUD.validationHUD(withView: self.view, text: "网络错误")
                    return
                }
                let json = JSON(res.result.value ?? [])
                print(res.result.value)
                if let status = json["status"].string {
                    if status == "210" {
                        MBProgressHUD.validationHUD(withView: self.view, text: "登录失败")
                        return
                    }
                }
                print("loginSuccess: \(json)")
                MADUserInfo.currentUserInfo = MADUserInfo(json: json)
                MBProgressHUD.validationHUD(withView: self.view, text: "登录成功")
                self.performSegueWithIdentifier("ForgetLoginSuccessSegue", sender: self)
            })
            break
        }
    }

    @IBAction func cancelButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func dismissButtonPressed(sender: UIButton) {
        view.endEditing(true)
    }
}
