//
//  MADGetMoneyViewController.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 6/15/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import UIKit
import MBProgressHUD

class MADGetMoneyViewController: UIViewController {

    @IBOutlet weak var sumLabel: UILabel!
    @IBOutlet weak var moneyTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    var walletVC: MADWalletController?

    override func viewDidLoad() {
        super.viewDidLoad()
        let money = MADUserInfo.currentUserInfo?.account_money ?? 0.0
        sumLabel.text = "\(String.init(format: "%.3f", money)) 元"
    }
    
    @IBAction func confirmButtonPressed(sender: DesignableButton) {
        if let moneyText = moneyTextField.text, let password = passwordTextField.text {
            if password == "" {
                MBProgressHUD.validationHUD(withView: view, text: "请输入支付密码")
                return
            }
            if let money = Float(moneyText) {
                if money > MADUserInfo.currentUserInfo?.account_money ?? 0 {
                    MBProgressHUD.validationHUD(withView: self.view, text: "超出余额")
                } else {
                    if money == 0.0 {
                        MBProgressHUD.validationHUD(withView: self.view, text: "请输入大于0的金额")
                    } else {
                        let hud = MBProgressHUD.madLoading(inView: view, withText: "提现中")
                        MADNetwork.get(withURL: MADURL.get_money(moneyText, pay_pwd: password), parameters: nil, success: { (json) -> (Void) in
                            hud.hide(true)
                            self.dismissViewControllerAnimated(true, completion: nil)
                            print(json)
                            if let status = json["status"].string {
                                if status == "600" {
                                    MADUserInfo.currentUserInfo?.account_money -= money
                                    self.walletVC?.setMoney()
                                }
                            }
                            }, failure: { (error) -> (Void) in
                                hud.labelText = "\(error)"
                                hud.hide(true)
                                self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                }
            }
        }
    }

    @IBAction func cancelButtonPressed(sender: DesignableButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func tapHandler(sender: UITapGestureRecognizer) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
