//
//  EXViewModel.m
//  Exchange
//
//  Created by xiangwei wang on 2017/06/21.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "EXViewModel.h"
#import "EXParser.h"

//#define FEED_JPY @"http://jpy.fx-exchange.com/rss.xml"
@interface EXViewModel() {
    EXParser *_parser;
}
@end

@implementation EXViewModel

-(instancetype) init {
    self = [super init];
    if(self) {
        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"EXViewModel updatedContentSignal"];
        NSInteger unit = [[NSUserDefaults standardUserDefaults] integerForKey:@"Unit"];
        if(unit == 0) {
            unit = 1;
        }
        self.unit = unit;
    }
    return self;
}

-(void) fetchExchangeRateWithBaseCurrency:(NSString *) currency {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@.jp.fx-exchange.com/rss.xml", currency]]];
    [[NSURLConnection rac_sendAsynchronousRequest:request] subscribeNext:^(RACTwoTuple<NSHTTPURLResponse *,NSData *> * _Nullable x) {
        NSHTTPURLResponse *response = [x first];
        NSData *feed = [x second];
        if([response statusCode] == 200) {
            _parser = [[EXParser alloc] initWithFeed:feed];
            
            [[_parser parseKML] subscribeNext:^(RACTwoTuple<EXChannel *, NSArray *> *  _Nullable m) {
                self.rateArray = [m second];
                [_updatedContentSignal sendNext:nil];
            }];
        }
    }];
}
@end
