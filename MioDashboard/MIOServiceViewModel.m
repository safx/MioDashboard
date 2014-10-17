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
#import "MIORestHelper+Authorize.h"
#import <TWMessageBarManager.h>
#import <ReactiveCocoa.h>
#import <Underscore.h>
#import <EXTScope.h>


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
    RACSignal* sig = [self.restHelper loadInformationSignal];
    return self.restHelper.accessToken? sig : [[[self.restHelper authorize] catch:self.errorBlock] concat:sig];
}

- (RACSignal*)loadInformation {
    @weakify(self);
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

    RACSignal* sig = [[self loadInformationSignal] catch:errorBlock];
    return [[self.restHelper mergeInformationSignal:sig] map:^(NSArray* array) {
        @strongify(self);
        self.couponInfoArray = array;
        return array;
    }];
}

- (void)changeCouponUse:(BOOL)couponUse forHdoInfo:(MIOCouponHdoInfo*)hdoInfo {
    if (hdoInfo.couponUse == couponUse) return;
    
    hdoInfo.couponUse = couponUse;
    @weakify(self);
    [[[self.restHelper putCoupon:couponUse forHdoServiceCode:hdoInfo.hdoServiceCode] catch:^RACSignal *(NSError *error) {
        @strongify(self);
        hdoInfo.couponUse = !couponUse;
        [self showErrorMessageForRestAPI:error];
        return [RACSignal empty];
    }] subscribeNext:^(RACTuple* tuple) {
        NSDictionary* dic = tuple.first;
        NSAssert([dic[@"returnCode"] isEqualToString:@"OK"], @"returnCode should be OK");
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:NSLocalizedString(@"Updated", @"Updated")
                                                       description:NSLocalizedString(@"Coupon switch was changed successfully", @"Coupon switch was changed successfully")
                                                              type:TWMessageBarMessageTypeSuccess];
    }];
}

@end
