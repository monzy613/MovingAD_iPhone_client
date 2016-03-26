//
//  MADNewUserViewController.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MADNewUserViewController: UIViewController {
    private var devCount = 0
    private var devTimer: NSTimer?
    private var time: NSTimeInterval = 0
    private var maxTime: NSTimeInterval = 5
    
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var registerButton: DesignableButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func devBack(sender: UIButton) {
        devCount += 1
        if let _ = devTimer {
            time = 0
            devTimer?.invalidate()
            devTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MADNewUserViewController.devJudge), userInfo: nil, repeats: true)
            if devCount >= 4 {
                devCount = 0
                time = 0
                devTimer?.invalidate()
                devTimer = nil
                devMode()
            }
        } else {
            devTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(MADNewUserViewController.devJudge), userInfo: nil, repeats: true)
        }
    }
    
    func devJudge() {
        time += 1
        if time >= maxTime {
            time = 0
            if devCount < 4 {
                devCount = 0
                devTimer?.invalidate()
                devTimer = nil
            } else {
                devMode()
            }
        }
    }
    
    func devMode() {
        print("enter dev mode")
        let serverlistAlert = UIAlertController(title: "Choose Server", message: "chose a server", preferredStyle: .ActionSheet)
        serverlistAlert.addAction(UIAlertAction(title: "121.42.214.153", style: .Default, handler: {
            action in
            MADURL.ip = "121.42.214.153"
        }))
        serverlistAlert.addAction(UIAlertAction(title: "42.96.155.17", style: .Default, handler: {
            action in
            MADURL.ip = "42.96.155.17"
        }))
        serverlistAlert.addAction(UIAlertAction(title: "Default", style: .Cancel, handler: {
            action in
        }))
        self.presentViewController(serverlistAlert, animated: true, completion: nil)
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
