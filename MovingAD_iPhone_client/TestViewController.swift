
//
//  TestViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit
import MBProgressHUD

class TestViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        /*
         MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
         hud.mode = MBProgressHUDModeAnnularDeterminate;
         hud.labelText = @"Loading";
         */
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = "登录中"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
