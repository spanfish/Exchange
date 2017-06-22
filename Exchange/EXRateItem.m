//
//  EXRateItem.m
//  Exchange
//
//  Created by xiangwei wang on 2017/06/22.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import "EXRateItem.h"

@implementation EXElement
// Add character data parsed from the xml
- (void)addString:(NSString *)str {
    if (self.canAddString) {
        if (!_accum) {
            _accum = [[NSMutableString alloc] init];
        }
        [_accum appendString:str];
    }
}

- (void)clearString {
    _accum = nil;
}
@end

@implementation EXChannel
- (BOOL)canAddString {
    return flags.inLastBuildDate;
}

- (void)beginLastBuildDate {
    flags.inLastBuildDate = YES;
}

- (void)endLastBuildDate {
    flags.inLastBuildDate = NO;
    self.lastBuildDate = [self.accum copy];
    [self clearString];
}
@end

@implementation EXRateItem
- (BOOL)canAddString {
    return flags.inDesc || flags.inLink || flags.inTitle;
}

- (void)beginItem {
    
}

- (void)endItem {
    self.baseCurrency = nil;
    self.foreignCurrency = nil;
    
    NSRange range = [self.link rangeOfString:@"://"];
    if(range.location != NSNotFound) {
        NSUInteger fromLocation = range.location + 3;
        NSUInteger toLocation = fromLocation;
        while (toLocation < [self.link length]) {
            if([self.link characterAtIndex:toLocation] != '.') {
                toLocation++;
            } else {
                break;
            }
        }
        self.baseCurrency = [[self.link substringWithRange:NSMakeRange(fromLocation, toLocation - fromLocation)] uppercaseString];
    }
    
    NSUInteger toLocation = [self.link length] - 1;
    while(toLocation > 0 && [self.link characterAtIndex:toLocation] == '/') {
        toLocation--;
    }
    NSUInteger fromLocation = toLocation;
    while(fromLocation > 0 && [self.link characterAtIndex:fromLocation] != '/') {
        fromLocation--;
    }
    
    self.foreignCurrency = [[self.link substringWithRange:NSMakeRange(fromLocation + 1, toLocation - fromLocation)] uppercaseString];
    
    NSLog(@"title:%@, foreignCurrency:%@", self.title, self.foreignCurrency);
}

- (void)beginTitle {
    flags.inTitle = YES;
}

- (void)endTitle {
    flags.inTitle = NO;
    self.title = [self.accum copy];
    [self clearString];
}

- (void)beginLink {
    flags.inLink = YES;
}

- (void)endLink {
    flags.inLink = NO;
    self.link = [self.accum copy];
    [self clearString];
}

- (void)beginDesc {
    flags.inDesc = YES;
}

- (void)endDesc {
    flags.inDesc = NO;
    self.desc = [self.accum copy];
    [self clearString];
    
    NSScanner *scanner = [NSScanner scannerWithString:self.desc];
    double base = 0, foreign = 0;
    [scanner scanDouble:&base];
    [scanner scanUpToString:@"=" intoString:NULL];
    [scanner scanString:@"=" intoString:nil];
    [scanner scanDouble:&foreign];
    if(foreign != 0 && base != 0) {
        self.exchangeRate = foreign / base;
    }
}
@end
