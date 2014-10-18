//
//  TodayViewController.swift
//  MioExtension
//
//  Created by Safx Developer on 2014/10/16.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var couponVolume: UILabel!
    @IBOutlet weak var usedToday: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        let helper = MIORestHelper.loadAccessToken()

        let coupon = RACSignal.defer { helper.loadInformationSignal() }
        helper.mergeInformationSignal(coupon).subscribeNext { (obj) -> Void in
            let couponInfo = obj as [MIOCouponInfo]
            if countElements(couponInfo) > 0 {
                let ci = couponInfo[0]

                self.couponVolume.text = NSByteCountFormatter.stringFromByteCount(1000 * 1000 * Int64(ci.totalVolume()), countStyle: .Decimal)

                var formatter = NSDateFormatter()
                formatter.dateFormat = "yyyyMMdd"
                let today = formatter.stringFromDate(NSDate())
                
                let todayUsed = ci.hdoInfo.reduce(0, combine: { (acc, elem) -> UInt in
                    let hdoInfo = elem as MIOCouponHdoInfo
                    let used = hdoInfo.packetLog.reduce(0, combine: { (a, e) -> UInt in
                        let p = e as MIOPacketLog
                        return a + (p.date == today ? p.withCoupon : 0)
                    })
                    return acc + used
                })
                if todayUsed > 0 {
                    let repl = NSByteCountFormatter.stringFromByteCount(1000 * 1000 * Int64(todayUsed), countStyle: .Decimal)
                    self.usedToday.text = "−\(repl)"
                } else {
                    self.usedToday.textColor = UIColor.lightTextColor()
                    self.usedToday.text = "±0"
                }
                
                completionHandler(NCUpdateResult.NewData)
                return
            }
            self.couponVolume.text = "No data"
            self.couponVolume.textColor = UIColor.darkTextColor()
            completionHandler(NCUpdateResult.NoData)
        }

    }
    
}
