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
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        func format(megabytes: Int32) -> String {
            return NSByteCountFormatter.stringFromByteCount(1000 * 1000 * Int64(megabytes), countStyle: .Decimal)
        }
        
        let helper = MIORestHelper.loadAccessToken()
        let coupon = RACSignal.defer { helper.loadInformationSignal() }
                              .catch { (error) -> RACSignal! in
                                if let data = error.localizedRecoverySuggestion?.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true) {
                                    var err: NSError? = nil
                                    let dic = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as [String:AnyObject]?
                                    if err == nil {
                                        if let ret = dic!["returnCode"] as? String {
                                            if ret == "User Authorization Failure" {
                                                if helper.accessToken != nil {
                                                    helper.accessToken = nil;
                                                    return helper.refreshToken().catch { (e) -> RACSignal! in
                                                        return RACSignal.empty()
                                                    }.concat(helper.loadInformationSignal())
                                                }
                                            }
                                        }
                                    }
                                }
                                return RACSignal.empty()
                              }
        let merged = helper.mergeInformationSignal(coupon)
        
        merged.timeout(10, onScheduler: RACScheduler.currentScheduler())
            .subscribeNext({ (obj) -> Void in
                let couponInfo = obj as [MIOCouponInfo]
                if countElements(couponInfo) > 0 {
                    let ci = couponInfo[0]
                    
                    self.couponVolume.text = format(ci.totalVolume())
                    
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
                        let repl = format(Int32(todayUsed))
                        self.usedToday.text = "−\(repl)"
                    } else {
                        self.usedToday.textColor = UIColor.lightTextColor()
                        self.usedToday.text = "±0"
                    }
                    
                    completionHandler(.NewData)
                    return
                }
                self.couponVolume.text = "No data"
                self.couponVolume.textColor = UIColor.darkTextColor()
                completionHandler(.NoData)
            }, error: { (error) -> Void in
                completionHandler(.Failed)
            })
    }
}
