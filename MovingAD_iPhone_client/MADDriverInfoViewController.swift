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
    @IBAction func drivingLicenceSignDateChosen(sender: UIDatePicker) {
    }
    
    @IBAction func drivingLicenceDueDateChosen(sender: UIDatePicker) {
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
