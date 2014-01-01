//
//  MIOInformation.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@class MIOCouponResponse;
@class MIOPacketResponse;



@interface MIOCouponResponse : MTLModel<MTLJSONSerializing>
@property NSString* returnCode;
@property NSArray* couponInfo;
@end



@interface MIOPacketResponse : MTLModel<MTLJSONSerializing>
@property NSString* returnCode;
@property NSArray* packetLogInfo;
@end



@interface MIOCouponInfo : MTLModel<MTLJSONSerializing>
@property NSString* hddServiceCode;
@property NSArray* hdoInfo;
@property NSArray* coupon;
@end


@interface MIOCouponHdoInfo : MTLModel<MTLJSONSerializing>
@property NSString* hdoServiceCode;
@property NSString* number;
@property NSString* iccid;
@property BOOL regulation;
@property BOOL sms;
@property BOOL couponUse;
//@property NSArray* coupon;
@property NSArray* packetLog; // assgin from MIOPacketResponse
@end


@interface MIOCoupon : MTLModel<MTLJSONSerializing>
@property NSUInteger volume;
@property NSString* expire;
@property NSString* type;
@end


@interface MIOPacketLogInfo : MTLModel<MTLJSONSerializing>
@property NSString* hddServiceCode;
@property NSArray* hdoInfo;
@end


@interface MIOPacketHdoInfo : MTLModel<MTLJSONSerializing>
@property NSString* hdoServiceCode;
@property NSArray* packetLog;
@end


@interface MIOPacketLog : MTLModel<MTLJSONSerializing>
@property NSString* date;
@property NSUInteger withCoupon;
@property NSUInteger withoutCoupon;
@end
