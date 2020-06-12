//
//  AppDelegate.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [AMapServices sharedServices].apiKey = MapKey;
    [AMapServices sharedServices].enableHTTPS = YES;
    return YES;
}







@end
