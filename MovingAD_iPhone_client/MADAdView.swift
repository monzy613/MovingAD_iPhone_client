//
//  MADAdView.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 5/23/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import UIKit
import SnapKit

class MADAdView: UIView {
    //weak var deledate: FBTextTimelineViewDelegate?
    var widthProportion: CGFloat = 0.747
    var heightProportion: CGFloat = 0.375
    var isImage = false

    lazy var contentView: UIView = {
        let _contentView = UIView()
        _contentView.layer.shadowOpacity = 1.0
        _contentView.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        _contentView.backgroundColor = UIColor.whiteColor()
        return _contentView
    }()

    lazy var textView: UITextView = {
        let _textView = UITextView()
        _textView.font = UIFont.systemFontOfSize(14.0)
        _textView.textColor = UIColor.blackColor()
        _textView.editable = false
        return _textView
    }()

    lazy var imageView: UIImageView = {
        let _imgView = UIImageView()
        _imgView.contentMode = .ScaleAspectFit
        return _imgView
    }()

    // MARK: public
    func setupImage(image: UIImage) {
        isImage = true
        let size = image.size
        heightProportion = widthProportion * size.height / size.width
        contentView.addSubview(imageView)
        imageView.image = image
        setupConstraints()
    }

    func setupText(text: String) {
        isImage = false
        contentView.addSubview(textView)
        textView.text = text
        setupConstraints()
    }

    func show() {
        UIView.animateWithDuration(0.25) { 
            self.contentView.snp_remakeConstraints { (make) in
                make.center.equalTo(self)
                make.width.equalTo(self).multipliedBy(self.widthProportion)
                make.height.equalTo(self).multipliedBy(self.heightProportion)
            }
            self.layoutIfNeeded()
        }
    }

    func hide() {
        UIView.animateWithDuration(0.25, animations: {
            self.contentView.snp_remakeConstraints { (make) in
                make.centerY.equalTo(self)
                make.left.equalTo(self.snp_right)
                make.width.equalTo(self).multipliedBy(self.widthProportion)
                make.height.equalTo(self).multipliedBy(self.heightProportion)
            }
            self.layoutIfNeeded()
            }) { (finished) in
                self.removeFromSuperview()
        }
    }

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - private
    private func setupConstraints() {
        contentView.snp_makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self.snp_left)
            make.width.equalTo(self).multipliedBy(widthProportion)
            make.height.equalTo(self).multipliedBy(heightProportion)
        }
        if isImage {
            imageView.snp_makeConstraints { (make) in
                make.edges.equalTo(contentView).inset(5.0)
            }
        } else {
            textView.snp_makeConstraints { (make) in
                make.edges.equalTo(contentView).inset(5.0)
            }
        }
        layoutIfNeeded()
    }
}
