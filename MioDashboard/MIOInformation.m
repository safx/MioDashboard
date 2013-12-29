//
//  MIOInformation.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOInformation.h"

@implementation MIOInformation

+ (MIOInformation*)sharedInstance {
    static MIOInformation* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = MIOInformation.alloc.init;
    });
    return instance;
}

@end
