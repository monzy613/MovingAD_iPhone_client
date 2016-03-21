//
//  MADRegisterViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var mobileTextField: DesignableTextField!
    @IBOutlet weak var sendVerifyCodeButton: DesignableButton!
    @IBOutlet weak var sendButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var resendVerifyCodeButton: UIButton!
    
    
    //textFields
    weak var verifyCodeTextField: UITextField?
    weak var nameTextField: UITextField?
    weak var pwd1TextField: UITextField?
    weak var pwd2TextField: UITextField?
    
    
    @IBAction func resendVerifyButtonPressed(sender: UIButton) {
        verifyCodeTimeLeft = maxTime
        resendVerifyCodeButton.setImage(nil, forState: .Normal)
        resendVerifyCodeButton.enabled = false
        resendVerifyCodeButton.setTitle("\(verifyCodeTimeLeft)", forState: .Normal)
        startTiming()
    }
    
    
    
    @IBAction func sendVerifyCodeButtonPressed(sender: DesignableButton) {
        switch currentState {
        case .PhoneNumber:
            //make verify code text field
            let sendButtonFrame = sendVerifyCodeButton.frame
            let vTextFieldFrame = CGRectMake(sendButtonFrame.origin.x, sendButtonFrame.origin.y, sendButtonFrame.width * 0.3, sendButtonFrame.height)
            let newSendButtonFrame = CGRectMake(vTextFieldFrame.maxX + 8, sendButtonFrame.origin.y, sendButtonFrame.width - 8 - vTextFieldFrame.width, sendButtonFrame.height)
            
            verifyCodeTextField = newTextField(withPlaceHolder: "验证码")
            verifyCodeTextField?.frame = CGRectMake(vTextFieldFrame.origin.x, vTextFieldFrame.origin.y, 0, vTextFieldFrame.height)
            view.addSubview(verifyCodeTextField!)
            MZAnim.move(object: verifyCodeTextField!, destPoint: CGPointMake(vTextFieldFrame.midX, vTextFieldFrame.midY))
            MZAnim.size(object: verifyCodeTextField!, destSize: vTextFieldFrame.size)
            MZAnim.animConstraint(constraint: sendButtonWidthConstraint, destConstant: Float(newSendButtonFrame.width - sendButtonFrame.width))
            currentState = .VerifyCode
            //show recend button
            resendVerifyCodeButton.hidden = false
            resendVerifyCodeButton.setTitle("\(verifyCodeTimeLeft)", forState: .Normal)
            startTiming()
            break
        case .VerifyCode:
            //send verify code
            
            //if success, make name, pwd1, pwd2 textFields
            resendVerifyCodeButton.hidden = true
            let tfSize = mobileTextField.frame.size
            let centerX = mobileTextField.frame.midX
            
            //name
            nameTextField = newTextField(withPlaceHolder: "姓名")
            nameTextField?.frame = CGRectMake(verifyCodeTextField!.frame.origin.x, verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
            view.addSubview(nameTextField!)
            let centerY4name = (nameTextField?.frame.origin.y)! + tfSize.height / 2
            MZAnim.move(object: nameTextField!, destPoint: CGPointMake(centerX, centerY4name))
            MZAnim.size(object: nameTextField!, destSize: tfSize)
            
            //pwd1
            pwd1TextField = newTextField(withPlaceHolder: "请输入密码")
            pwd1TextField?.frame = CGRectMake(verifyCodeTextField!.frame.origin.x, verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
            view.addSubview(pwd1TextField!)
            let centerY4pwd1 = centerY4name + tfSize.height + 8
            MZAnim.move(object: pwd1TextField!, destPoint: CGPointMake(centerX, centerY4pwd1))
            MZAnim.size(object: pwd1TextField!, destSize: tfSize)
            
            //pwd2
            pwd2TextField = newTextField(withPlaceHolder: "再次输入密码")
            pwd2TextField?.frame = CGRectMake(verifyCodeTextField!.frame.origin.x, verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
            view.addSubview(pwd2TextField!)
            let centerY4pwd2 = centerY4pwd1 + tfSize.height + 8
            MZAnim.move(object: pwd2TextField!, destPoint: CGPointMake(centerX, centerY4pwd2))
            MZAnim.size(object: pwd2TextField!, destSize: tfSize)
            //animations
            verifyCodeTextField?.frame = CGRect.zero
            verifyCodeTextField?.removeFromSuperview()
            let sendButtonTopConstant: Float = 8 * 4 + Float(tfSize.height) * 3
            MZAnim.animConstraint(constraint: sendButtonTopConstraint, destConstant: sendButtonTopConstant)
            MZAnim.animConstraint(constraint: sendButtonWidthConstraint, destConstant: 0)
            currentState = .UserInfo
            sendVerifyCodeButton.setTitle("注册", forState: .Normal)
            sendVerifyCodeButton.backgroundColor = UIColor(hex6: 0x00D000)
            break
        case .UserInfo:
            break
        }
    }
    
    func newTextField(withPlaceHolder placeHolder: String) -> UITextField {
        var tf = UITextField(frame: CGRect.zero)
        tf = UITextField()
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
        verifyCodeTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "verifyCodeTiming", userInfo: nil, repeats: true)
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
