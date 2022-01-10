//
//  MZDaysCell.swift
//  MZCalendar
//
//  Created by Jerry.li on 2018/10/17.
//  Copyright © 2018年 51app. All rights reserved.
//

import UIKit

class MZDaysCell: UICollectionViewCell {
    
    lazy var daysLabel: UILabel = {
        let frame = CGRect(x: 0, y: 0, width: CollectionRect().itemWidth!, height:CollectionRect().itemHeight!)
        let daysLabel = UILabel(frame:frame)
        daysLabel.textAlignment = .center
        daysLabel.font = UIFont.systemFont(ofSize: 14)
        daysLabel.textColor = UIColor.white
        return daysLabel
    }()
    
    lazy var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()
    
    var isSelectedItem: Bool = false {
        didSet {
            if isSelectedItem {
                self.daysLabel.backgroundColor = UIColor.green
            } else {
                self.daysLabel.backgroundColor = UIColor.blue
            }
        }
    }
    
    var isToday:Bool = false{
        didSet{
            if isToday{
                self.daysLabel.textColor = UIColor.red
            }
        }
    }
    
    //是否禁用
    var isDisable: Bool = false {
        didSet {
            if isDisable {
                self.daysLabel.textColor = UIColor.lightGray
            }
        }
    }
    
    var isHead:Bool = false{
        didSet{
            if isHead{
                let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft,.bottomLeft], cornerRadii: CGSize(width: self.daysLabel.height/2.0, height: self.daysLabel.height/2.0))
                    self.shapeLayer.frame = self.daysLabel.bounds
                    self.shapeLayer.path = maskPath.cgPath
                    self.daysLabel.layer.mask = self.shapeLayer
            }
        }
    }
    
    var isFoot:Bool = false{
        didSet{
            if isFoot{
                let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topRight,.bottomRight], cornerRadii: CGSize(width: self.daysLabel.height/2.0, height: self.daysLabel.height/2.0))
                self.shapeLayer.frame = self.daysLabel.bounds
                self.shapeLayer.path = maskPath.cgPath
                self.daysLabel.layer.mask = self.shapeLayer
            }
        }
    }
    
    //清除现有日期label上的所有样式
    func clearDaysLabelStyle() {
        daysLabel.text = ""
        daysLabel.textColor = UIColor.white
        self.shapeLayer.removeFromSuperlayer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addSubview(daysLabel)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
