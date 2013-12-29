//
//  MIODetailViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIODetailViewController.h"
#import "MIOViewModel.h"
#import <iOSPlot/PCLineChartView.h>

@interface MIODetailViewController ()
@property PCLineChartView *lineChartView;
@property MIOViewModel* viewModel;
@end

@implementation MIODetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.viewModel = MIOViewModel.alloc.init;
    
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

@end
