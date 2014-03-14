//
//  PMSQLiteObject.m
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

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@: <id:%ld> <key:%@> <type:%@> <lastUpdate:%@> <dataLength:%ld>",[super description], (long)_dbID, _key, _type, _lastUpdate.description, (long)_data.length];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return NO;
    
    return [[(PMSQLiteObject*)object key] isEqualToString:_key];
}

- (NSUInteger)hash
{
    NSString *string = [NSString stringWithFormat:@"%ld-%@",(long)_dbID, _key];
    return string.hash;
}

#pragma mark Private Methods

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

#pragma mark Key Value Coding

- (void)setValue:(id)value forKey:(NSString *)key
{
    _hasChanges = ![value isEqual:[self valueForKey:key]] || _hasChanges;
    [super setValue:value forKey:key];
}

@end
