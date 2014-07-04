//
//  PMAppDelegate.m
//  PersistentModelTest
//
//  Created by Joan Martin on 27/02/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMAppDelegate.h"

#import "PMObjectContext.h"
#import "PMSQLiteStore.h"

#import "PMVideo.h"
#import "PMUser.h"

NSURL* applicationCacheDirectory();

@implementation PMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    [self performTest];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = [UIViewController new];
    
    return YES;
}

- (void)performTest
{
    NSURL *url = [applicationCacheDirectory() URLByAppendingPathComponent:@"PersistentStorage.sql"];
    
//    [[NSFileManager defaultManager] removeItemAtURL:url error:nil]; // <------ COMMENT AND UNCOMMENT THIS LINE TO DELETE THE PERSISTENT STORAGE
    
    // Creating the persistent store
    PMPersistentStore *persistentStore = [[PMSQLiteStore alloc] initWithURL:url];
    
    // Creating an object context connected to the above persistent store
    PMObjectContext *objectContext = [[PMObjectContext alloc] initWithPersistentStore:persistentStore];
    
    // Lets check if the user exist in the persistent layer.
    PMUser *user = [PMUser objectWithKey:@"user-1" inContext:objectContext allowsCreation:NO];
    
    if (user)
    {
        NSLog(@"Found user in persistent storage: %@", user.description);
    }
    else
    {
        NSLog(@"User not found in persistent storage ==> Lets create a user and save it!");
        
        // If it doesn't exist, lets create a new user for that key.
        user = [PMUser objectWithKey:@"user-1" inContext:objectContext allowsCreation:YES];
        
        user.username = @"john.doe";
        user.age = 25;
        user.avatarURL = [NSURL URLWithString:@"http://www.twitter.com/john.doe"];
        
        // Flag changes on user! Otherwise won't be saved!
        user.hasChanges = YES;
        
        NSLog(@"Saving user: %@", user.description);
        
        [objectContext save];
        
        NSLog(@"Saved!");
    }
}

@end


NSURL* applicationCacheDirectory()
{
    static NSURL *url = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSArray *pathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = [pathList[0] stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
        
        // Create cache path if it doesn't exist, yet:
        BOOL isDir = NO;
        NSError *error;
        if (! [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO)
            [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:&error];
        
        url = [NSURL fileURLWithPath:cachePath];
    });
    
    return url;
}
