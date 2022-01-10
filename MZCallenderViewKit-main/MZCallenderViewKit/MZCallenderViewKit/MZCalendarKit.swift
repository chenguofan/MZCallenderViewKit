//
//  MZCalendarKit.swift
//  MZCalendar
//
//  Created by Jerry.li on 2018/10/17.
//  Copyright © 2018年 51app. All rights reserved.
//

import UIKit

let kScreenWidth = UIScreen.main.bounds.size.width

typealias SelectDateClosure = (_ beginDate:Date,_ endDate:Date)->Void

class MZCalendarKit: UIView {
    
    fileprivate var identifier: String = "daysCell"
    fileprivate var date = Date()
    //选中的日期
    fileprivate var date1:Date?
    //30天后的日期
    fileprivate var date2:Date?
    fileprivate var isCurrentMonth: Bool = false //是否当月
    fileprivate var currentMonthTotalDays: Int = 0 //当月的总天数
    fileprivate var firstDayIsWeekInMonth: Int = 0 //每月的一号对于的周几
    
    //获取最后一次选中的索引
    fileprivate let today: String = String(MZDateUtils.day(Date()))  //当天几号
    fileprivate var selectDateClosure:SelectDateClosure?
    //日历格式
    private lazy var dateFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    //日历控件头部
    private lazy var calendarHeadView: UIView = {
        let calendarHeadView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 64))
        calendarHeadView.backgroundColor = UIColor.blue
        return calendarHeadView
    }()
    
    //日历控件title
    fileprivate lazy var dateLabel: UILabel = {
        let labelWidth: CGFloat = 100.0
        let originX: CGFloat = (kScreenWidth - labelWidth) / 2.0
        let dateLabel = UILabel(frame: CGRect(x: originX, y: 5, width: labelWidth, height: 20))
        dateLabel.textAlignment = .center
        dateLabel.textColor = UIColor.white
        dateLabel.font = UIFont.systemFont(ofSize: 18)
        dateLabel.backgroundColor = UIColor.clear
        return dateLabel
    }()
    
    //上个月
    fileprivate lazy var lastMonthButton: UIButton = {
        let last = self.createButton(imageName: "last_month_normal", disabledImage: "last_month_enabled")
        last.frame.origin.x = self.dateLabel.frame.minX - last.width - 5
        last.addTarget(self, action: #selector(lastAction), for: .touchUpInside)
        return last
    }()
    
    //下个月
    fileprivate lazy var nextMonthButton: UIButton = {
        let next = self.createButton(imageName: "next_month_normal", disabledImage: "next_month_enabled")
        next.frame.origin.x = self.dateLabel.right
        next.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return next
    }()
    
    private lazy var weekView: UIView = {
        var paddingLeft = 0.0
        if kScreenWidth == 320{
            paddingLeft = 9.5
        }else if kScreenWidth == 375{
            paddingLeft = 12.5
        }else if (kScreenWidth == 414){
            paddingLeft = 11.0
        }else{
            paddingLeft = 10.0
        }
        let originY: CGFloat = self.calendarHeadView.height - 13.0 - 15.0
        let weekView = UIView(frame: CGRect(x: paddingLeft, y: originY, width: kScreenWidth - paddingLeft * 2, height: 15))
        weekView.backgroundColor = UIColor.clear
        
        //week
        var weekArray = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
        var originX: CGFloat = 0.0
        for weekStr in weekArray {
            let week = UILabel()
            week.frame = CGRect(x: originX, y: 0, width: CollectionRect().itemWidth!, height: 15)
            week.text = weekStr
            week.textColor = UIColor.white
            week.font = UIFont.boldSystemFont(ofSize: 15)
            week.textAlignment = .center
            weekView.addSubview(week)
            originX = week.frame.maxX
        }
        return weekView
    }()
    
    private func createButton(imageName: String, disabledImage: String) -> UIButton {
        let image: UIImage = UIImage.init(named: imageName)!
        let button = UIButton(type: .custom)
        let originY: CGFloat = self.dateLabel.centerY - image.size.height / 2
        button.frame = CGRect(x: 0, y: originY, width: image.size.width, height: image.size.height)
        button.setBackgroundImage(image, for: .normal)
        button.setBackgroundImage(image, for: .highlighted)
        button.setBackgroundImage(UIImage(named: disabledImage), for: .disabled)
        return button
    }
    
    fileprivate lazy var calendarCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = CollectionRect().margin
        flowLayout.minimumInteritemSpacing = CollectionRect().margin

        let collectionWidth = kScreenWidth - 2 * CollectionRect().paddingLeft!
        
        let itemWidth = (kScreenWidth - 2 * CollectionRect().paddingLeft!)/7.0
        flowLayout.itemSize = CGSize.init(width: itemWidth, height: CollectionRect().itemHeight!)

        flowLayout.scrollDirection = .vertical
        flowLayout.sectionFootersPinToVisibleBounds = true
        flowLayout.sectionFootersPinToVisibleBounds = false
        
        let tempRect = CGRect(x:CollectionRect().paddingLeft!, y: self.calendarHeadView.bottom, width: collectionWidth, height:self.height - 64)
        
        let calendarCollectionView = UICollectionView(frame: tempRect, collectionViewLayout:flowLayout)
        calendarCollectionView.backgroundColor = UIColor.blue
        calendarCollectionView.dataSource = self
        calendarCollectionView.delegate = self
        calendarCollectionView.register(MZDaysCell.self, forCellWithReuseIdentifier: self.identifier)
        return calendarCollectionView
        
    }()
    
    private var shapeLayer:CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //init
        _initCalendarInfo()
        
        self.addSubview(calendarHeadView)
        calendarHeadView.addSubview(dateLabel)
        calendarHeadView.addSubview(lastMonthButton)
        calendarHeadView.addSubview(nextMonthButton)
        calendarHeadView.addSubview(weekView)
        
        self.addSubview(calendarCollectionView)
        self.backgroundColor = UIColor.blue
        
        let date = Date()
        let dateStr1 = self.dateFormatter.string(from: date)
        
        self.date1 = self.dateFormatter.date(from: dateStr1)
        self.date2 = self.date1!.addingTimeInterval(24 * 60 * 60 * 29)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //初始化日历信息
    func _initCalendarInfo() {
        //当前月份的总天数
        self.currentMonthTotalDays = MZDateUtils.daysInCurrMonth(date: date)
        
        //当前月份第一天是周几
        self.firstDayIsWeekInMonth = MZDateUtils.firstDayIsWeekInMonth(date: date)
        
        self.dateLabel.text = MZDateUtils.stringFromDate(date: date, format: "yyyy-MM")
        
        //是否当月
        let nowDate: String = MZDateUtils.stringFromDate(date: Date(), format: "yyyy-MM")
        self.isCurrentMonth = nowDate == self.dateLabel.text
        
        //重置日历高度
        let days = self.currentMonthTotalDays + self.firstDayIsWeekInMonth
        var rowCount:Int = 4
        if days % 7 == 0{
            rowCount = (days/7)
        }else{
            rowCount = (days/7) + 1
        }
        
        let kitHeight:CGFloat = CGFloat(rowCount) * CollectionRect().itemHeight! + CGFloat(rowCount) * CollectionRect().margin
        calendarCollectionView.frame.size.height = kitHeight
    }
}

