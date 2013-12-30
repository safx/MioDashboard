//
//  MIODetailViewController.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNLineChart;
@class MIOPacketHdoInfo;

@interface MIOCouponUsageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (void)setModelWithpacketHdoInfo:(MIOPacketHdoInfo*)packetHdoInfo;
@end
