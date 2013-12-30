//
//  MIOViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <XYPieChart.h>
#import "MIOResponse.h"
#import "MIOCouponViewController.h"
#import "MIOCouponViewModel.h"

@interface MIOCouponViewController () <XYPieChartDataSource, XYPieChartDelegate>
@property MIOCouponViewModel* viewModel;
@end

@implementation MIOCouponViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
    self.pieChartView.delegate = self;
    self.pieChartView.dataSource = self;
    self.pieChartView.showLabel = YES;
    self.pieChartView.showPercentage = NO;
    self.pieChartView.labelRadius = 100;
    self.pieChartView.labelColor = UIColor.blackColor;
    
    self.volumeLabel.layer.cornerRadius = 70;

    @weakify(self);
    [RACObserve(self, viewModel.slices) subscribeNext:^(id x) {
        @strongify(self);
        [self.pieChartView reloadData];
    }];
    [RACObserve(self, viewModel.couponTotal) subscribeNext:^(NSNumber* val) {
        @strongify(self);
        long long vol = [val longLongValue] * 1000 * 1000;
        NSByteCountFormatter* s = [[NSByteCountFormatter alloc] init];
        s.countStyle = NSByteCountFormatterCountStyleDecimal;
        s.includesUnit = NO;
        self.volumeLabel.text = [s stringFromByteCount:vol];
        s.includesCount = NO;
        s.includesUnit = YES;
        self.unitLabel.text = [s stringFromByteCount:vol];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - XYPieChartDataSource

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart {
    return self.viewModel.slices.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index {
    NSDictionary* dic = self.viewModel.slices[index];
    return [dic[@"volume"] floatValue];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index {
    NSDictionary* dic = self.viewModel.slices[index];
    return dic[@"label"];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index {
    NSDictionary* dic = self.viewModel.slices[index];
    return [dic[@"type"] isEqualToString:@"used"]? UIColor.redColor : nil;
}

#pragma mark - XYPieChartDelegate

- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index {
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index {
    NSDictionary* dic = self.viewModel.slices[index];
    self.detailLabel.text = [NSString stringWithFormat:@"%@  %d MB  (%@)", dic[@"type"], [dic[@"volume"] intValue], dic[@"label"]];
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index {
}
- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index {
    self.detailLabel.text = @"";
}

#pragma mark -

- (void)setModelWithCouponInfo:(MIOCouponInfo*)couponInfo packetLogInfo:(MIOPacketLogInfo*)packetLogInfo {
    self.title = couponInfo.hddServiceCode;
    self.viewModel = [[MIOCouponViewModel alloc] initWithCouponInfo:couponInfo packetLogInfo:packetLogInfo];
}

@end
