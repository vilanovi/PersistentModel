//
//  PMBaseObject+PrivateMethods.m
//  PersistentModelTest
//
//  Created by Joan Martin on 04/07/14.
//  Copyright (c) 2014 Joan Martin. All rights reserved.
//

#import "PMBaseObject+PrivateMethods.h"

static NSString* stringFromClass(Class theClass)
{
    static NSMapTable *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        map = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    });
    
    NSString *string = [map objectForKey:theClass];
    
    if (!string)
    {
        string = NSStringFromClass(theClass);
        [map setObject:string forKey:theClass];
    }
    
    return string;
}

@implementation PMBaseObject (PrivateMethods)

+ (NSArray*)pmd_allPersistentPropertyNames
{
    static NSMutableDictionary *persistentProperties = nil;
    
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        persistentProperties = [NSMutableDictionary dictionary];
    });
    
    NSString *className = stringFromClass(self);
    NSArray *propertyNames = persistentProperties[className];
    
    if (!propertyNames)
    {
        Class superClass = [self superclass];
        
        NSMutableArray *array = nil;
        
        if ([superClass isSubclassOfClass:PMBaseObject.class])
            array = [[superClass pmd_allPersistentPropertyNames] mutableCopy];
        else
            array = [NSMutableArray array];
        
        [array addObjectsFromArray:[self pmd_persistentPropertyNames]];
        
        propertyNames = [array copy];
        persistentProperties[className] = propertyNames;
    }
    
    return propertyNames;
}

@end
