//
//  PMUser.h
//  PersistentModelTest
//
//  Created by Joan Martin on 21/03/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMBaseObject.h"

@interface PMUser : PMBaseObject

@property (nonatomic, strong) NSString *username;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, strong) NSURL *avatarURL;

@end
