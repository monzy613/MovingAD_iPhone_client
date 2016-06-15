//
//  MADAdTableViewCell.swift
//  MovingAD_iPhone_client
//
//  Created by Monzy Zhang on 6/15/16.
//  Copyright © 2016 MonzyZhang. All rights reserved.
//

import UIKit

class MADAdTableViewCell: UITableViewCell {
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .ByWordWrapping
        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIColor.lightGrayColor()
        return label
    }()

    lazy var moneyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10)
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(moneyLabel)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        contentLabel.text = ""
        timeLabel.text = ""
        moneyLabel.text = ""
    }

    // MARK: - public
    func configWithAD(ad: MADAd) {
        contentLabel.text = ad.text ?? "[图片类型]"
        timeLabel.text = ad.shortDate
        moneyLabel.text = "RMB \(ad.money)"
    }

    // MARK: - private
    private func setupConstraints() {
        contentLabel.snp_makeConstraints { (make) in
            make.left.top.bottom.equalTo(contentView).inset(5.0)
            make.right.equalTo(contentView).inset(75.0)
        }
        timeLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp_right).offset(5.0)
            make.right.equalTo(contentView).inset(5.0)
            make.top.equalTo(contentLabel)
            make.bottom.equalTo(moneyLabel.snp_top)
        }
        moneyLabel.snp_makeConstraints { (make) in
            make.left.equalTo(contentLabel.snp_right).offset(5.0)
            make.right.equalTo(contentView).inset(5.0)
            make.bottom.equalTo(contentLabel)
            make.height.equalTo(timeLabel)
        }
    }
}
