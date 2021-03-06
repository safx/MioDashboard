//
//  MIOCouponUsageViewModel.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/31.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOCouponUsageViewModel.h"
#import "MIOResponseModel.h"
#import <iOSPlot/PCLineChartView.h>
#import <Underscore.h>


@implementation MIOCouponUsageViewModel
- (instancetype)initWithCouponHdoInfo:(MIOCouponHdoInfo*)hdoInfo {
    self = [super init];
    if (self) {
        self.packetDate = Underscore.array(hdoInfo.packetLog).map(^id(MIOPacketLog* e) {
            NSString* date = e.date;
            if ([date intValue] % 5 != 1) return @"";
            
            NSString* m = [date substringWithRange:NSMakeRange(4,2)];
            NSString* d = [date substringWithRange:NSMakeRange(6,2)];
            return [NSString stringWithFormat:@"%@/%@", m, d];
        }).unwrap.mutableCopy;
        
        NSMutableArray* components = NSMutableArray.array;
        {
            PCLineChartViewComponent* c = PCLineChartViewComponent.alloc.init;
            c.title = NSLocalizedString(@"Coupon", @"Coupon");
            c.points = Underscore.array(hdoInfo.packetLog).map(^id(MIOPacketLog* e) {
                return @(e.withCoupon);
            }).unwrap;
            c.colour = PCColorRed;
            [components addObject:c];
        }
        {
            PCLineChartViewComponent* c = PCLineChartViewComponent.alloc.init;
            c.title = NSLocalizedString(@"Sum", @"Sum");
            c.points = Underscore.array(hdoInfo.packetLog).map(^id(MIOPacketLog* e) {
                return @(e.withoutCoupon + e.withCoupon);
            }).unwrap;
            c.colour = PCColorBlue;
            [components addObject:c];
        }
        self.packetUsages = components;
    }
    return self;
}
@end
