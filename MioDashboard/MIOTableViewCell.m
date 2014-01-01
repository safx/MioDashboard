//
//  MIOTableViewCell.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOTableViewCell.h"
#import "MIOResponseModel.h"
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
    self.couponSwitch.on = couponHdoInfo.couponUse;
    
    int total = [Underscore.array(couponHdoInfo.packetLog).reduce(@0, ^id(NSNumber* v, MIOPacketLog* e) {
        return @(v.intValue + e.withCoupon);
    }) intValue];
 
    self.couponUsedLabel.text = [NSByteCountFormatter stringFromByteCount:total * 1000 * 1000 countStyle:NSByteCountFormatterCountStyleDecimal];
}

- (IBAction)onCouponSwitchTouched:(UISwitch *)sender {
    [self.viewModel changeCouponUse:sender.on forHdoInfo:self.couponHdoInfo];
}
@end


@implementation MIOCouponCell
- (void)setModelWithCouponInfo:(MIOCouponInfo*)couponInfo {
    self.couponInfo = couponInfo;
    
    int total = [Underscore.array(couponInfo.coupon).reduce(@0, ^id(NSNumber* v, MIOCoupon* e) {
        return @(v.intValue + e.volume);
    }) intValue];

    self.couponLabel.text = [NSByteCountFormatter stringFromByteCount:total * 1000 * 1000 countStyle:NSByteCountFormatterCountStyleDecimal];
}
@end

