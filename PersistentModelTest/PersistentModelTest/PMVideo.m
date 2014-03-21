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

+ (NSSet *)keysForPersistentValues
{
    static NSSet *persistentKeys = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        persistentKeys = [NSSet setWithArray:@[@"title",
                                               @"about",
                                               @"likesCount",
                                               @"viewsCount",
                                               @"uploaderKey",
                                               @"participants",
                                               ]];
    });
    
    return persistentKeys;
}

- (PMUser*)uploader
{
    if (_uploaderKey)
        return [PMUser objectWithKey:_uploaderKey inContext:self.context allowsCreation:NO];
    
    return nil;
}

@end
