//
//  MIOTableViewCell.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOTableViewCell.h"
#import "MIOResponseModel.h"
#import "MIOResponseModel+Util.h"
#import "MIOServiceViewModel.h"


@implementation MIOHdoServiceCodeCell
- (void)setModelWithCouponHdoInfo:(MIOCouponHdoInfo*)couponHdoInfo {
    self.couponHdoInfo = couponHdoInfo;

    NSString* a = [couponHdoInfo.number substringWithRange:NSMakeRange(0, 3)];
    NSString* b = [couponHdoInfo.number substringWithRange:NSMakeRange(3, 4)];
    NSString* c = [couponHdoInfo.number substringFromIndex:7];
    self.numberLabel.text = [NSString stringWithFormat:@"%@-%@-%@", a, b, c];

    self.iccIdCodeLabel.text = couponHdoInfo.iccid;
    self.regulationLabel.hidden = !couponHdoInfo.regulation;
    self.smsLabel.hidden = !couponHdoInfo.sms;
    RAC(self.couponSwitch, on) = RACObserve(self.couponHdoInfo, couponUse);
    
    long long total = couponHdoInfo.totalPacketUsedWithCoupon;
    self.couponUsedLabel.text = [NSByteCountFormatter stringFromByteCount:total * 1000 * 1000 countStyle:NSByteCountFormatterCountStyleDecimal];
}

- (IBAction)onCouponSwitchTouched:(UISwitch *)sender {
    [self.viewModel changeCouponUse:sender.on forHdoInfo:self.couponHdoInfo];
}
@end


@implementation MIOCouponCell
- (void)setModelWithCouponInfo:(MIOCouponInfo*)couponInfo {
    self.couponInfo = couponInfo;
    
    long long total = couponInfo.totalVolume;
    self.couponLabel.text = [NSByteCountFormatter stringFromByteCount:total * 1000 * 1000 countStyle:NSByteCountFormatterCountStyleDecimal];
}
@end

