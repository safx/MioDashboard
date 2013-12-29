//
//  MIOOAuthModel.h
//  MioGraph
//
//  Created by Safx Developer on 2013/12/27.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@class MIOInformation;

@interface MIORestHelper : MTLModel<MTLJSONSerializing>
@property NSString* accessToken;
@property NSString* clientID;
@property NSString* redirectURI;
@property NSString* state;

- (RACSignal*)authorize;
- (RACSignal*)authorizeInView:(UIView*)view;

- (RACSignal*)getCoupon;
- (RACSignal*)getPacket;
- (RACSignal*)putCoupon:(BOOL)useCoupon forHdoServiceCode:(NSString*)hdoServiceCode;
@end
