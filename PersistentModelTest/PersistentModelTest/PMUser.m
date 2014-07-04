//
//  PMUser.m
//  PersistentModelTest
//
//  Created by Joan Martin on 21/03/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMUser.h"

@implementation PMUser

+ (NSArray*)pmd_persistentPropertyNames
{
    return @[mjz_key(username),
             mjz_key(age),
             mjz_key(avatarURL),
             ];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - %@, %ld, %@", [super description], _username, (long)_age, _avatarURL.absoluteString];
}

@end
