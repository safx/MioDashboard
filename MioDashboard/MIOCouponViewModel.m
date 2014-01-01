//
//  MIOMIOCouponViewModel.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOResponseModel.h"
#import "MIOCouponViewModel.h"

@implementation MIOCouponViewModel

- (instancetype)initWithCouponInfo:(MIOCouponInfo*)couponInfo {
    self = [super init];
    if (self) {
        self.couponTotal = Underscore.array(couponInfo.coupon).reduce(@0, ^id(NSNumber* v, MIOCoupon* e) {
            return @(v.intValue + e.volume);
        });

        NSArray* coupons = Underscore.array(couponInfo.coupon).filter(^BOOL(MIOCoupon* e) {
            return e.volume > 0;
        }).map(^id(MIOCoupon* e) {
            NSString* expire = e.expire;
            NSString* y = [expire substringWithRange:NSMakeRange(0, 4)];
            NSString* m = [expire substringWithRange:NSMakeRange(4, 2)];
            NSString* date = [NSString stringWithFormat:NSLocalizedString(@"〜%@.%@", @"〜%@.%@"), y, m];
            return @{@"label":date, @"type":e.type, @"volume":@(e.volume)};
        }).unwrap;

        NSArray* usages = Underscore.array(couponInfo.hdoInfo).map(^id(MIOCouponHdoInfo* hdoInfo) {
            int sum = [Underscore.array(hdoInfo.packetLog).reduce(@0, ^id(NSNumber* v, MIOPacketLog* e) {
                return @(v.intValue + e.withCoupon);
            }) intValue];
            return @[@{@"label":hdoInfo.hdoServiceCode, @"type":@"used", @"volume":@(sum)}];
        }).unwrap;
        
        self.slices = Underscore.array(@[usages, coupons]).flatten.unwrap;
    }
    return self;
}
@end
