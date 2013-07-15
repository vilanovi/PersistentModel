//
//  PMSQLiteObject.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMSQLiteObject.h"

#import "PMSQLiteStore_Private.h"

@implementation PMSQLiteObject

- (id)initWithDataBaseIdentifier:(NSInteger)dbID
{
    self = [super init];
    if (self)
    {
        _dbID = dbID;
        _key = nil;
        _type = nil;
        _hasChanges = NO;
    }
    return self;
}

- (id)initWithKey:(NSString*)key andType:(NSString *)type
{
    self = [super init];
    if (self)
    {
        _dbID = NSNotFound;
        _key = key;
        _type = type;
        _hasChanges = NO;
    }
    return self;
}

- (void)setDbID:(NSInteger)dbID
{
    _dbID = dbID;
}

- (void)setHasChanges:(BOOL)hasChanges
{
    _hasChanges = hasChanges;
    
    if (_hasChanges)
        [_persistentStore didChangePersistentObject:self];
}

- (void)setLastUpdate:(NSDate *)lastUpdate
{
    BOOL sameValue = [_lastUpdate isEqual:lastUpdate];
    
    _lastUpdate = lastUpdate;
    
    self.hasChanges = _hasChanges || !sameValue;
}

- (void)setData:(NSData *)data
{
    BOOL didChange = ![_data isEqualToData:data];
    
    _data = data;
    
    self.hasChanges = _hasChanges || didChange;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    _hasChanges = ![value isEqual:[self valueForKey:key]] || _hasChanges;
    [super setValue:value forKey:key];
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@: <id:%d> <key:%@> <type:%@> <lastUpdate:%@> <dataLength:%d>",[super description], _dbID, _key, _type, _lastUpdate.description, _data.length];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return NO;
    
    return [[(PMSQLiteObject*)object key] isEqualToString:_key];
}

@end
