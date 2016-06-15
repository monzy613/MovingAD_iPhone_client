//
//  MADWalletController.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 5/22/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import UIKit

class MADWalletController: UIViewController {

    // MARK: outlets
    @IBOutlet weak var cash: UILabel!

    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setMoney()
    }

    func setMoney() {
        let money = MADUserInfo.currentUserInfo?.account_money ?? 0.0
        cash.text = "余额: \(String.init(format: "%.3f", money)) 元"
    }

    // MARK: - actions -
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "退出登录", message: "确认退出登录？", preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: "是", style: .Destructive, handler: { (action) in
            MADData.sweepAllData()
            self.performSegueWithIdentifier("LogoutSegue", sender: self)
        }))
        alert.addAction(UIAlertAction(title: "否", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func getcashButtonPressed(sender: DesignableButton) {
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "GetMoneySegue" {
                let vc = segue.destinationViewController as! MADGetMoneyViewController
                vc.walletVC = self
            }
        }
    }
}
