//
//  MADRegisterViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import MBProgressHUD

extension MBProgressHUD {
    func hideHUD(withText text: String, andDelay delay: NSTimeInterval) {
        self.mode = .Text
        self.labelText = text
        self.hide(true, afterDelay: delay)
    }
    
    static func madLoading(inView view: UIView, withText text: String) -> MBProgressHUD {
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = text
        return hud
    }
}

enum RegisterState {
    case PhoneNumber
    case VerifyCode
    case UserInfo
}

let maxTime = 60

class MADRegisterViewController: UIViewController {
    var currentState = RegisterState.PhoneNumber
    var verifyCodeTimer: NSTimer?
    var verifyCodeTimeLeft = maxTime
    var dirty: Bool {
        if mobileTextField.text != "" {
            return true
        } else {
            return false
        }
    }
    
    var hud: MBProgressHUD?
    @IBOutlet weak var mobileTextField: DesignableTextField!
    @IBOutlet weak var sendVerifyCodeButton: DesignableButton!
    @IBOutlet weak var sendButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var resendVerifyCodeButton: UIButton!
    
    
    //textFields
    var verifyCodeTextField: UITextField?
    var nameTextField: UITextField?
    var pwd1TextField: UITextField?
    var pwd2TextField: UITextField?
    
    
    
    
    @IBAction func dismissKeyboard(sender: UIButton) {
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonPressed(sender: UIButton) {
        if dirty {
            let confirmCancel = UIAlertController(title: "MovingAD", message: "确定取消注册?", preferredStyle: .Alert)
            confirmCancel.addAction(UIAlertAction(title: "是的", style: .Destructive, handler: {
                action in
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            confirmCancel.addAction(UIAlertAction(title: "取消", style: .Default, handler: nil))
            self.presentViewController(confirmCancel, animated: true, completion: nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func resendVerifyButtonPressed(sender: UIButton) {
        verifyCodeTimeLeft = maxTime
        resendVerifyCodeButton.setImage(nil, forState: .Normal)
        resendVerifyCodeButton.enabled = false
        resendVerifyCodeButton.setTitle("\(verifyCodeTimeLeft)", forState: .Normal)
        startTiming()
    }
    
    @IBAction func sendVerifyCodeButtonPressed(sender: DesignableButton) {
        let phoneNumber = mobileTextField.text
        switch currentState {
        case .PhoneNumber:
            let validationResult = MADInputValidation.phoneNumber(phonenumber: phoneNumber)
            if validationResult != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validationResult.rawValue)
                break
            }
            hud = MBProgressHUD.madLoading(inView: view, withText: "发送中")
            MADNetwork.Post(url: MADURL.registerPhone, parameters: [
                MADURL.param.account: phoneNumber!
                ], onSuccess: {
                    info in
                    //make verify code text field
                    let sendButtonFrame = self.sendVerifyCodeButton.frame
                    let vTextFieldFrame = CGRectMake(sendButtonFrame.origin.x, sendButtonFrame.origin.y, sendButtonFrame.width * 0.3, sendButtonFrame.height)
                    let newSendButtonFrame = CGRectMake(vTextFieldFrame.maxX + 8, sendButtonFrame.origin.y, sendButtonFrame.width - 8 - vTextFieldFrame.width, sendButtonFrame.height)
                    
                    self.verifyCodeTextField = self.newTextField(withPlaceHolder: "验证码")
                    self.verifyCodeTextField?.keyboardType = .NumberPad
                    self.verifyCodeTextField?.frame = CGRectMake(vTextFieldFrame.origin.x, vTextFieldFrame.origin.y, 0, vTextFieldFrame.height)
                    self.view.addSubview(self.verifyCodeTextField!)
                    MZAnim.move(object: self.verifyCodeTextField!, destPoint: CGPointMake(vTextFieldFrame.midX, vTextFieldFrame.midY))
                    MZAnim.size(object: self.verifyCodeTextField!, destSize: vTextFieldFrame.size)
                    MZAnim.animConstraint(constraint: self.sendButtonWidthConstraint, destConstant: Float(newSendButtonFrame.width - sendButtonFrame.width))
                    self.currentState = .VerifyCode
                    //show recend button
                    self.resendVerifyCodeButton.hidden = false
                    self.resendVerifyCodeButton.setTitle("\(self.verifyCodeTimeLeft)", forState: .Normal)
                    
                    self.hud?.hideHUD(withText: info, andDelay: 0.3)
                    self.startTiming()
                }, onFailure: {
                    info in
                    self.hud?.hideHUD(withText: info, andDelay: 1.0)
            })
            break
        case .VerifyCode:
            //send verify code
            let verifyCode = verifyCodeTextField?.text
            let validationResult = MADInputValidation.verifyNumber(verifyNumber: verifyCode)
            if validationResult != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validationResult.rawValue)
                break
            }
            hud = MBProgressHUD.madLoading(inView: view, withText: "发送中")
            MADNetwork.Post(url: MADURL.registerVerify, parameters: [
                MADURL.param.account: phoneNumber!,
                MADURL.param.verifyNumber: verifyCode!
                ], onSuccess: {
                    info in
                    //if success, make name, pwd1, pwd2 textFields
                    self.resendVerifyCodeButton.hidden = true
                    let tfSize = self.mobileTextField.frame.size
                    let centerX = self.mobileTextField.frame.midX
                    
                    //name
                    self.nameTextField = self.newTextField(withPlaceHolder: "姓名")
                    self.nameTextField?.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x, self.verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
                    self.view.addSubview(self.nameTextField!)
                    let centerY4name = (self.nameTextField?.frame.origin.y)! + tfSize.height / 2
                    MZAnim.move(object: self.nameTextField!, destPoint: CGPointMake(centerX, centerY4name))
                    MZAnim.size(object: self.nameTextField!, destSize: tfSize)
                    
                    //pwd1
                    self.pwd1TextField = self.newTextField(withPlaceHolder: "请输入密码")
                    self.pwd1TextField?.secureTextEntry = true
                    self.pwd1TextField?.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x, self.verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
                    self.view.addSubview(self.pwd1TextField!)
                    let centerY4pwd1 = centerY4name + tfSize.height + 8
                    MZAnim.move(object: self.pwd1TextField!, destPoint: CGPointMake(centerX, centerY4pwd1))
                    MZAnim.size(object: self.pwd1TextField!, destSize: tfSize)
                    
                    //pwd2
                    self.pwd2TextField = self.newTextField(withPlaceHolder: "再次输入密码")
                    self.pwd2TextField?.secureTextEntry = true
                    self.pwd2TextField?.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x, self.verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
                    self.view.addSubview(self.pwd2TextField!)
                    let centerY4pwd2 = centerY4pwd1 + tfSize.height + 8
                    MZAnim.move(object: self.pwd2TextField!, destPoint: CGPointMake(centerX, centerY4pwd2))
                    MZAnim.size(object: self.pwd2TextField!, destSize: tfSize)
                    //animations
                    self.verifyCodeTextField?.frame = CGRect.zero
                    self.verifyCodeTextField?.removeFromSuperview()
                    let sendButtonTopConstant: Float = 8 * 4 + Float(tfSize.height) * 3
                    MZAnim.animConstraint(constraint: self.sendButtonTopConstraint, destConstant: sendButtonTopConstant)
                    MZAnim.animConstraint(constraint: self.sendButtonWidthConstraint, destConstant: 0)
                    self.currentState = .UserInfo
                    self.sendVerifyCodeButton.setTitle("注册", forState: .Normal)
                    self.sendVerifyCodeButton.backgroundColor = UIColor(hex6: 0x00D000)
                    self.mobileTextField.enabled = false
                    self.hud?.hideHUD(withText: info, andDelay: 0.3)
                }, onFailure: {
                    info in
                    self.hud?.hideHUD(withText: info, andDelay: 1.0)
            })
            break
        case .UserInfo:
            let name = nameTextField?.text
            let pwd1 = pwd1TextField?.text
            let pwd2 = pwd2TextField?.text
            let validationResult = MADInputValidation.password(pwd1: pwd1, pwd2: pwd2)
            
            if validationResult != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validationResult.rawValue)
                break
            }
            hud = MBProgressHUD.madLoading(inView: view, withText: "注册中")
            MADNetwork.Post(url: MADURL.register, parameters: [
                MADURL.param.account: phoneNumber!,
                MADURL.param.name: name ?? "defaultName",
                MADURL.param.password: pwd1!
                ], onSuccess: {
                    info in
                    self.hud?.hideHUD(withText: info, andDelay: 0.3)
                    self.performSegueWithIdentifier(MADSegues.registerSuccess, sender: self)
                }, onFailure: {
                    info in
                    self.hud?.hideHUD(withText: info, andDelay: 1.0)
            })
            break
        }
    }
    
    func newTextField(withPlaceHolder placeHolder: String) -> UITextField {
        let tf = UITextField(frame: CGRect.zero)
        tf.layer.cornerRadius = mobileTextField.layer.cornerRadius
        tf.backgroundColor = UIColor.whiteColor()
        tf.placeholder = placeHolder
        let leftPaddingView = UIView(frame: CGRectMake(0, 0, 5, 10))
        leftPaddingView.backgroundColor = UIColor.clearColor()
        tf.leftView = leftPaddingView
        tf.leftViewMode = .Always
        tf.font = mobileTextField.font
        return tf
    }
    
    func startTiming() {
        verifyCodeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MADRegisterViewController.verifyCodeTiming), userInfo: nil, repeats: true)
    }
    
    func verifyCodeTiming() {
        verifyCodeTimeLeft -= 1
        if verifyCodeTimeLeft == 0 {
            resendVerifyCodeButton.setTitle("", forState: .Normal)
            resendVerifyCodeButton.enabled = true
            resendVerifyCodeButton.setImage(UIImage(named: "resend0_5x"), forState: .Normal)
            resendVerifyCodeButton.contentMode = .ScaleAspectFill
            verifyCodeTimer?.invalidate()
            verifyCodeTimer = nil
            return
        }
        resendVerifyCodeButton.setTitle("\(verifyCodeTimeLeft)", forState: .Normal)
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
