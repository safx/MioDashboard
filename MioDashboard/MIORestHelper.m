//
//  MIOOAuthModel.m
//  MioGraph
//
//  Created by Safx Developer on 2013/12/27.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIORestHelper.h"
#import "MIOResponseModel.h"
#import <AFNetworking.h>
#import <AFNetworking-RACExtensions/RACAFNetworking.h>
#import <Underscore.h>


@implementation MIORestHelper

+ (NSDictionary*)JSONKeyPathsByPropertyKey {
    return @{
             @"couponInfo":NSNull.null,
             @"packetInfo":NSNull.null,
             @"state":NSNull.null,
             @"authSignal":NSNull.null
    };
}

+ (MIORestHelper*)sharedInstance {
    __block MIORestHelper* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self loadAccessToken];
        if (!instance) {
            instance = MIORestHelper.alloc.init;
            instance.clientID = @"Your_CliendID";
            instance.redirectURI = @"Your_Redirect_URI";
        }
    });
    return instance;
}

#pragma mark - serialization

+ (void)saveAccessToken:(MIORestHelper*)instance {
    NSUserDefaults* sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.blogspot.safxdev.miodashboard"];
    [sharedDefaults setObject:instance.clientID    forKey:@"clientID"];
    [sharedDefaults setObject:instance.accessToken forKey:@"accessToken"];
    [sharedDefaults setObject:instance.redirectURI forKey:@"redirectURI"];
    [sharedDefaults synchronize];
}

+ (MIORestHelper*)loadAccessToken {
    NSUserDefaults* sharedDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.blogspot.safxdev.miodashboard"];
    NSString* clientID    = [sharedDefaults objectForKey:@"clientID"];
    NSString* accessToken = [sharedDefaults objectForKey:@"accessToken"];
    NSString* redirectURI = [sharedDefaults objectForKey:@"redirectURI"];

    if (clientID && accessToken && redirectURI) {
        MIORestHelper* instance = MIORestHelper.alloc.init;
        instance.clientID    = clientID;
        instance.accessToken = accessToken;
        instance.redirectURI = redirectURI;
        return instance;
    }
    return nil;
}

#pragma mark - REST API helper

- (RACSignal*)loadInformationSignal {
    RACSignal* coupon = [RACSignal defer:^RACSignal* { return [self getCoupon]; }];
    RACSignal* packet = [RACSignal defer:^RACSignal* { return [self getPacket]; }];
    return [[coupon concat:packet] collect];
}

- (RACSignal*)mergeInformationSignal:(RACSignal*)signal {
    id(^createObject)(Class,NSDictionary*) = ^id(Class clazz, NSDictionary* dic) {
        NSError* error = nil;
        id obj = [MTLJSONAdapter modelOfClass:clazz fromJSONDictionary:dic error:&error];
        if (error) {
            return nil;
        } else {
            return obj;
        }
    };

    return [signal map:^(NSArray* array) {
        MIOCouponResponse* couponResponse = createObject(MIOCouponResponse.class, [array[0] first]);
        MIOPacketResponse* packetResponse = createObject(MIOPacketResponse.class, [array[1] first]);
        
        for (MIOCouponInfo* couponInfo in couponResponse.couponInfo) {
            NSString* hdd = couponInfo.hddServiceCode;
            MIOPacketLogInfo* packetLogInfo = Underscore.find(packetResponse.packetLogInfo, ^BOOL(MIOPacketLogInfo* e) {
                return [e.hddServiceCode isEqualToString:hdd];
            });
            for (MIOCouponHdoInfo* couponHdoInfo in couponInfo.hdoInfo) {
                NSString* hdo = couponHdoInfo.hdoServiceCode;
                MIOPacketHdoInfo* packetHdoInfo = Underscore.find(packetLogInfo.hdoInfo, ^BOOL(MIOPacketHdoInfo* e) {
                    return [e.hdoServiceCode isEqualToString:hdo];
                });
                couponHdoInfo.packetLog = packetHdoInfo.packetLog;
            }
        }
        
        return couponResponse.couponInfo;
    }];
}

#pragma mark - IIJmio REST API

- (NSMutableURLRequest*)apiRequestWithURLString:(NSString*)urlString {
    NSAssert(_clientID && _accessToken, @"should be non-nil");
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];

    [request setValue:self.clientID forHTTPHeaderField:@"X-IIJmio-Developer"];
    [request setValue:self.accessToken forHTTPHeaderField:@"X-IIJmio-Authorization"];
    return request;
}

- (RACSignal*)getCoupon {
    NSMutableURLRequest* request = [self apiRequestWithURLString:@"https://api.iijmio.jp/mobile/d/v1/coupon/"];
    return [AFJSONRequestOperation rac_startJSONRequestOperationWithRequest:request];
}

- (RACSignal*)getPacket {
    NSMutableURLRequest* request = [self apiRequestWithURLString:@"https://api.iijmio.jp/mobile/d/v1/log/packet/"];
    return [AFJSONRequestOperation rac_startJSONRequestOperationWithRequest:request];
}

- (RACSignal*)putCoupon:(BOOL)useCoupon forHdoServiceCode:(NSString*)hdoServiceCode {
    NSMutableURLRequest* request = [self apiRequestWithURLString:@"https://api.iijmio.jp/mobile/d/v1/coupon/"];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString* jsonstr = [NSString stringWithFormat:@"{\"couponInfo\":[{\"hdoInfo\":[{\"hdoServiceCode\":\"%@\",\"couponUse\":%@}]}]}", hdoServiceCode, useCoupon? @"true":@"false"];
    request.HTTPBody = [jsonstr dataUsingEncoding:NSUTF8StringEncoding];
    return [AFJSONRequestOperation rac_startJSONRequestOperationWithRequest:request];
}

@end
