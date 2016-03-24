//
//  MZLoadingView.swift
//  MovingAD_iPhone_client
//
//  Created by 张逸 on 16/3/24.
//  Copyright © 2016年 MonzyZhang. All rights reserved.
//

import UIKit

class MZLoadingView: UIView {
    //subviews
    var blurView: UIVisualEffectView!
    
    init(blurStyle: UIBlurEffectStyle) {
        super.init(frame: CGRectMake(0, 100, 100, 100))
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))

        self.clipsToBounds = true
        self.layer.cornerRadius = 5
        self.addSubview(blurView)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // constraints
    func setupConstraints() {
        addConstraints([
            NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: blurView, attribute: .CenterX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: blurView, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: blurView, attribute: .Height, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: blurView, attribute: .Width, multiplier: 1.0, constant: 0)
            ])
    }
}
