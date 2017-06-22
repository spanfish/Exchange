//
//  RateTableViewCell.h
//  Exchange
//
//  Created by xiangwei wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EXRateItem.h"

@interface RateTableViewCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UIImageView *currencyImageView;
@property(nonatomic, weak) IBOutlet UILabel *titleLabel;
@property(nonatomic, weak) IBOutlet UILabel *rateLabel;

@property(nonatomic, strong) EXRateItem *rateItem;
@end
