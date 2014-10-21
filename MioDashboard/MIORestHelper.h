//
//  MIOOAuthModel.h
//  MioGraph
//
//  Created by Safx Developer on 2013/12/27.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle.h>

@class MIOResponseCache;
@class RACSignal;
@class RACSubject;

@interface MIORestHelper : MTLModel<MTLJSONSerializing>
@property NSString* accessToken;
@property NSString* clientID;
@property NSString* redirectURI;
@property NSString* state;
@property RACSubject* authSignal;

+ (MIORestHelper*)sharedInstance;

+ (void)saveAccessToken:(MIORestHelper*)instance;
+ (MIORestHelper*)loadAccessToken;

- (RACSignal*)loadInformationSignal; // send information array of coupon and packet.
- (RACSignal*)mergeInformationSignal:(RACSignal*)signal;

- (RACSignal*)getCoupon;
- (RACSignal*)getPacket;
- (RACSignal*)putCoupon:(BOOL)useCoupon forHdoServiceCode:(NSString*)hdoServiceCode;

@end


@interface MIORestHelper (Authorize)
- (RACSignal*)refreshToken;
- (BOOL)checkAccessToken:(NSURL*)url;
- (NSURLRequest*)authorizeRequest;
@end
