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

class MADHomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var avatarImageView: DesignableImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var checkStateLabel: DesignableButton!

    static var sharedInstance: MADHomeViewController?

    var customPopViewToggled = false
    var historyToggled = false

    lazy var textView: UITextView! = {
        let tv = UITextView(frame: CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 60.0, 80.0))
        tv.backgroundColor = UIColor.clearColor()
        return tv
    }()

    lazy var tableView: UITableView! = {
        let tv = UITableView(frame: CGRectMake(5, 5, CGRectGetWidth(self.view.bounds) - 20, CGRectGetHeight(self.view.bounds) - 180))
        tv.registerClass(MADAdTableViewCell.self, forCellReuseIdentifier: MADAdTableViewCell.self.description())
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()

    lazy var sendButton: UIButton! = {
        let button = UIButton(type: .System)
        button.frame = CGRectMake(CGRectGetWidth(self.view.bounds) - 60.0, 5, 60.0, 60.0)
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


    var popTableViewFrame: CGRect {
        get {
            return CGRectMake(0, 80, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) - 160)
        }
    }

    lazy var popTableView: MZPopView! = {
        let popView = MZPopView(frame: self.popTableViewFrame)
        popView.contentView.addSubview(self.tableView)
        self.view.addSubview(popView)
        return popView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        MADHomeViewController.sharedInstance = self
        setupDriverInfo()
    }

    @IBAction func sendCustomInfoButtonPressed(sender: UIBarButtonItem) {
        dismissHistory()
        if customPopViewToggled {
            dismissCustom()
        } else {
            popTextField.popDownFromPoint(CGPointMake(view.center.x, 80.0))
            customPopViewToggled = true
        }
    }

    @IBAction func historyButtonPressed(sender: UIBarButtonItem) {
        dismissCustom()
        if historyToggled {
            dismissHistory()
        } else {
            popTableView.popDownFromPoint(CGPointMake(view.center.x, 80.0))
            historyToggled = true
        }
    }

    @IBAction func tapGestureHandler(sender: UITapGestureRecognizer) {
        dismissPopViews()
    }

    func sendButtonPressed(sender: UIButton) {
        dismissPopViews()
        if textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" || MADTabViewController.isConnectedToCentral == false {
            return
        }
        MADTabViewController.customMessage = textView.text
    }

    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK: - UITableViewDatasource
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MADAd.history.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(MADAdTableViewCell.self.description(), forIndexPath: indexPath) as! MADAdTableViewCell
        if indexPath.row < MADAd.history.count {
            cell.configWithAD(MADAd.history[indexPath.row])
        }
        return cell
    }

    // MARK: private
    private func dismissCustom() {
        popTextField.endEditing(true)
        popTextField.popBack()
        customPopViewToggled = false
    }

    private func dismissHistory() {
        popTableView.popBack()
        historyToggled = false
    }

    private func dismissPopViews() {
        dismissCustom()
        dismissHistory()
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
            changeCheckLabelColor(UIColor.greenColor())
        }
    }
}
