//
//  DMPersistentStore.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMCoreDataStore.h"

#import "PMCoreDataObject.h"

#import <pthread.h>

@interface PMCoreDataStore ()

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation PMCoreDataStore
{
    NSMutableDictionary *_contexts;
}

- (id)initWithURL:(NSURL*)url
{
    return [self initWithURL:url storeType:PMCoreDataStoreTypeSQLite];
}

- (id)initWithURL:(NSURL *)url storeType:(PMCoreDataStoreType)type
{
    self = [super initWithURL:url];
    if (self)
    {
        _contexts = [NSMutableDictionary dictionary];
        _storeType = type;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

#pragma mark Public Methods

- (PMCoreDataObject*)persistentObjectWithKey:(NSString*)key
{
    if (key == nil)
    {
        NSString *reason = @"Cannot query for a persistent object with a nil key.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ModelObject"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self.key == %@", key];

    NSError *error = nil;
    NSArray *result = [self.currentManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSAssert(result.count <= 1, @"MORE THAN ONE OBJECT IN PERSISTENCE WITH THE SAME KEY <%@>", key);
    
    return [result lastObject];
}

- (PMCoreDataObject*)createPersistentObjectWithKey:(NSString*)key ofType:(NSString*)type
{
    if (key == nil)
    {
        NSString *reason = @"Cannot create a persistent object with a nil key.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }
    else if (type == nil)
    {
        NSString *reason = @"Cannot create a persistent object with a nil type.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }
    
    PMCoreDataObject *existingObject = [self persistentObjectWithKey:key];
    
    if (existingObject)
    {
        NSString *reason = @"Cannot create a persitent object because it exists already an object with the given key.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:@{PMPersistentStoreObjectKey: existingObject}];
        [exception raise];
        return nil;
    }
    
    PMCoreDataObject *modelObject = [[PMCoreDataObject alloc] initWithEntity:[NSEntityDescription entityForName:@"ModelObject" inManagedObjectContext:self.currentManagedObjectContext]
                                        insertIntoManagedObjectContext:self.currentManagedObjectContext];
    modelObject.key = key;
    modelObject.type = type;
    
    return modelObject;
}

- (NSArray*)persistentObjectsOfType:(NSString*)type
{
    if (type == nil)
    {
        NSString *reason = @"Cannot query for persistent objects with a nil type.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ModelObject"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self.type == %@", type];
    
    NSError *error = nil;
    NSArray *result = [self.currentManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return result;
}

- (void)deletePersistentObjectWithKey:(NSString*)key
{
    if (key == nil)
    {
        NSString *reason = @"Cannot delete a persistent object with a nil key.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return;
    }
    
    PMCoreDataObject *object = (PMCoreDataObject*)[self persistentObjectWithKey:key];
    
    if (object)
        [self.currentManagedObjectContext deleteObject:object];
}

- (BOOL)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"ModelObject"];
    if (type)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self.lastUpdate < %@ AND self.type = %@", date, type];
    else
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self.lastUpdate < %@", date];
    
    NSError *error = nil;
    NSArray *result = [self.currentManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error)
        return NO;
    
    for (PMCoreDataObject *object in result)
        [[self currentManagedObjectContext] deleteObject:object];

    [self save];
    
    return YES;
}

#pragma mark - Core Data

// ****************************************************************************** //
// ****************************************************************************** //
// *******************************  CORE DATA  ********************************** //
// ****************************************************************************** //
// ****************************************************************************** //

@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)save
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.currentManagedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    return error == nil;
}

- (NSManagedObjectContext *)newManagedObjectContext
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    NSManagedObjectContext *managedObjectContext = nil;
    
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    }

    return managedObjectContext;
}

- (NSManagedObjectContext*)currentManagedObjectContext
{
    mach_port_t tid = pthread_mach_thread_np(pthread_self());
    
//    NSInteger tid = (NSInteger)[NSThread currentThread];
    
//    NSString *threadDesc = [NSThread currentThread].description;
//    NSString *string = [[threadDesc componentsSeparatedByString:@"num = "] lastObject];
//    string = [string substringToIndex:string.length-1];
//    NSInteger tid = [string integerValue];
    
//    NSLog(@"CONTEXT IN THREAD: %d",tid);
    
    NSManagedObjectContext *context = [_contexts objectForKey:@(tid)];
    
    if (!context)
    {
        context = [self newManagedObjectContext];
        [_contexts setObject:context forKey:@(tid)];
    }
    
    return context;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
        return _managedObjectModel;
    
    NSArray *bundleIdentifiers = @[@"com.metamedia.CitizenTV", @"com.metamedia.CitizenTVTests"];
    
    NSBundle *bundle = nil;
    
    for (NSString *identifier in bundleIdentifiers)
    {
        bundle = [NSBundle bundleWithIdentifier:identifier];
        if (bundle != nil)
            break;
    }
    
    NSURL *modelURL = [bundle URLForResource:@"PersistentModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
        return _persistentStoreCoordinator;
    
    NSURL *storeURL = self.url;
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSString *storeType = nil;
    
    if (_storeType == PMCoreDataStoreTypeSQLite)
        storeType = NSSQLiteStoreType;
    else if (_storeType == PMCoreDataStoreTypeBinary)
        storeType = NSBinaryStoreType;
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark Notifications

- (void)notificationReceived:(NSNotification*)notification
{
    NSArray *allContexts = _contexts.allValues;
    
    for (NSManagedObjectContext *context in allContexts)
    {
        if (context != notification.object)
            [context reset];
//            [context mergeChangesFromContextDidSaveNotification:notification];
    }
}

@end
