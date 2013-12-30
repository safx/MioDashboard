//
//  MIOTableViewCell.h
//  MioDashboard
//
//  Created by Safx Developer on 2013/12/30.
//  Copyright (c) 2013年 Safx Developers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MIOCouponInfo;
@class MIOPacketLogInfo;
@class MIOPacketHdoInfo;
@class MIOCouponHdoInfo;
@class MIOServiceViewModel;

@interface MIOHdoServiceCodeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *hdoServiceCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *regulationLabel;
@property (weak, nonatomic) IBOutlet UILabel *smsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *couponSwitch;
@property (weak, nonatomic) IBOutlet UILabel *couponUsedLabel;
@property (weak, nonatomic) MIOCouponHdoInfo* couponHdoInfo;
@property (weak, nonatomic) MIOPacketHdoInfo* packetHdoInfo;
@property (weak, nonatomic) MIOServiceViewModel* viewModel;

- (IBAction)onCouponSwitchTouched:(UISwitch *)sender;
- (void)setModelWithCouponHdoInfo:(MIOCouponHdoInfo*)couponHdoInfo packetHdoInfo:(MIOPacketHdoInfo*)packetHdoInfo;
@end


@interface MIOCouponCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *couponLabel;
@property (weak, nonatomic) MIOCouponInfo* couponInfo;
@property (weak, nonatomic) MIOPacketLogInfo* packetLogInfo;
- (void)setModelWithCouponInfo:(MIOCouponInfo*)couponInfo packetHdoInfo:(MIOPacketLogInfo*)packetLogInfo;
@end

