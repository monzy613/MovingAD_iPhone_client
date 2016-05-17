//
//  MADRegisterViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/20.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import MBProgressHUD
import BUKImagePickerController
import BUKPhotoEditViewController
import Alamofire

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

class MADRegisterViewController: UIViewController, BUKImagePickerControllerDelegate, BUKPhotoEditViewControllerDelegate {
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

    var idCardUploadButton: UIButton!
    var permitUploadButton: UIButton!
    var carUploadButton: UIButton!

    //textFields
    var verifyCodeTextField: UITextField?
    var nameTextField: UITextField?
    var idNumberTextField: UITextField?
    var pwd1TextField: UITextField?
    var pwd2TextField: UITextField?

    //upload images
    var idCardImageData: NSData?
    var idCardImageFileType: String?
    var permitImageData: NSData?
    var permitImageFileType: String?
    var carImageData: NSData?
    var carImageFileType: String?
    private var currentUploadType: UploadType = .NULL
    private var imagePickerController: BUKImagePickerController?

    private enum UploadType {
        case NULL
        case IDCard
        case Permit
        case Car
    }
    
    
    
    
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

    func uploadButtonPressed(sender: UIButton) {
        view.endEditing(true)
        switch sender {
        case idCardUploadButton:
            currentUploadType = .IDCard
        case permitUploadButton:
            currentUploadType = .Permit
        case carUploadButton:
            currentUploadType = .Car
        default:
            break
        }
        imagePickerController = BUKImagePickerController()
        imagePickerController!.mediaType = .Image
        imagePickerController!.sourceType = .Library
        imagePickerController!.delegate = self
        imagePickerController!.allowsMultipleSelection = false
        presentViewController(imagePickerController!, animated: true, completion: nil)
    }

