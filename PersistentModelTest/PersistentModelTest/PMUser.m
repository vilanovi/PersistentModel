//
//  PMUser.m
//  PersistentModelTest
//
//  Created by Joan Martin on 21/03/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMUser.h"

@implementation PMUser

+ (NSSet *)keysForPersistentValues
{
    static NSSet *persistentKeys = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistentKeys = [NSSet setWithArray:@[@"username",
                                               @"age",
                                               @"avatarURL",
                                               ]];
    });
    
    return persistentKeys;
}

@end
