//
//  BaseCurrencyView.m
//  Exchange
//
//  Created by Xiangwei Wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "BaseCurrencyView.h"
#import <ReactiveObjC.h>

@implementation BaseCurrencyView

-(instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        UIView *view = [[[UINib nibWithNibName:@"BaseCurrencyView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
        [self addSubview:view];

        RACChannelTerminal *single = [[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"unit"];
        [[[single combineLatestWith:[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"base"]]
         deliverOnMainThread]
         subscribeNext:^(RACTwoTuple*  _Nullable x) {
             NSLog(@"%@", x);
             NSString *baseCurrency = [x second];
             
             UIImage *image = [UIImage imageNamed:baseCurrency];
             CGFloat imageW = image.size.width;
             CGFloat imageH = image.size.height;
             // リサイズする倍率を作成する。
             CGFloat scale = imageW / imageH;
             
             CGSize resizedSize = CGSizeMake(40 * scale, 40);
             UIGraphicsBeginImageContext(resizedSize);
             [image drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
             UIImage* resizedImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             
             self.currencyImageView.image = resizedImage;
             
             NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
             [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
             [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
             [numberFormatter setLocale:[NSLocale currentLocale]];
             [numberFormatter setMaximumFractionDigits:3];
             
             [numberFormatter setCurrencySymbol:@""];
             self.unitLabel.text = [numberFormatter stringFromNumber:[x first]];
        }];
        
//        [[[[NSUserDefaults standardUserDefaults] rac_channelTerminalForKey:@"base"] deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
//            @strongify(self);
//            NSString *baseCurrency = [[NSUserDefaults standardUserDefaults] objectForKey:@"base"];
//            [self.viewModel fetchExchangeRateWithBaseCurrency:[baseCurrency lowercaseString]];
//            [self showBaseImage];
//        }];
    }
    
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
