//
//  MIOSettingsViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/29.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOHomeViewController.h"
#import "MIOViewModel.h"

@interface MIOHomeViewController ()
@property MIOViewModel* viewModel;
@end

@implementation MIOHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
    self.viewModel = MIOViewModel.alloc.init;
    
    id(^boolToString)(NSNumber*) = ^id(NSNumber* value) {
        return [value boolValue]? NSLocalizedString(@"Yes", @"Yes") : NSLocalizedString(@"No", @"No");
    };
    RAC(self, smsLabel.text) = [RACObserve(self, viewModel.sms) map:boolToString];
    RAC(self, regulationLabel.text) = [RACObserve(self, viewModel.regulation) map:boolToString];
    RAC(self, numberLabel.text) = RACObserve(self, viewModel.number);

    RAC(self, couponSwitch.on) = RACObserve(self, viewModel.couponUse);

    @weakify(self);
    [[self.couponSwitch rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(UISwitch* x) {
        @strongify(self);
        [self.viewModel changeCouponUse:x.on];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
