//
//  MADHomeViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/23.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import Alamofire
import MZPopView
import BabyBluetooth

class MADHomeViewController: UIViewController {
    @IBOutlet weak var avatarImageView: DesignableImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var checkStateLabel: DesignableButton!


    lazy var textView: UITextView! = {
        let tv = UITextView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 60.0, 80.0))
        tv.backgroundColor = UIColor.clearColor()
        return tv
    }()

    lazy var sendButton: UIButton! = {
        let button = UIButton(type: .System)
        button.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 60.0, 10, 60.0, 60.0)
        button.addTarget(self, action: #selector(sendButtonPressed), forControlEvents: .TouchUpInside)
        button.setTitle("发送", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        return button
    }()

    lazy var popTextField: MZPopView! = {
        let popView = MZPopView(frame: CGRectMake(0, 80, CGRectGetWidth(self.view.bounds), 80.0))
        popView.contentView.addSubview(self.textView)
        popView.contentView.addSubview(self.sendButton)
        self.view.addSubview(popView)
        return popView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDriverInfo()
    }

    @IBAction func sendCustomInfoButtonPressed(sender: UIBarButtonItem) {
        popTextField.popDownFromPoint(CGPointMake(view.center.x, 80.0))
    }

    @IBAction func tapGestureHandler(sender: UITapGestureRecognizer) {
        dismissPopTextView()
    }

    func sendButtonPressed(sender: UIButton) {
        dismissPopTextView()
        if textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" || MADTabViewController.isConnectedToCentral == false {
            return
        }
        MADTabViewController.customMessage = textView.text
    }

    // MARK: private
    private func dismissPopTextView() {
        popTextField.endEditing(true)
        popTextField.popBack()
    }

    private func changeCheckLabelColor(color: UIColor) {
        checkStateLabel.borderColor = color
        checkStateLabel.setTitleColor(color, forState: .Normal)
    }

    private func setupDriverInfo() {
        username.text = MADUserInfo.currentUserInfo?.name ?? ""
        phoneLabel.text = MADUserInfo.currentUserInfo?.phone ?? ""
        idLabel.text =  MADUserInfo.currentUserInfo?.id ?? ""
        if MADUserInfo.currentUserInfo!.checkState != "未审核" {
            checkStateLabel.setTitle(MADUserInfo.currentUserInfo!.checkState, forState: .Normal)
            checkStateLabel.setTitleColor(UIColor.greenColor(), forState: .Normal)
        }
    }
}
