//
//  PMBaseObject.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//
// Copyright (c) 2013 Joan Martin, vilanovi@gmail.com.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import "PMBaseObject.h"

#import "PMObjectContext.h"

NSString * const PMBaseObjectNilKeyException = @"PMBaseObjectNilKeyException";

@implementation PMBaseObject

- (id)init
{
    return [self initWithContext:nil andKey:nil];
}

- (id)initWithContext:(PMObjectContext*)context andKey:(NSString*)key
{
    if (!key)
        return nil;
    
    if ([context containsObjectWithKey:key])
        return nil;
    
    self = [super init];
    if (self)
    {
        _key = key;
        
        [self addKeyMapping:[self.class dictionaryWithKeysForMappingKeys]];
        
        _context = context;
                
        _hasChanges = NO;
        
        [_context insertObject:self];
    }
    return self;
}

- (id)initWithContext:(PMObjectContext*)context andValues:(NSDictionary*)dictionary
{
    return [self initWithContext:context andValues:dictionary logUndefinedMappings:YES];
}

- (id)initWithContext:(PMObjectContext*)context andValues:(NSDictionary*)dictionary logUndefinedMappings:(BOOL)flag
{
    NSDictionary *map = [self.class dictionaryWithKeysForMappingKeys];
    
    NSArray *allKeys = [map allKeysForObject:@"key"];
    NSString *webKey = nil;
    
    for (NSString *string in allKeys)
    {
        webKey = [dictionary valueForKey:string];
        if (webKey)
            break;
    }
    
    if (!webKey)
        return nil;
    
    self = [self initWithContext:context andKey:webKey];
    
    self.logUndefinedMappings = flag;
    [self setValuesForKeysWithDictionary:dictionary];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSDictionary *map = [self.class dictionaryWithKeysForMappingKeys];
    self = [super initWithMapping:map];
    
    if (self)
    {
        self.logUndefinedMappings = NO;
        NSArray *persistentKeys = [[self.class keysForPersistentValues] allObjects];
        for (NSString *key in persistentKeys)
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        self.logUndefinedMappings = YES;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSArray *persistentKeys = [[self.class keysForPersistentValues] allObjects];
    for (NSString *key in persistentKeys)
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
}

- (id)copyWithZone:(NSZone *)zone
{
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeRootObject:self];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    PMBaseObject *copy = [unarchiver decodeObject];
    
    return copy;
}

+ (PMBaseObject*)baseObjectWithKey:(NSString *)key inContext:(PMObjectContext*)context allowsCreation:(BOOL)flag
{
    if (key == nil)
    {
        NSString *reason = [NSString stringWithFormat:@"Trying to fetch an object of type %@ with a nil key.", NSStringFromClass(self)];
        NSException *exception = [NSException exceptionWithName:PMBaseObjectNilKeyException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }
    
    PMBaseObject *baseObject = [context objectForKey:key];
    
    if (baseObject)
        return baseObject;
    
    if (flag)
    {
        baseObject = [[self alloc] initWithContext:context andKey:key];
        return baseObject;
    }
    
    return nil;
}

+ (PMBaseObject*)baseObjectWithDictionary:(NSDictionary*)dictionary inContext:(PMObjectContext*)context
{
    NSDictionary *map = [self dictionaryWithKeysForMappingKeys];
    
    NSArray *allKeys = [map allKeysForObject:@"key"];
    NSString *webKey = nil;
    
    for (NSString *string in allKeys)
    {
        webKey = [dictionary valueForKey:string];
        if (webKey)
            break;
    }
    
    if (!webKey)
        return nil;
    
    PMBaseObject *baseObject = [self baseObjectWithKey:webKey inContext:context allowsCreation:YES];
    [baseObject setValuesForKeysWithDictionary:dictionary];
    
    return baseObject;
}

#pragma mark Key Value Coding

- (void)setValue:(id)value forMappedKey:(NSString *)key
{
    NSSet *persistentKeys = [self.class keysForPersistentValues];
    
    if ([persistentKeys containsObject:key])
        _hasChanges = YES;
    
    [super setValue:value forMappedKey:key];
}

#pragma mark Properties

- (void)setLastUpdate:(NSDate *)lastUpdate
{
    _lastUpdate = lastUpdate;
    _hasChanges = YES;
}

#pragma mark Public Methods

- (void)deleteObjectFromContext
{
    if (_context != nil)
    {
        PMObjectContext *context = _context;
        _context = nil;
        [context deleteObject:self];
    }
}

- (BOOL)registerToContext:(PMObjectContext*)context
{
    if ([context containsObjectWithKey:_key])
        return NO;
    
    _context = context;
    [_context insertObject:self];
    return YES;
}

+ (NSSet*)keysForPersistentValues
{
    return [NSSet set];
}

+ (NSDictionary*)dictionaryWithKeysForMappingKeys
{
    return @{};
}


@end

