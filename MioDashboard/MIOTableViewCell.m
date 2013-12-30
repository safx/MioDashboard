//
//  MIOTableViewCell.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOTableViewCell.h"
#import "MIOResponse.h"
#import "MIOServiceViewModel.h"


@implementation MIOHdoServiceCodeCell
- (void)setModelWithCouponHdoInfo:(MIOCouponHdoInfo*)couponHdoInfo packetHdoInfo:(MIOPacketHdoInfo*)packetHdoInfo {
    self.couponHdoInfo = couponHdoInfo;
    self.packetHdoInfo = packetHdoInfo;
    
    self.hdoServiceCodeLabel.text = couponHdoInfo.hdoServiceCode;
    self.numberLabel.text = couponHdoInfo.number;
    self.regulationLabel.text = couponHdoInfo.regulation? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    self.smsLabel.text = couponHdoInfo.sms? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    self.couponSwitch.on = couponHdoInfo.couponUse;
    
    int total = [Underscore.array(packetHdoInfo.packetLog).reduce(@0, ^id(NSNumber* v, MIOPacketLog* e) {
        return @(v.intValue + e.withCoupon);
    }) intValue];
 
    self.couponUsedLabel.text = [NSByteCountFormatter stringFromByteCount:total * 1000 * 1000 countStyle:NSByteCountFormatterCountStyleDecimal];
}

- (IBAction)onCouponSwitchTouched:(UISwitch *)sender {
    [self.viewModel changeCouponUse:sender.on forHdoInfo:self.couponHdoInfo];
}
@end


@implementation MIOCouponCell
- (void)setModelWithCouponInfo:(MIOCouponInfo*)couponInfo packetHdoInfo:(MIOPacketLogInfo*)packetLogInfo {
    self.couponInfo = couponInfo;
    self.packetLogInfo = packetLogInfo;
    
    int total = [Underscore.array(couponInfo.coupon).reduce(@0, ^id(NSNumber* v, MIOCoupon* e) {
        return @(v.intValue + e.volume);
    }) intValue];

    self.couponLabel.text = [NSByteCountFormatter stringFromByteCount:total * 1000 * 1000 countStyle:NSByteCountFormatterCountStyleDecimal];
}
@end

