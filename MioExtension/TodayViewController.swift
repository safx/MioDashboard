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

        let coupon = RACSignal.defer { helper.getCoupon() }
        coupon.subscribeNext { (obj) -> Void in
            var error : NSError? = nil
            let response = MTLJSONAdapter.modelOfClass(MIOCouponResponse.self, fromJSONDictionary: obj.first as NSDictionary, error: &error) as MIOCouponResponse?
            //println("\(response) \(error)")
            
            if response == nil {
                completionHandler(NCUpdateResult.Failed)
                self.couponVolume.text = "Error"
                self.couponVolume.textColor = UIColor(red: 234.0/255, green: 99.0/255, blue: 69.0/255, alpha: 1)
                return
            }
            
            if let couponInfo = response!.couponInfo as? [MIOCouponInfo] {
                if countElements(couponInfo) > 0 {
                    let total = couponInfo[0].totalVolume()
                    self.couponVolume.text = NSByteCountFormatter.stringFromByteCount(1000 * 1000 * Int64(total), countStyle: .Decimal)
                    completionHandler(NCUpdateResult.NewData)
                    return
                }
            }
            self.couponVolume.text = "No data"
            self.couponVolume.textColor = UIColor.darkTextColor()
            completionHandler(NCUpdateResult.NoData)
        }

    }
    
}
