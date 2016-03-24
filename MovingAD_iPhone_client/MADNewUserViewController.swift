//
//  MADNewUserViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADNewUserViewController: UIViewController {
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var registerButton: DesignableButton!

    
    func animateButtons() {
        loginButton.animation = "slideUp"
        registerButton.animation = "slideUp"
        loginButton.animate()
        registerButton.animate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animateButtons()
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
