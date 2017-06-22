//
//  AppDelegate.h
//  Exchange
//
//  Created by xiangwei wang on 2017/06/21.
//  Copyright © 2017 xiangwei wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

