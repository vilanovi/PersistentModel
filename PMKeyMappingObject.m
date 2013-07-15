//
//  MMKeyMappingObject.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMKeyMappingObject.h"

@interface PMKeyMappingObject ()

@end

@implementation PMKeyMappingObject
{
    NSMutableArray *_mappings;
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
        _mappings = [NSMutableArray array];
        _logUndefinedMappings = YES;
        
        if (mapping)
            [_mappings addObject:mapping];
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ - MappedValues: %@", [super description], [[self dictionaryWithValuesForKeys:[[_mappings lastObject] allValues]] description]];
}

#pragma mark Properties

- (NSArray*)mappings
{
    return [_mappings copy];
}

#pragma mark Public Methods

- (void)addKeyMapping:(NSDictionary*)dictionary
{
    [_mappings addObject:dictionary];
}

- (void)removeKeyMapping:(NSDictionary*)dictionary
{
    [_mappings removeObject:dictionary];
}

- (NSDictionary*)dictionaryWithValuesForKeys:(NSArray*)keys
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    for (NSString *key in keys)
    {
        id value = [self valueForKey:key];
        
        if (value)
            [dic setObject:value forKey:key];
    }
    
    return [dic copy];
}

- (id)validateValue:(id)value forMappedKey:(NSString*)key
{
    return value;
}

- (NSString*)mapKey:(NSString*)key
{
    for (NSDictionary *mapping in _mappings)
    {
        NSString *mappedKey = [mapping valueForKey:key];
        
        if (mappedKey)
            return mappedKey;
    }
    
    return key;
}

- (void)setValue:(id)value forMappedKey:(NSString *)key
{
    value = [self validateValue:value forMappedKey:key];
    
    if (value)
        [super setValue:value forKey:key];
}

#pragma mark Key Value Coding

- (void)setValue:(id)value forKey:(NSString *)key
{
    NSString *mappedKey = [self mapKey:key];
    [self setValue:value forMappedKey:mappedKey];
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
