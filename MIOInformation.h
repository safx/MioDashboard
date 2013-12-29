//
//  MIOInformation.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MIOInformation : NSObject
@property NSDictionary* couponInfo;
@property NSDictionary* packetInfo;
+ (MIOInformation*)sharedInstance;
@end
