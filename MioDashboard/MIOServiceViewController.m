//
//  MIOServiceViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOResponseModel.h"
#import "MIOServiceViewController.h"
#import "MIOServiceViewModel.h"
#import "MIOTableViewCell.h"
#import "MIOCouponViewController.h"
#import "MIOCouponUsageViewController.h"
#import "VTAcknowledgementsViewController.h"


@interface MIOServiceViewController ()
@property MIOServiceViewModel* viewModel;
@end

@implementation MIOServiceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.viewModel = MIOServiceViewModel.alloc.init;

    @weakify(self);
    [RACObserve(self.viewModel, couponInfoArray) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [[self.infoRefreshControl rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        [[[self.viewModel loadInformation] finally:^{
            [self.infoRefreshControl endRefreshing];
        }] subscribeCompleted:^{
            
        }];
    }];
    
    self.aboutButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        UIViewController *viewController = [VTAcknowledgementsViewController acknowledgementsViewController];
        [self.navigationController pushViewController:viewController animated:YES];
        return [RACSignal empty];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.viewModel.couponInfoArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MIOCouponInfo* info = self.viewModel.couponInfoArray[section];
    return [NSString stringWithFormat:@"%@ (%@)", info.hddServiceCode, info.plan];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MIOCouponInfo* info = self.viewModel.couponInfoArray[section];
    return 1 + info.hdoInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < 1? 44: 105;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < 1? indexPath : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = nil;
    switch (indexPath.row) {
        case 0:  cellIdentifier = @"Coupon"; break;
        default: cellIdentifier = @"hdoServiceCode"; break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    MIOCouponInfo* couponInfo = self.viewModel.couponInfoArray[indexPath.section];
    
    long index = indexPath.row - 1;
    switch (indexPath.row) {
        case 0:  [(MIOCouponCell*)cell setModelWithCouponInfo:couponInfo]; break;
        default: {
            MIOCouponHdoInfo* couponHdoInfo = couponInfo.hdoInfo[index];
            [(MIOHdoServiceCodeCell*)cell setViewModel:self.viewModel];
            [(MIOHdoServiceCodeCell*)cell setModelWithCouponHdoInfo:couponHdoInfo];
        } break;
    }
    
    return cell;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"coupon"]) {
        MIOCouponCell* cell = sender;
        [(MIOCouponViewController*) segue.destinationViewController setModelWithCouponInfo:cell.couponInfo];
    } else if ([segue.identifier isEqualToString:@"couponUsage"]) {
        MIOHdoServiceCodeCell* cell = (MIOHdoServiceCodeCell*) [[sender superview] superview]; // FIXME
        [(MIOCouponUsageViewController*) segue.destinationViewController setModelWithCouponHdoInfo:cell.couponHdoInfo];
    }
}

@end
