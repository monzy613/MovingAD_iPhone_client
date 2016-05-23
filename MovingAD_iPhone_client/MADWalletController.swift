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
        let money = MADUserInfo.currentUserInfo?.account_money ?? 0.0
        cash.text = "余额: \(String.init(format: "%.3f", money)) 元"
    }

    // MARK: - actions -
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        let newUserController = MADNewUserViewController()
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(newUserController, animated: true, completion: nil)
        }
    }

    @IBAction func getcashButtonPressed(sender: DesignableButton) {
    }
}