extension MZCalendarKit: UICollectionViewDelegate, UICollectionViewDataSource {
    //UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let days = self.currentMonthTotalDays + self.firstDayIsWeekInMonth
        return days
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier, for: indexPath) as! MZDaysCell
        cell.clearDaysLabelStyle()

        if cell.daysLabel.text == ""{
            cell.isSelectedItem = false
        }
        
        var day = 0
        let index = indexPath.row
        
        if index < self.firstDayIsWeekInMonth {
            cell.daysLabel.text = ""
        } else {
            day = index - self.firstDayIsWeekInMonth + 1
            cell.daysLabel.text = String(day)
            
            if isCurrentMonth {
                //当月当天以前的日期置灰，不可点击
                let itemValue = cell.daysLabel.text!
                let currDay = Int(itemValue)
                
                if  currDay! < Int(today)! {
                    cell.isDisable = true
                }
                
                if currDay! == Int(today)!{
                    cell.isToday = true
                }
            }
            
            if cell.daysLabel.text != ""{
                let dayStr = cell.daysLabel.text!
                let cellDateStr = self.dateLabel.text! + "-" + dayStr
                let cellDate = self.dateFormatter.date(from: cellDateStr)
                
                if (cellDate!.compare(self.date1!) == .orderedDescending && cellDate!.compare(self.date2!) == .orderedAscending) || (cellDate!.compare(self.date1!) == .orderedSame) ||
                    cellDate!.compare(self.date2!) == .orderedSame{
                    
                    cell.isSelectedItem = true
                    
                    if cellDate!.compare(self.date1!) == .orderedSame {
                        cell.isHead = true
                    }
                    
                    if cellDate!.compare(self.date2!) == .orderedSame{
                        cell.isFoot = true
                    }
                    
                    print("self.date1:\(self.date1!)")
                    print("self.date2:\(self.date2!)")
                    print("cellDate:,\(cellDate)")
                    
                }
            }
        }
        return cell
    }
    
    //UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //刷新界面
        let cell = self.calendarCollectionView.cellForItem(at:indexPath) as! MZDaysCell
        let dayStr = cell.daysLabel.text

        let selectStr = self.dateLabel.text! + "-" + dayStr!
        let seletDate = self.dateFormatter.date(from: selectStr)
        if seletDate!.compare(Date()) == .orderedAscending{
            print("比当前日期小的不能选")
            return
        }

        self.date1 = dateFormatter.date(from: selectStr)
        self.date2 = self.date1?.addingTimeInterval(24 * 60 * 60 * 30)
        self.calendarCollectionView.reloadData()
        self.selectDateClosure?(self.date1!,self.date2!)
        
    }
    
    func select(selectDateClosure:@escaping SelectDateClosure){
        self.selectDateClosure = selectDateClosure
    }
}

extension MZCalendarKit {
    @objc func lastAction() {
        self.date = MZDateUtils.lastMonth(date)
        self._initCalendarInfo()
        calendarCollectionView.reloadData()
        
    }
    
    @objc func nextAction() {
        self.date = MZDateUtils.nextMonth(date)
        self._initCalendarInfo()
        calendarCollectionView.reloadData()
    }
}

struct CollectionRect{
    let margin: CGFloat = 0.0
    var paddingLeft:CGFloat?{
        if kScreenWidth == 320{
            return 9.5
        }else if kScreenWidth == 375{
            return 12.5
        }else if (kScreenWidth == 414){
            return 11.0
        }else{
            return 10.0
        }
    }
    
    var itemWidth:CGFloat?{
        return (kScreenWidth - 2 * (paddingLeft ?? 0.0)) / 7.0
    }
    
    var itemHeight:CGFloat?{
        return (220 - margin * 5)/6.0 - 0.15
    }
    
}

