//
//  EXRateItem.h
//  Exchange
//
//  Created by xiangwei wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EXElement : NSObject
@property(nonatomic, strong) NSMutableString *accum;
@property(nonatomic, assign, readonly) BOOL canAddString;

- (void)clearString;
// Add character data parsed from the xml
- (void)addString:(NSString *)str;
@end

@interface EXRateItem : EXElement {
    struct {
        int inTitle:1;
        int inLink:1;
        int inDesc:1;
    } flags;
}
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *link;
@property(nonatomic, strong) NSString *desc;

@property(nonatomic, strong) NSString *baseCurrency;
@property(nonatomic, strong) NSString *foreignCurrency;

@property(nonatomic, assign) double exchangeRate;
- (void)beginTitle;
- (void)endTitle;
- (void)beginLink;
- (void)endLink;
- (void)beginDesc;
- (void)endDesc;
- (void)beginItem;
- (void)endItem;
@end


@interface EXChannel : EXElement {
    struct {
        int inLastBuildDate:1;
    } flags;
}

@property(nonatomic, strong) NSString *lastBuildDate;

- (void)beginLastBuildDate;
- (void)endLastBuildDate;

@end
