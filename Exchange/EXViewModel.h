//
//  EXViewModel.h
//  Exchange
//
//  Created by xiangwei wang on 2017/06/21.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXRateItem.h"
#import <ReactiveObjC.h>

@interface EXViewModel : NSObject

@property (nonatomic, strong) RACSubject *updatedContentSignal;
@property(nonatomic, strong) NSArray<EXRateItem *> *rateArray;
@property(nonatomic, assign) NSUInteger unit;

-(void) fetchExchangeRateWithBaseCurrency:(NSString *) currency;
-(instancetype) initWithCurrency:(NSString *) currency;
@end
