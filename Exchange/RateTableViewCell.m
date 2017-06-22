//
//  RateTableViewCell.m
//  Exchange
//
//  Created by xiangwei wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "RateTableViewCell.h"
#import <ReactiveObjC.h>

@implementation RateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    RAC(self.currencyImageView, image) = [RACObserve(self, rateItem) map:^id _Nullable(EXRateItem *  _Nullable value) {
        if(value == nil) {
            return nil;
        } else {
            return [UIImage imageNamed:value.foreignCurrency];
        }
    }];
    
    RAC(self.titleLabel, text) = [RACObserve(self, rateItem) map:^id _Nullable(EXRateItem *  _Nullable value) {
        if(value == nil) {
            return @"N/A";
        }
        return NSLocalizedString(value.foreignCurrency, nil);
    }];
    
    RAC(self.rateLabel, text) = [RACObserve(self, rateItem) map:^id _Nullable(EXRateItem *  _Nullable value) {
        if(value == nil) {
            return @"N/A";
        }
        double unit = [[NSUserDefaults standardUserDefaults] doubleForKey:@"unit"];
        if(unit == 0) {
            unit = 1;
        }
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [numberFormatter setLocale:[NSLocale currentLocale]];
        [numberFormatter setMaximumFractionDigits:3];

        [numberFormatter setCurrencySymbol:@""];

        return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:value.exchangeRate * unit]];// [NSString stringWithFormat:@"%.3f", ];
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setRateItem:(EXRateItem *)rateItem {
    _rateItem = rateItem;
//    [self.rateLabel sizeToFit];
//    self.titleLabel.textAlignment = NSTextAlignmentLeft;
}
@end
