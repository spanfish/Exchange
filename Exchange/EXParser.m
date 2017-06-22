//
//  EXParser.m
//  Exchange
//
//  Created by xiangwei wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "EXParser.h"

#define ELTYPE(typeName) (NSOrderedSame == [elementName caseInsensitiveCompare:@#typeName])

@implementation EXParser

- (instancetype)initWithFeed:(NSData *)feed {
    if (self = [super init]) {
        _xmlParser = [[NSXMLParser alloc] initWithData:feed];
        [_xmlParser setDelegate:self];
        _itemArray = [NSMutableArray array];
        _channel = [[EXChannel alloc] init];

        _updatedContentSignal = [[RACSubject subject] setNameWithFormat:@"EXParser updatedContentSignal"];
    }
    return self;
}

- (RACSignal *)parseKML {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_xmlParser parse];
        [_updatedContentSignal sendNext:[RACTwoTuple tupleWithObjectsFromArray:@[_channel, _itemArray]]];
        return;
    });
    return _updatedContentSignal;
}

#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if (ELTYPE(channel)) {

    } else if (ELTYPE(lastBuildDate)) {
        [_channel beginLastBuildDate];
    } else if (ELTYPE(item)) {
        _rateItem = [[EXRateItem alloc] init];
        [_rateItem beginItem];
    } else if (ELTYPE(title)) {
        if(_rateItem) {
            [_rateItem beginTitle];
        }
    } else if (ELTYPE(link)) {
        if(_rateItem) {
            [_rateItem beginLink];
        }
    } else if (ELTYPE(description)) {
        if(_rateItem) {
            [_rateItem beginDesc];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName {
    if (ELTYPE(channel)) {

    } else if (ELTYPE(lastBuildDate)) {
        [_channel endLastBuildDate];
    } else if (ELTYPE(title)) {
        if(_rateItem) {
            [_rateItem endTitle];
        }
    } else if (ELTYPE(link)) {
        if(_rateItem) {
            [_rateItem endLink];
        }
    } else if (ELTYPE(description)) {
        if(_rateItem) {
            [_rateItem endDesc];
        }
    } else if (ELTYPE(item)) {
        [self.rateItem endItem];
        if(![self.rateItem.foreignCurrency isEqualToString:@"XOF"] && ![self.rateItem.baseCurrency isEqualToString:@"XOF"]) {
            [_itemArray addObject:self.rateItem];
        }
        
        self.rateItem = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    EXElement *element = self.rateItem == nil ? _channel : self.rateItem;
    [element addString:string];
}
@end
