//
//  MIOInformation.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOResponseModel.h"

@implementation MIOCouponResponse
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
+ (NSValueTransformer *)couponInfoJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOCouponInfo.class]; }
@end



@implementation MIOPacketResponse
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
+ (NSValueTransformer *)packetLogInfoJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOPacketLogInfo.class]; }
@end



@implementation MIOCouponInfo
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
+ (NSValueTransformer *)hdoInfoJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOCouponHdoInfo.class]; }
+ (NSValueTransformer *)couponJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOCoupon.class]; }
@end


@implementation MIOCouponHdoInfo
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
//+ (NSValueTransformer *)couponJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOCoupon.class]; }
@end


@implementation MIOCoupon
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
@end


@implementation MIOPacketLogInfo
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
+ (NSValueTransformer *)hdoInfoJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOPacketHdoInfo.class]; }
@end


@implementation MIOPacketHdoInfo
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
+ (NSValueTransformer *)packetLogJSONTransformer { return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:MIOPacketLog.class]; }
@end


@implementation MIOPacketLog
+ (NSDictionary *)JSONKeyPathsByPropertyKey { return @{}; }
@end
