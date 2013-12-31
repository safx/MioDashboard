//
//  MIOServicewViewModel.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MIOCouponResponse;
@class MIOPacketResponse;

@interface MIOServiceViewModel : NSObject
@property MIOCouponResponse* couponResponse;
@property MIOPacketResponse* packetResponse;
- (RACSignal*)loadInformation;
- (void)changeCouponUse:(BOOL)couponUse forHdoInfo:(MIOCouponHdoInfo*)hdoInfo;
@end
