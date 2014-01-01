//
//  MIODetailViewController.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNLineChart;
@class MIOCouponHdoInfo;

@interface MIOCouponUsageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)setModelWithCouponHdoInfo:(MIOCouponHdoInfo*)hdoInfo;
@end
