//
//  MIOViewController.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/28.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYPieChart;

@interface MIOSummaryViewController : UIViewController
@property (weak, nonatomic) IBOutlet XYPieChart *pieChartView;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end
