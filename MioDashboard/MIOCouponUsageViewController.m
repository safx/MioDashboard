//
//  MIODetailViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOResponse.h"
#import "MIOCouponUsageViewController.h"
#import "MIOCouponUsageViewModel.h"
#import <iOSPlot/PCLineChartView.h>

@interface MIOCouponUsageViewController ()
@property PCLineChartView *lineChartView;
@property MIOCouponUsageViewModel* viewModel;
@end

@implementation MIOCouponUsageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.lineChartView = [[PCLineChartView alloc] initWithFrame:CGRectMake(0,0, 900, 250)];
    self.lineChartView.autoscaleYAxis = TRUE;
    
    // TN2154: UIScrollView And Autolayout - Mixed Approach
    //self.scrollView.translatesaAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.lineChartView];
    self.scrollView.contentSize = self.lineChartView.frame.size;    
    
    RAC(self, lineChartView.xLabels) = RACObserve(self, viewModel.packetDate);
    RAC(self, lineChartView.components) = RACObserve(self, viewModel.packetUsages);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModelWithpacketHdoInfo:(MIOPacketHdoInfo*)packetHdoInfo {
    self.title = packetHdoInfo.hdoServiceCode;
    self.viewModel = [[MIOCouponUsageViewModel alloc] initWithPacketHdoInfo:packetHdoInfo];
}

@end
