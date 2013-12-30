//
//  MIOMIOCouponViewModel.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MIOCouponHdoInfo;
@class MIOPacketLogInfo;

@interface MIOCouponViewModel : NSObject
@property NSNumber* couponTotal;
@property NSArray* slices;

- (instancetype)initWithCouponInfo:(MIOCouponInfo*)couponInfo packetLogInfo:(MIOPacketLogInfo*)packetLogInfo;
@end
