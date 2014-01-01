//
//  MIOServicewViewModel.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOResponseModel.h"
#import "MIOServiceViewModel.h"
#import "MIORestHelper.h"
#import <TWMessageBarManager.h>

@interface MIOServiceViewModel ()
@property MIORestHelper* restHelper;
@property MIOResponseCache* info;
@end

typedef id(^RACSignalErrorBlock)(NSError*);

@implementation MIOServiceViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        // init properties
        self.restHelper = MIORestHelper.sharedInstance;
        self.restHelper.state = NSDate.date.description;

        [[self loadInformation] subscribeCompleted:^{

        }];
    }
    return self;
}

- (RACSignalErrorBlock)errorBlock {
    @weakify(self);
    return ^(NSError* error) {
        @strongify(self);
        [self showErrorMessageForRestAPI:error];
        return [RACSignal empty];
    };
}

- (void)showErrorMessageForRestAPI:(NSError*)error {
    NSLog(@"%@", error);
    NSString* t = error.localizedRecoverySuggestion;
    NSError* err = nil;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[t dataUsingEncoding:NSASCIIStringEncoding]  options:0 error:&err];
    if (!err && dic[@"returnCode"]) t = dic[@"returnCode"];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:t
                                                   description:error.localizedDescription
                                                          type:TWMessageBarMessageTypeError];
}

- (RACSignal*)loadInformationSignal {
    RACSignal* coupon = [RACSignal defer:^RACSignal* { return [self.restHelper getCoupon]; }];
    RACSignal* packet = [RACSignal defer:^RACSignal* { return [self.restHelper getPacket]; }];
    
    RACSignal* sig = [[coupon concat:packet] collect];
    return self.restHelper.accessToken? sig : [[[self.restHelper authorize] catch:self.errorBlock] concat:sig];
}

- (RACSignal*)loadInformation {
    @weakify(self);
    id(^createObject)(Class,NSDictionary*) = ^id(Class clazz, NSDictionary* dic) {
        @strongify(self);
        NSError* error = nil;
        id obj = [MTLJSONAdapter modelOfClass:clazz fromJSONDictionary:dic error:&error];
        if (error) {
            [self showErrorMessageForRestAPI:error];
            return nil;
        } else {
            return obj;
        }
    };
    
    id(^errorBlock)(NSError*) = ^(NSError* error) {
        @strongify(self);
        
        NSString* t = error.localizedRecoverySuggestion;
        NSError* err = nil;
        NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:[t dataUsingEncoding:NSASCIIStringEncoding] options:0 error:&err];
        if (!err && dic[@"returnCode"]) {
            if ([dic[@"returnCode"] isEqualToString:@"User Authorization Failure"]) {
                // Access toekn maybe expired, so we retry...
                if (self.restHelper.accessToken) {
                    self.restHelper.accessToken = nil;
                    return [[self loadInformationSignal] catch:^RACSignal *(NSError *error) {
                        [self showErrorMessageForRestAPI:error];
                        return [RACSignal empty];
                    }];
                }
            }
        } else {
            [self showErrorMessageForRestAPI:error];
        }
        return [RACSignal empty];
    };
    
    return [[[self loadInformationSignal] catch:errorBlock] map:^(NSArray* array) {
        @strongify(self);
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
        
        self.couponInfoArray = couponResponse.couponInfo;
        
        return array;
    }];
}

- (void)changeCouponUse:(BOOL)couponUse forHdoInfo:(MIOCouponHdoInfo*)hdoInfo {
    if (hdoInfo.couponUse == couponUse) return;
    
    [[[self.restHelper putCoupon:couponUse forHdoServiceCode:hdoInfo.hdoServiceCode] catch:self.errorBlock] subscribeNext:^(RACTuple* tuple) {
        NSDictionary* dic = tuple.first;
        NSAssert([dic[@"returnCode"] isEqualToString:@"OK"], @"returnCode should be OK");
        hdoInfo.couponUse = couponUse;
    }];
}

@end
