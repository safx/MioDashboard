//
//  MIOViewModel.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOInformation.h"
#import "MIOViewModel.h"
#import "MIORestHelper.h"
#import <iOSPlot/PCLineChartView.h>

@interface MIOViewModel ()
@property MIORestHelper* restHelper;
@property MIOInformation* info;
@end


@implementation MIOViewModel

- (id)init
{
    self = [super init];
    if (self) {
        // init properties
        self.restHelper = MIORestHelper.sharedInstance;
        self.restHelper.state = NSDate.date.description;
        
        self.info = MIOInformation.sharedInstance;
        
        // RAC: home view
        typedef NSString*(^GetValue)(NSDictionary*);
        GetValue(^getValue)(NSString*) = ^(NSString* kp) {
            return ^id(NSDictionary* couponInfo){ return [[self.info.couponInfo valueForKeyPath:kp] objectAtIndex:0]; };
        };
        
        typedef NSNumber*(^GetBoolValue)(NSDictionary*);
        GetBoolValue(^getBoolValue)(NSString*) = ^(NSString* kp) {
            return ^id(NSDictionary* couponInfo){ return @([[[self.info.couponInfo valueForKeyPath:kp] objectAtIndex:0] boolValue]); };
        };
        
        RAC(self, couponUse)  = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo)] reduce:getBoolValue(@"hdoInfo.couponUse")];
        RAC(self, regulation) = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo)] reduce:getBoolValue(@"hdoInfo.regulation")];
        RAC(self, sms)        = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo)] reduce:getBoolValue(@"hdoInfo.sms")];
        
        RAC(self, number)         = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo)] reduce:getValue(@"hdoInfo.number")];
        RAC(self, hdoServiceCode) = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo)] reduce:getValue(@"hdoInfo.hdoServiceCode")];

        // RAC: summary view
        NSArray*(^getPacketLog)(NSDictionary*) = ^NSArray*(NSDictionary* packetInfo) {
            return [[self.info.packetInfo valueForKeyPath:@"hdoInfo.packetLog"] objectAtIndex:0];
        };

        RAC(self, slices) = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo), RACObserve(self, info.packetInfo)] reduce:^id(NSDictionary* couponInfo, NSDictionary* packetInfo){
            NSUInteger totalCouponUsed = [[getPacketLog(couponInfo) valueForKeyPath:@"@sum.withCoupon"] intValue];
            
            NSArray* coupons = couponInfo[@"coupon"];
            NSArray* couponsSlices = Underscore.array(coupons).filter(^BOOL(NSDictionary* e) {
                return [e[@"volume"] intValue] > 0;
            }).map(^id(NSDictionary* e) {
                //return @{@"label":e[@"expire"], @"value":@([e[@"volume"] intValue])};
                NSString* expire = e[@"expire"];
                NSString* y = [expire substringWithRange:NSMakeRange(0, 4)];
                NSString* m = [expire substringWithRange:NSMakeRange(4, 2)];
                NSString* date = [NSString stringWithFormat:NSLocalizedString(@"〜%@.%@", @"〜%@.%@"), y, m];
                return @{@"label":date, @"type":e[@"type"], @"volume":e[@"volume"]};
            }).unwrap;
            
            return Underscore.array(@[@{@"type":@"", @"label":NSLocalizedString(@"Used", @"Used"), @"volume":@(totalCouponUsed)}, couponsSlices]).flatten.unwrap;
        }];

        RAC(self, couponTotal) = [RACSignal combineLatest:@[RACObserve(self, info.couponInfo)] reduce:^id(NSDictionary* couponInfo){
            return [self.info.couponInfo valueForKeyPath:@"coupon.@sum.volume"];
        }];
        
        // RAC: detail view
        RAC(self, packetDate) = [RACSignal combineLatest:@[RACObserve(self, info.packetInfo)] reduce:^id(NSDictionary* packetInfo){
            return Underscore.array(getPacketLog(packetInfo)).map(^id(NSDictionary* e) {
                NSString* date = e[@"date"];
                if ([date intValue] % 5 != 1) return @"";
                
                NSString* m = [date substringWithRange:NSMakeRange(4,2)];
                NSString* d = [date substringWithRange:NSMakeRange(6,2)];
                return [NSString stringWithFormat:@"%@/%@", m, d];
            }).unwrap.mutableCopy;
        }];

        RAC(self, packetUsages) = [RACSignal combineLatest:@[RACObserve(self, info.packetInfo)] reduce:^id(NSDictionary* packetInfo){
            NSArray* packetLog = getPacketLog(packetInfo);
            NSMutableArray* components = NSMutableArray.array;
            {
                PCLineChartViewComponent* c = PCLineChartViewComponent.alloc.init;
                c.title = NSLocalizedString(@"Coupon", @"Coupon");
                c.points = [packetLog valueForKeyPath:@"withCoupon"];
                c.colour = PCColorRed;
                [components addObject:c];
            }
            {
                PCLineChartViewComponent* c = PCLineChartViewComponent.alloc.init;
                c.title = NSLocalizedString(@"Sum", @"Sum");
                c.points = Underscore.array(packetLog).map(^id(NSDictionary* e) {
                    return @([e[@"withoutCoupon"] intValue] + [e[@"withCoupon"] intValue]);
                }).unwrap;
                c.colour = PCColorBlue;
                [components addObject:c];
            }
            return components;
        }];
        
        // other operations
        [self loadInformation];
    }
    return self;
}

