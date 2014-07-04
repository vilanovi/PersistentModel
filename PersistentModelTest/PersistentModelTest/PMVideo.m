//
//  PMVideo.m
//  PersistentModelTest
//
//  Created by Joan Martin on 21/03/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMVideo.h"
#import "PMUser.h"

@implementation PMVideo

+ (NSArray*)pmd_persistentPropertyNames
{
    return @[mjz_key(title),
             mjz_key(about),
             mjz_key(likesCount),
             mjz_key(viewsCount),
             mjz_key(uploaderKey),
             mjz_key(participantsKeys),
             ];
}

- (PMUser*)uploader
{
    if (_uploaderKey)
        return [PMUser objectWithKey:_uploaderKey inContext:self.context allowsCreation:NO];
    
    return nil;
}

@end
