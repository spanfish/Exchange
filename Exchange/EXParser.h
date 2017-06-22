//
//  EXParser.h
//  Exchange
//
//  Created by xiangwei wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EXRateItem.h"
#import <ReactiveObjC.h>

@interface EXParser : NSObject<NSXMLParserDelegate> {
    NSXMLParser *_xmlParser;
}

@property(nonatomic, strong) EXChannel *channel;
@property(nonatomic, strong) NSMutableArray<EXRateItem *> *itemArray;
@property(nonatomic, strong) EXRateItem *rateItem;
@property (nonatomic, strong) RACSubject *updatedContentSignal;

- (instancetype)initWithFeed:(NSData *)feed;
- (RACSignal *)parseKML;

@end
