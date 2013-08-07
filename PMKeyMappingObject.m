//
//  PMKeyMappingObject.m
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

#import "PMKeyMappingObject.h"

@interface PMKeyMappingObject ()

@end

@implementation PMKeyMappingObject
{
    NSMutableDictionary *_mappings;
}

- (id)init
{
    return [self initWithMapping:nil];
}

- (id)initWithMapping:(NSDictionary*)mapping
{
    self = [super init];
    if (self)
    {
        _mappings = [NSMutableDictionary dictionary];
        _logUndefinedMappings = YES;
        
        if (mapping)
            [_mappings addEntriesFromDictionary:mapping];
    }
    return self;
}

- (NSString*)description
{
    NSArray *keys = [_mappings allValues];
    NSDictionary *keyValues = [self dictionaryWithValuesForKeys:keys];
    
    return [NSString stringWithFormat:@"%@ - MappedValues: %@", [super description], [keyValues description]];
}

#pragma mark Properties

- (NSDictionary*)mappings
{
    return [_mappings copy];
}

- (void)setMappings:(NSDictionary *)mappings
{
    _mappings = [mappings mutableCopy];
}

#pragma mark Public Methods

- (void)addKeyMapping:(NSDictionary*)dictionary
{
    [_mappings addEntriesFromDictionary:dictionary];
}

- (void)removeKeyMapping:(NSDictionary*)dictionary
{
    for (NSString *key in dictionary)
    {
        NSString *value1 = [dictionary valueForKey:key];
        NSString *value2 = [_mappings valueForKey:key];
        
        if ([value1 isEqualToString:value2])
            [_mappings removeObjectForKey:key];
    }
}

- (void)removeKeyMappingForKeys:(NSArray*)keys
{
    [_mappings removeObjectsForKeys:keys];
}

- (NSString*)mapKey:(NSString*)key
{
    NSString *mappedKey = [_mappings valueForKey:key];
    
    if (mappedKey)
        return mappedKey;
    
    return key;
}

#pragma mark Key Value Coding

- (void)setNilValueForKey:(NSString *)key
{
    // Subclasses may override
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSString *mappedKey = [self mapKey:key];
    
    NSError *error = nil;
    BOOL succeed = [self validateValue:&value forMappedKey:mappedKey firingKey:key error:&error];
    
    if (succeed)
    {
        [self setValue:value forMappedKey:mappedKey];
    }
    else
    {
#if DEBUG
        if (error)
            NSLog(@"WARNING: Cannot set value for key <%@> in class <%@>. Error: %@", key, NSStringFromClass(self.class), error.description);
#endif
    }
}

- (id)valueForKey:(NSString *)key
{
    NSString *mappedKey = [self mapKey:key];
    
    return [super valueForKey:mappedKey];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (_logUndefinedMappings)
    {
#if DEBUG
        NSLog(@"%s :: Unrecognized Key <%@> for class %@", __PRETTY_FUNCTION__, key, [self.class description]);
#endif
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{    
    if (_logUndefinedMappings)
    {
#if DEBUG
        NSLog(@"%s :: Unrecognized Key <%@> for class %@", __PRETTY_FUNCTION__, key, [self.class description]);
#endif
    }
    
    return nil;
}

@end

#pragma mark -

@implementation PMKeyMappingObject (KeyValueCoding)

- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forMappedKey:(NSString*)key firingKey:(NSString*)firingKey error:(out NSError *__autoreleasing *)outError
{
    return [self validateValue:ioValue forKey:key error:outError];
}

- (void)setValue:(id)value forMappedKey:(NSString *)key
{
    [super setValue:value forKey:key];
}

@end
