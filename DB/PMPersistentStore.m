//
//  PMPersistentStore.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMPersistentStore.h"

@implementation PMPersistentStore

- (id)initWithURL:(NSURL*)url
{
    // Abstract class
    if (self.class == [PMPersistentStore class])
        return nil;
    
    self = [super init];
    if (self)
    {
        _url = url;
    }
    return self;
}

- (id<PMPersistentObject>)persistentObjectWithKey:(NSString*)key
{
    // Subclasses must override.
    return nil;
}

- (NSArray*)persistentObjectsOfType:(NSString*)type
{
    // Subclasses must override.
    return nil;
}

- (id<PMPersistentObject>)createPersistentObjectWithKey:(NSString*)key ofType:(NSString*)type
{
    // Subclasses must override.
    return nil;
}

- (void)deletePersistentObjectWithKey:(NSString*)key
{
    // Subclasses must override.
}

- (void)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option
{
    // Subclasses must override.
}

- (BOOL)save
{
    // Subclasses must override.
    return NO;
}

@end
