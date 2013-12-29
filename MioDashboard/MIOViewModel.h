//
//  MIOViewModel.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIOViewModel : NSObject
// for Home view
@property NSString* hdoServiceCode;
@property NSString* number;
@property BOOL couponUse;
@property BOOL regulation;
@property BOOL sms;
- (void)changeCouponUse:(BOOL)couponUse;

// for Summary view
@property NSNumber* couponTotal;
@property NSArray* slices;

// for Detail view
@property NSArray* packetDate;
@property NSArray* packetUsages;
@end
