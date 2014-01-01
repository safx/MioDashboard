//
//  MIOCouponUsageViewModel.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/31.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MIOCouponHdoInfo;

@interface MIOCouponUsageViewModel : NSObject
@property NSArray* packetDate;
@property NSArray* packetUsages;
- (instancetype)initWithCouponHdoInfo:(MIOCouponHdoInfo*)hdoInfo;
@end
