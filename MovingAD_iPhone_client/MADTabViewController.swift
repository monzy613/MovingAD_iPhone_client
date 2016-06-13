//
//  MADTabViewController.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 6/13/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import UIKit
import BATabBarController

class MADTabViewController: UIViewController, BATabBarControllerDelegate {
    var baTabBarController: BATabBarController!

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewControllers()
    }

    // MARK: - private
    private func initViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = storyboard.instantiateViewControllerWithIdentifier("MADHomeViewController") as! MADHomeViewController
        let mapViewController = storyboard.instantiateViewControllerWithIdentifier("MADMapViewController") as! MADMapViewController
        let walletViewController = storyboard.instantiateViewControllerWithIdentifier("MADWalletController") as! MADWalletController
        let walletNavigationController = UINavigationController(rootViewController: walletViewController)

        let homeTabItem = BATabBarItem(image: UIImage(named: "home"), selectedImage: UIImage(named: "home"))
        let mapTabItem = BATabBarItem(image: UIImage(named: "compass"), selectedImage: UIImage(named: "compass"))
        let walletTabItem = BATabBarItem(image: UIImage(named: "account"), selectedImage: UIImage(named: "account"))

        baTabBarController = BATabBarController()
        baTabBarController.viewControllers = [homeViewController, mapViewController, walletNavigationController]
        baTabBarController.tabBarItems = [homeTabItem, mapTabItem, walletTabItem]
        baTabBarController.delegate = self
        baTabBarController.tabBarBackgroundColor = UIColor.blackColor()
        baTabBarController.tabBarItemStrokeColor = UIColor(hex6: 0x4A90E2)
        view.addSubview(baTabBarController.view)
    }

    // MARK: - delegate
    // MARK: - BATabBarControllerDelegate -
    func tabBarController(tabBarController: BATabBarController!, didSelectViewController viewController: UIViewController!) {

    }
}
