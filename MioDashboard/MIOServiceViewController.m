//
//  MIOServiceViewController.m
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import "MIOResponse.h"
#import "MIOServiceViewController.h"
#import "MIOServiceViewModel.h"
#import "MIOTableViewCell.h"
#import "MIOCouponViewController.h"
#import "MIOCouponUsageViewController.h"

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
    [RACObserve(self.viewModel, couponResponse.couponInfo) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    [RACObserve(self.viewModel, packetResponse.packetLogInfo) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
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
    return self.viewModel.couponResponse.couponInfo.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MIOCouponInfo* info = self.viewModel.couponResponse.couponInfo[section];
    return info.hddServiceCode;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MIOCouponInfo* info = self.viewModel.couponResponse.couponInfo[section];
    return 1 + info.hdoInfo.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < 1? 44: 280;
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
    MIOCouponInfo* couponInfo = self.viewModel.couponResponse.couponInfo[indexPath.section];
    NSString* hdd = couponInfo.hddServiceCode;
    MIOPacketLogInfo* packetLogInfo = Underscore.find(self.viewModel.packetResponse.packetLogInfo, ^BOOL(MIOPacketLogInfo* e) {
        return [e.hddServiceCode isEqualToString:hdd];
    });
    
    int index = indexPath.row - 1;
    switch (indexPath.row) {
        case 0:  [(MIOCouponCell*)cell setModelWithCouponInfo:couponInfo packetHdoInfo:packetLogInfo]; break;
        default: {
            MIOCouponHdoInfo* couponHdoInfo = couponInfo.hdoInfo[index];
            NSString* hdo = couponHdoInfo.hdoServiceCode;
            
            MIOPacketHdoInfo* packetHdoInfo = Underscore.find(packetLogInfo.hdoInfo, ^BOOL(MIOPacketHdoInfo* e) {
                return [e.hdoServiceCode isEqualToString:hdo];
            });

            [(MIOHdoServiceCodeCell*)cell setViewModel:self.viewModel];
            [(MIOHdoServiceCodeCell*)cell setModelWithCouponHdoInfo:couponHdoInfo packetHdoInfo:packetHdoInfo];
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
        [(MIOCouponViewController*) segue.destinationViewController setModelWithCouponInfo:cell.couponInfo packetLogInfo:cell.packetLogInfo];
    } else if ([segue.identifier isEqualToString:@"couponUsage"]) {
        MIOHdoServiceCodeCell* cell = (MIOHdoServiceCodeCell*) [[[sender superview] superview] superview]; // FIXME
        [(MIOCouponUsageViewController*) segue.destinationViewController setModelWithpacketHdoInfo:cell.packetHdoInfo];
    }
}

@end
