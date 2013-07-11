//
//  MMKeyMappingObject.m
//  Created by Joan Martin on 1/9/13.
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
        MMLog(@"WARNING: Unrecognized Key <%@> for class %@", key, [self.class description]);
        [self _registerUnrecognizedSetterWithKey:key ofType:NSStringFromClass([value class])];
    }
}

- (id)valueForUndefinedKey:(NSString *)key
{    
    if (_logUndefinedMappings)
    {
        MMLog(@"WARNING: Unrecognized Key <%@> for class %@",key, [self.class description]);
        [self _registerUnrecognizedGetterWithKey:key];
    }
    
    return nil;
}

#pragma mark Private Methods

static NSString * const UndefinedKeyRegisterFileName = @"UndefinedKeys.txt";

- (void)_registerUnrecognizedGetterWithKey:(NSString*)key
{    
    NSString *methodType = @"GET";
    NSString *entity = NSStringFromClass(self.class);
    
    NSString *text = [NSString stringWithFormat:@"MethodType:<%@> Entity:<%@> UndefinedKey:<%@>", methodType, entity, key];
    
    PLog(text, UndefinedKeyRegisterFileName);
}

- (void)_registerUnrecognizedSetterWithKey:(NSString*)key ofType:(NSString*)type
{    
    NSString *methodType = @"SET";
    NSString *entity = NSStringFromClass(self.class);
    
    NSString *text = [NSString stringWithFormat:@"MethodType:<%@> Entity:<%@> UndefinedKey:<%@> Type:<%@>", methodType, entity, key, type];
    
    PLog(text, UndefinedKeyRegisterFileName);
}

@end
