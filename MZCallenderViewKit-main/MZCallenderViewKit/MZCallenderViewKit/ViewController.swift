//
//  ViewController.swift
//  MZCallenderViewKit
//
//  Created by suhengxian on 2022/1/10.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = .white
        
        let calendarKit = MZCalendarKit(frame: CGRect(x: 0, y:100, width: UIScreen.main.bounds.size.width, height:290))
        calendarKit.backgroundColor = UIColor.blue
        
        calendarKit.select { beginDate, endDate in
            
        }
        self.view.addSubview(calendarKit)
        
    }
}

