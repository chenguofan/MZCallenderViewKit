//
//  UIViewExtension.swift
//  MZCallenderViewKit
//
//  Created by suhengxian on 2022/1/10.
//

import Foundation
import UIKit

extension UIView{
    var width:CGFloat{
        return self.frame.size.width
    }
    
    var right:CGFloat{
        return self.frame.size.width + self.frame.origin.x
    }
    
    var height:CGFloat{
        return self.frame.size.height
    }
    
    var bottom:CGFloat{
        return self.frame.origin.y + self.frame.size.height
    }
    
    var centerY:CGFloat{
        return (self.frame.origin.y + self.frame.size.height)/2.0
    }
    
}
