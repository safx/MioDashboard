//
//  MIOResponseModel+Util.h
//  MioDashboard
//
//  Created by Safx Developer on 2014/10/17.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MIOCouponInfo (Util)
- (int)totalVolume;
@end


@interface MIOCouponHdoInfo (Util)
- (int)totalPacketUsedWithCoupon;
@end
