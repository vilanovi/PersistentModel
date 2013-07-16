//
//  PMPersistentStore.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMPersistentStore.h"

#import "PMPersistentObject.h"

NSString * const PMPersistentStoreObjectKey = @"PMPersistentStoreObjectKey";

@implementation PMPersistentStore

- (id)initWithURL:(NSURL*)url
{
    if (self.class == [PMPersistentStore class])
    {
        NSString *reason = @"PMPersistentStore cannot be instanciated thus it's an abstract class. Try by instanciating PMSQliteStore or PMCoreDataStore.";
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }

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

- (BOOL)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option
{
    // Subclasses must override.
    return NO;
}

- (BOOL)save
{
    // Subclasses must override.
    return NO;
}

@end
