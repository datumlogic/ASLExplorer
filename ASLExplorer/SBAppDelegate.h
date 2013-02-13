//
//  SBAppDelegate.h
//  ASLExplorer
//
//  Created by Paul Dardeau on 2/8/13.
//  Copyright (c) 2013 Paul Dardeau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) NSString *sender;
@property (strong, nonatomic) NSString *gid;
@property (strong, nonatomic) NSString *uid;
@property (strong, nonatomic) NSString *pid;

@end