    @IBAction func sendVerifyCodeButtonPressed(sender: DesignableButton) {
        let phoneNumber = mobileTextField.text ?? ""
        switch currentState {
        case .PhoneNumber:
            let validationResult = MADInputValidation.phoneNumber(phonenumber: phoneNumber)
            if validationResult != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validationResult.rawValue)
                break
            }
            hud = MBProgressHUD.madLoading(inView: view, withText: "发送中")
            MADNetwork.Get(url: MADURL.get_register_code(withPhone: phoneNumber), parameters: nil, onSuccess: {
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
            MADNetwork.Get(url: MADURL.check_register_code, parameters: [
                MADURL.param.verifyCode: verifyCode!
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

                    //idnumber
                    self.idNumberTextField = self.newTextField(withPlaceHolder: "身份证号")
                    self.idNumberTextField?.keyboardType = .DecimalPad
                    self.idNumberTextField?.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x, self.verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
                    self.view.addSubview(self.idNumberTextField!)
                    let centerY4IDNumber = centerY4name + tfSize.height + 8
                    MZAnim.move(object: self.idNumberTextField!, destPoint: CGPointMake(centerX, centerY4IDNumber))
                    MZAnim.size(object: self.idNumberTextField!, destSize: tfSize)

                    //pwd1
                    self.pwd1TextField = self.newTextField(withPlaceHolder: "请输入密码")
                    self.pwd1TextField?.secureTextEntry = true
                    self.pwd1TextField?.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x, self.verifyCodeTextField!.frame.origin.y, tfSize.width, 1)
                    self.view.addSubview(self.pwd1TextField!)
                    let centerY4pwd1 = centerY4IDNumber + tfSize.height + 8
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

                    //uploadButtons
                    self.idCardUploadButton = self.newUploadButton(withTitle: "身份证照")
                    self.permitUploadButton = self.newUploadButton(withTitle: "驾驶证照")
                    self.carUploadButton = self.newUploadButton(withTitle: "行驶证照")
                    let buttonSpace: CGFloat = 8.0
                    let buttonWidth = (tfSize.width - buttonSpace * 2) / 3
                    let buttonSize = CGSizeMake(buttonWidth, tfSize.height)
                    self.idCardUploadButton.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x, self.verifyCodeTextField!.frame.origin.y, buttonWidth, 1)
                    self.permitUploadButton.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x + buttonWidth + buttonSpace, self.verifyCodeTextField!.frame.origin.y, buttonWidth, 1)
                    self.carUploadButton.frame = CGRectMake(self.verifyCodeTextField!.frame.origin.x + 2 * (buttonWidth + buttonSpace), self.verifyCodeTextField!.frame.origin.y, buttonWidth, 1)
                    self.view.addSubview(self.idCardUploadButton)
                    self.view.addSubview(self.permitUploadButton)
                    self.view.addSubview(self.carUploadButton)
                    let centerY4UploadButtons = centerY4pwd2 + tfSize.height + 8

                    MZAnim.move(object: self.idCardUploadButton, destPoint: CGPointMake(self.idCardUploadButton.center.x, centerY4UploadButtons))
                    MZAnim.size(object: self.idCardUploadButton, destSize: buttonSize)

                    MZAnim.move(object: self.permitUploadButton, destPoint: CGPointMake(self.permitUploadButton.center.x, centerY4UploadButtons))
                    MZAnim.size(object: self.permitUploadButton, destSize: buttonSize)

                    MZAnim.move(object: self.carUploadButton, destPoint: CGPointMake(self.carUploadButton.center.x, centerY4UploadButtons))
                    MZAnim.size(object: self.carUploadButton, destSize: buttonSize)


                    //animations
                    self.verifyCodeTextField?.frame = CGRect.zero
                    self.verifyCodeTextField?.removeFromSuperview()
                    let sendButtonTopConstant: Float = 8 * 6 + Float(tfSize.height) * 5
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
            let idCode = idNumberTextField?.text
            let validationPassword = MADInputValidation.password(pwd1: pwd1, pwd2: pwd2)
            
            if validationPassword != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validationPassword.rawValue)
                break
            }
            let validationID = MADInputValidation.idCode(code: idCode)
            if validationID != .Valid {
                MBProgressHUD.validationHUD(withView: view, text: validationID.rawValue)
                break
            }

            if idCardImageData == nil || permitImageData == nil || carImageData == nil {
                MBProgressHUD.validationHUD(withView: view, text: "请上传身份证正面照， 行驶证详情照， 驾驶证详情照")
                break
            }
            hud = MBProgressHUD.madLoading(inView: view, withText: "注册中")

            Alamofire.upload(
                .POST,
                MADURL.check_register,
                multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: self.idCardImageData!, name: "ID_card_image", fileName: "idCardImage.\(self.idCardImageFileType ?? "jpeg")", mimeType: "image/\(self.idCardImageFileType ?? "jpeg")")
                    multipartFormData.appendBodyPart(data: self.permitImageData!, name: "permit_card_image", fileName: "permit_card_image.\(self.permitImageFileType ?? "jpeg")", mimeType: "image/\(self.permitImageFileType ?? "jpeg")")
                    multipartFormData.appendBodyPart(data: self.carImageData!, name: "car_image", fileName: "car_image.\(self.carImageFileType ?? "jpeg")", mimeType: "image/\(self.carImageFileType ?? "jpeg")")
                    multipartFormData.appendBodyPart(data:idCode!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"userID")
                    multipartFormData.appendBodyPart(data:pwd1!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"password")
                    multipartFormData.appendBodyPart(data:(name ?? "defaultName").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!, name :"user_name")
                },
                encodingCompletion: { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _):
                        upload.responseJSON { response in
                            debugPrint(response)
                            let json = JSON(response.result.value ?? [])
                            if let status = json["status"].string {
                                if status == "340" {
                                    self.hud?.hideHUD(withText: "注册成功", andDelay: 1.0)
                                    return
                                }
                            }
                            self.hud?.hideHUD(withText: "注册失败", andDelay: 1.0)
                        }
                    case .Failure(let encodingError):
                        print(encodingError)
                        self.hud?.hideHUD(withText: "\(encodingError)", andDelay: 1.0)
                    }
            })
            break
        }
    }

    // MARK: buk image picker delegate
    func buk_imagePickerController(imagePickerController: BUKImagePickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        print("didFinishPickingAssets")
        if assets.count == 0 {
            return
        }
        let asset = (assets[0] as! ALAsset)
        let image = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
        let photoEditViewController = BUKPhotoEditViewController(photo: image)
        photoEditViewController.delegate = self
        imagePickerController.presentViewController(photoEditViewController, animated: true, completion: nil)
    }

    // MARK: BUKPhotoEditViewControllerDelegate
    func buk_photoEditViewController(controller: BUKPhotoEditViewController!, didFinishEditingPhoto photo: UIImage!) {
        print("didFinishEditingPhoto: \(photo)")
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var photoData = UIImageJPEGRepresentation(photo, 1.0)
            var photoType = "jpeg"
            if photoData == nil {
                photoData = UIImagePNGRepresentation(photo)
                photoType = "png"
            }
            dispatch_async(dispatch_get_main_queue()) {
                self.imagePickerController!.dismissViewControllerAnimated(true) {
                    switch self.currentUploadType {
                    case .NULL:
                        break
                    case .IDCard:
                        self.idCardImageFileType = photoType
                        UIView.animateWithDuration(0.25, animations: { 
                            self.idCardUploadButton.backgroundColor = self.sendVerifyCodeButton.backgroundColor
                        })
                        self.idCardImageData = photoData
                    case .Permit:
                        self.permitImageFileType = photoType
                        UIView.animateWithDuration(0.25, animations: {
                            self.permitUploadButton.backgroundColor = self.sendVerifyCodeButton.backgroundColor
                        })
                        self.permitImageData = photoData
                    case .Car:
                        self.carImageFileType = photoType
                        UIView.animateWithDuration(0.25, animations: {
                            self.carUploadButton.backgroundColor = self.sendVerifyCodeButton.backgroundColor
                        })
                        self.carImageData = photoData
                    }
                }
            }
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func buk_photoEditViewControllerDidCancelEditingPhoto(controller: BUKPhotoEditViewController!) {
        print("buk_photoEditViewControllerDidCancelEditingPhoto")
        dispatch_async(dispatch_get_main_queue()) {
            self.imagePickerController!.dismissViewControllerAnimated(true, completion: nil)
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func newUploadButton(withTitle title: String) -> UIButton {
        let uploadButton = UIButton(type: .System)
        uploadButton.backgroundColor = UIColor(hex6: 0x0079FF)
        uploadButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        uploadButton.titleLabel?.font = mobileTextField.font
        uploadButton.setTitle(title, forState: .Normal)
        uploadButton.layer.cornerRadius = 5.0
        uploadButton.addTarget(self, action: #selector(uploadButtonPressed), forControlEvents: .TouchUpInside)
        return uploadButton;
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
}