#pragma mark -

- (void)loadInformation_impl {
#if 1
    if (self.info.couponInfo && self.info.packetInfo) return;
    
    @weakify(self);
    id(^errorBlock)(NSError*) = ^(NSError* error) {
        @strongify(self);
        [self showErrorMessageForRestAPI:error];
        return [RACSignal empty];
    };
    
    typedef id (^MapReturnBlock)(id value);
    MapReturnBlock(^getObjectFromKey)(NSString*) = ^(NSString* key) {
        return ^id(RACTuple* tuple) {
            NSDictionary* dic = tuple.first;
            NSAssert([dic[@"returnCode"] isEqualToString:@"OK"], @"returnCode should be OK");
            NSArray* arr = dic[key];
            NSLog(@"%@", arr);
            return arr[0];
        };
    };
    
    RAC(self, info.couponInfo) = [[[self.restHelper getCoupon] catch:errorBlock] map:getObjectFromKey(@"couponInfo")];
    RAC(self, info.packetInfo) = [[[self.restHelper getPacket] catch:errorBlock] map:getObjectFromKey(@"packetLogInfo")];
#else
    self.info.packetInfo = @{
        @"hddServiceCode": @"hddXXXXXXXX",
        @"hdoInfo"       : @[@{
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
            }
    ]};

    self.info.couponInfo = @{
        @"hddServiceCode": @"hddXXXXXXXX",
        @"hdoInfo"       : @[@{
                               @"hdoServiceCode": @"hdoXXXXXXXX",
                               @"number"        : @"080XXXXXXXX",
                               @"iccid"         : @"DN00XXXXXXXXXX",
                               @"regulation"    : @true,
                               @"sms"           : @false,
                               @"couponUse"     : @true,
                               @"coupon"        : @[@{ @"volume": @100, @"expire":NSNull.null, @"type": @"sim" }]
                           }],
        @"coupon"       : @[
                             @{@"volume":@100, @"expire":@"201312", @"type":@"bundle"},
                             @{@"volume":@200, @"expire":@"201401", @"type":@"bundle"},
                             @{@"volume":@0,   @"expire":@"201312", @"type":@"topup"},
                             @{@"volume":@400, @"expire":@"201401", @"type":@"topup"},
                             @{@"volume":@0,   @"expire":@"201402", @"type":@"topup"},
                             @{@"volume":@400, @"expire":@"201403", @"type":@"topup"}]
    };
#endif
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

- (void)loadInformation {
    if (self.restHelper.accessToken) {
        [self loadInformation_impl];
    } else {
        @weakify(self);
        [[[self.restHelper authorize] catch:^RACSignal *(NSError *error) {
            @strongify(self);
            [self showErrorMessageForRestAPI:error];
        }] subscribeCompleted:^{
            @strongify(self);
            [self loadInformation_impl];
        }];
    }
}

- (void)changeCouponUse:(BOOL)couponUse {
    NSAssert(self.hdoServiceCode, @"should be non-null");

    if (self.couponUse == couponUse) return;
    
    @weakify(self);
    id(^errorBlock)(NSError*) = ^(NSError* error) {
        @strongify(self);
        self.couponUse = !couponUse;
        [self showErrorMessageForRestAPI:error];
        return [RACSignal empty];
    };

    [[[self.restHelper putCoupon:couponUse forHdoServiceCode:self.hdoServiceCode] catch:errorBlock] subscribeNext:^(RACTuple* tuple) {
        @strongify(self);
        NSDictionary* dic = tuple.first;
        NSAssert([dic[@"returnCode"] isEqualToString:@"OK"], @"returnCode should be OK");
        self.couponUse = couponUse;
    }];
}

@end
