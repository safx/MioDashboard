//
//  MIOResponseModel+Util.m
//  MioDashboard
//
//  Created by Safx Developer on 2014/10/17.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

#import <Underscore.h>
#import "MIOResponseModel.h"
#import "MIOResponseModel+Util.h"


@implementation MIOCouponInfo (Util)
- (int)totalVolume {
    return [Underscore.array(self.coupon).reduce(@0, ^id(NSNumber* v, MIOCoupon* e) {
        return @(v.intValue + e.volume);
    }) intValue];
}
@end


@implementation MIOCouponHdoInfo (Util)
- (int)totalPacketUsedWithCoupon {
    return [Underscore.array(self.packetLog).reduce(@0, ^id(NSNumber* v, MIOPacketLog* e) {
        return @(v.intValue + e.withCoupon);
    }) intValue];
}
@end

