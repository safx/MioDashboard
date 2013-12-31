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
                        return [[self loadInformation] catch:^RACSignal *(NSError *error) {
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
        
        [[[self loadInformation] catch:errorBlock] subscribeNext:^(NSArray* array) {
            @strongify(self);
            self.couponResponse = createObject(MIOCouponResponse.class, [array[0] first]);
            self.packetResponse = createObject(MIOPacketResponse.class, [array[1] first]);
        }];
    }
    return self;
}

- (void)loadInformation_forText {
    NSDictionary* cr =
    @{
      @"returnCode": @"OK",
      @"couponInfo": @[
        @{
            @"hddServiceCode": @"hddXXXXXXXX",
            @"hdoInfo"       : @[
                    @{
                                     @"hdoServiceCode": @"hdoXXXXXXXX",
                                     @"number"        : @"080XXXXXXXX",
                                     @"iccid"         : @"DN00XXXXXXXXXX",
                                     @"regulation"    : @true,
                                     @"sms"           : @false,
                                     @"couponUse"     : @true,
                                     @"coupon"        : @[@{ @"volume": @0, @"expire":NSNull.null, @"type": @"sim" }]
                    },
                    @{
                        @"hdoServiceCode": @"hdoYYYYYYYY",
                        @"number"        : @"080YYYYYYYY",
                        @"iccid"         : @"DN00YYYYYYYYYYY",
                        @"regulation"    : @true,
                        @"sms"           : @false,
                        @"couponUse"     : @true,
                        @"coupon"        : @[@{ @"volume": @0, @"expire":NSNull.null, @"type": @"sim" }]
                        }
                    ],
            @"coupon"       : @[
                    @{@"volume":@100, @"expire":@"201312", @"type":@"bundle"},
                    @{@"volume":@200, @"expire":@"201401", @"type":@"bundle"},
                    @{@"volume":@0,   @"expire":@"201312", @"type":@"topup"},
                    @{@"volume":@400, @"expire":@"201401", @"type":@"topup"},
                    @{@"volume":@0,   @"expire":@"201402", @"type":@"topup"},
                    @{@"volume":@400, @"expire":@"201403", @"type":@"topup"}]
        }]
    };



    NSDictionary* pr =
    @{
      @"returnCode": @"OK",
      @"packetLogInfo": @[
          @{
              @"hddServiceCode": @"hddXXXXXXXX",
              @"hdoInfo"       : @[
                      @{
                          @"hdoServiceCode": @"hdoXXXXXXXX",
                          @"packetLog"     : @[
                                  @{ @"date": @"20131101", @"withCoupon": @50, @"withoutCoupon": @19 },
                                  @{ @"date": @"20131102", @"withCoupon": @25, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131103", @"withCoupon": @12, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131104", @"withCoupon": @0, @"withoutCoupon": @8 },
                                  @{ @"date": @"20131105", @"withCoupon": @50, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131106", @"withCoupon": @25, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131107", @"withCoupon": @12, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131108", @"withCoupon": @50, @"withoutCoupon": @20 },
                                  @{ @"date": @"20131109", @"withCoupon": @25, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131110", @"withCoupon": @12, @"withoutCoupon": @10 },
                                  @{ @"date": @"20131111", @"withCoupon": @0, @"withoutCoupon": @8 },
                                  @{ @"date": @"20131112", @"withCoupon": @50, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131113", @"withCoupon": @25, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131114", @"withCoupon": @72, @"withoutCoupon": @1 },
                                  @{ @"date": @"20131115", @"withCoupon": @50, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131116", @"withCoupon": @25, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131117", @"withCoupon": @12, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131118", @"withCoupon": @0, @"withoutCoupon": @8 },
                                  @{ @"date": @"20131119", @"withCoupon": @50, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131120", @"withCoupon": @25, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131121", @"withCoupon": @12, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131122", @"withCoupon": @0, @"withoutCoupon": @59 }
                                  ]
                          },
                      @{
                          @"hdoServiceCode": @"hdoYYYYYYYY",
                          @"packetLog"     : @[
                                  @{ @"date": @"20131101", @"withCoupon": @0, @"withoutCoupon": @9 },
                                  @{ @"date": @"20131102", @"withCoupon": @5, @"withoutCoupon": @8 },
                                  @{ @"date": @"20131103", @"withCoupon": @32, @"withoutCoupon": @9 },
                                  @{ @"date": @"20131104", @"withCoupon": @4, @"withoutCoupon": @8 },
                                  @{ @"date": @"20131105", @"withCoupon": @0, @"withoutCoupon": @5 },
                                  @{ @"date": @"20131106", @"withCoupon": @15, @"withoutCoupon": @3 },
                                  @{ @"date": @"20131107", @"withCoupon": @21, @"withoutCoupon": @1 },
                                  @{ @"date": @"20131108", @"withCoupon": @5, @"withoutCoupon": @20 },
                                  @{ @"date": @"20131109", @"withCoupon": @5, @"withoutCoupon": @40 },
                                  @{ @"date": @"20131110", @"withCoupon": @2, @"withoutCoupon": @0 },
                                  @{ @"date": @"20131111", @"withCoupon": @0, @"withoutCoupon": @1 },
                                  @{ @"date": @"20131112", @"withCoupon": @0, @"withoutCoupon": @0 },
                                  @{ @"date": @"20131113", @"withCoupon": @5, @"withoutCoupon": @0 },
                                  @{ @"date": @"20131114", @"withCoupon": @7, @"withoutCoupon": @8 },
                                  @{ @"date": @"20131115", @"withCoupon": @0, @"withoutCoupon": @50 },
                                  @{ @"date": @"20131116", @"withCoupon": @2, @"withoutCoupon": @20 },
                                  @{ @"date": @"20131117", @"withCoupon": @2, @"withoutCoupon": @10 },
                                  @{ @"date": @"20131118", @"withCoupon": @0, @"withoutCoupon": @3 },
                                  @{ @"date": @"20131119", @"withCoupon": @0, @"withoutCoupon": @30 },
                                  @{ @"date": @"20131120", @"withCoupon": @3, @"withoutCoupon": @60 },
                                  @{ @"date": @"20131121", @"withCoupon": @62, @"withoutCoupon": @0 },
                                  @{ @"date": @"20131122", @"withCoupon": @52, @"withoutCoupon": @9 }
                                  ]
                          }
                      ]
              }]};
    
    NSError* error = nil;
    self.couponResponse = [MTLJSONAdapter modelOfClass:MIOCouponResponse.class fromJSONDictionary:cr error:&error];
    self.packetResponse = [MTLJSONAdapter modelOfClass:MIOPacketResponse.class fromJSONDictionary:pr error:&error];
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

- (RACSignal*)loadInformation {
    RACSignal* coupon = [RACSignal defer:^RACSignal* { return [self.restHelper getCoupon]; }];
    RACSignal* packet = [RACSignal defer:^RACSignal* { return [self.restHelper getPacket]; }];
    
    RACSignal* sig = [[coupon concat:packet] collect];
    return self.restHelper.accessToken? sig : [[[self.restHelper authorize] catch:self.errorBlock] concat:sig];
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
