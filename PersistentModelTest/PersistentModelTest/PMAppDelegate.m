//
//  PMAppDelegate.m
//  PersistentModelTest
//
//  Created by Joan Martin on 27/02/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMAppDelegate.h"

#import "PMObjectContext.h"
#import "PMPersistentStore.h"

#import "PMVideo.h"
#import "PMUser.h"

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self performTest];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)performTest
{
    // TODO
}

@end
