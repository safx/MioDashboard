//
//  MIORestHelper+Authorize.h
//  MioDashboard
//
//  Created by Safx Developer on 2014/10/16.
//  Copyright (c) 2014年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MIORestHelper.h"

@interface MIORestHelper (Authorize)

- (RACSignal*)authorize;
- (RACSignal*)authorizeInView:(UIView*)view;

@end
