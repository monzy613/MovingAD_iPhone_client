//
//  MADDriverInfoViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/23.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADDriverInfoViewController: UIViewController {
    
    // Mark iboutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: DesignableTextField!
    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var identityTextField: DesignableTextField!
    @IBOutlet weak var drivingLicenceLabel: UILabel!
    @IBOutlet weak var drivingLicenceDueDate: UILabel!
    

    
    
    
    // Mark actions
    @IBAction func logoutButtonPressed(sender: UIBarButtonItem) {
        let logoutAlert = UIAlertController(title: "退出登录", message: "要退出登录吗", preferredStyle: .Alert)
        logoutAlert.addAction(UIAlertAction(title: "是", style: .Destructive, handler: {
            action in
            self.tabBarController?.performSegueWithIdentifier(MADSegues.logout, sender: self.tabBarController!)
        }))
        logoutAlert.addAction(UIAlertAction(title: "否", style: .Default, handler: nil))
        self.presentViewController(logoutAlert, animated: true, completion: nil)
    }
    
    @IBAction func drivingLicenceSignDateChosen(sender: UIDatePicker) {
        print("licenceSignDate: \(sender.date)")
    }
    
    @IBAction func drivingLicenceDueDateChosen(sender: UIDatePicker) {
        print("licenceDueDate: \(sender.date)")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
