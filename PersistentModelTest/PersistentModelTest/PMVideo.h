//
//  PMVideo.h
//  PersistentModelTest
//
//  Created by Joan Martin on 21/03/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMBaseObject.h"

@class PMUser;

@interface PMVideo : PMBaseObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *about;

@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger viewsCount;

@property (nonatomic, strong) NSString *uploaderKey;
@property (nonatomic, strong) NSArray *participantsKeys;

- (PMUser*)uploader;

@end
