//
//  MIOViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <XYPieChart.h>
#import "MIOSummaryViewController.h"
#import "MIOViewModel.h"

@interface MIOSummaryViewController () <XYPieChartDataSource, XYPieChartDelegate>
@property MIOViewModel* viewModel;
@end

@implementation MIOSummaryViewController

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

    self.viewModel = MIOViewModel.alloc.init;
    
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
    return index == 0? UIColor.redColor : nil;
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

@end
