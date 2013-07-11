//
//  PMObjectContext.m
//  Created by Joan Martin on 1/23/13.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMObjectContext.h"

#import "PMBaseObject.h"

#import "PMCoreDataObject.h"
#import "PMPersistentObject.h"
#import "PMPersistentStore.h"

NSString * const PMObjectContextDidSaveNotification = @"PMObjectContextDidSaveNotification";
NSString * const PMObjectContextSavedObjectsKey = @"PMObjectContextSavedObjectsKey";
NSString * const PMObjectContextDeletedObjectsKey = @"PMObjectContextDeletedObjectsKey";

@implementation PMObjectContext
{
    NSMutableDictionary *_objects;
    NSMutableSet *_deletedObjects;
    BOOL _hasChanges;
    
    BOOL _isSaving;
    NSCondition *_savingCondition;
    NSInteger _savingOperationIndex;
}

- (id)initWithPersistentStore:(PMPersistentStore *)persistentStore
{
    self = [super init];
    if (self)
    {
        _persistentStore = persistentStore;
        
        _hasChanges = NO;
        _isSaving = NO;
        _savingCondition = [[NSCondition alloc] init];
        _objects = [NSMutableDictionary dictionary];
        _deletedObjects = [NSMutableSet set];
    }
    return self;
}

#pragma mark Properties

- (BOOL)hasChanges
{
    if (_hasChanges)
        return YES;
    
    NSArray *allObjects = _objects.allValues;
    
    for (PMBaseObject *object in allObjects)
    {
        if (object.hasChanges)
            return YES;
    }
    
    return NO;
}

#pragma mark Public Methods

- (PMBaseObject*)objectForKey:(NSString*)key
{    
    PMBaseObject* object = [_objects valueForKey:key];
    
    if (!object)
        object = [self _baseObjectFromPersistentStoreWithKey:key];
    
    return object;
}

- (BOOL)containsObjectWithKey:(NSString*)key
{
    return [_objects valueForKey:key] != nil;
}

- (NSArray*)registeredObjects
{
    return _objects.allValues;
}

- (void)insertObject:(PMBaseObject*)object
{
    if (object != nil)
    {
        _hasChanges = YES;
        [_objects setValue:object forKey:object.key];
    }
}

- (void)deleteObject:(PMBaseObject*)object
{
    if ([_objects.allValues containsObject:object])
    {
        _hasChanges = YES;
        [_objects removeObjectForKey:object.key];
        [_deletedObjects addObject:object];
        [object deleteObjectFromContext];
    }
}

- (void)save
{
    [self saveWithCompletionBlock:NULL];
}

- (void)saveWithCompletionBlock:(void (^)(BOOL succeed))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _savingOperationIndex += 1;
        NSInteger currentOperationIndex = _savingOperationIndex;
        
        [_savingCondition lock];
        
        while (_isSaving)
            [_savingCondition wait];
        
        _isSaving = YES;
        
        BOOL shouldSaveCoreDataContext = _hasChanges;
        
        // -- SAVED OBJECTS -- //
        NSMutableSet *savedObjects = [NSMutableSet set];
        NSArray *allValues = [_objects.allValues copy];
        for (PMBaseObject *object in allValues)
        {
            if (object.hasChanges)
            {
                shouldSaveCoreDataContext = YES;
                [self _updatePersistentModelObjectOfBaseObject:object];
                object.hasChanges = NO;
                [savedObjects addObject:object];
            }
        }
        
        // -- DELETED OBJECTS -- //
        NSSet *deletedObjects = [_deletedObjects copy];
        shouldSaveCoreDataContext |= deletedObjects.count > 0;
        for (PMBaseObject *object in deletedObjects)
            [_persistentStore deletePersistentObjectWithKey:object.key];
        
        BOOL succeed = NO;
        if (shouldSaveCoreDataContext)
            succeed = [_persistentStore save];
        
        if (succeed)
            [_deletedObjects removeAllObjects];
        
        _hasChanges = NO;
        
        _isSaving = NO;
        [_savingCondition signal];
        [_savingCondition unlock];
        
        if (completionBlock)
            completionBlock(succeed);
        
        if (currentOperationIndex == _savingOperationIndex)
        {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            if (savedObjects.count > 0)
                [dict setValuesForKeysWithDictionary:@{PMObjectContextSavedObjectsKey : savedObjects}];
            if (deletedObjects.count > 0)
                [dict setValuesForKeysWithDictionary:@{PMObjectContextDeletedObjectsKey : deletedObjects}];
            
            NSNotification *notification = [NSNotification notificationWithName:PMObjectContextDidSaveNotification
                                                                         object:self
                                                                       userInfo:dict];
            
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }
        
    });
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification*)notification
{
    if (notification.object == self)
        return;
    
    NSArray *savedObjects = [notification.userInfo valueForKey:PMObjectContextSavedObjectsKey];
    
    for (PMBaseObject *object in savedObjects)
    {
        PMBaseObject *myObject = [_objects valueForKey:object.key];
        
        if (myObject)
        {
            NSDictionary *keyedValues = [object dictionaryWithValuesForKeys:[[object.class keysForPersistentValues] allObjects]];
            
            [myObject setValuesForKeysWithDictionary:keyedValues];
            myObject.hasChanges = NO;
            myObject.lastUpdate = object.lastUpdate;
        }
    }
}

- (NSArray*)objectsOfClass:(Class)objectClass
{
    if (![objectClass isSubclassOfClass:[PMBaseObject  class]])
        return @[];
    
    NSArray *result = [_persistentStore persistentObjectsOfType:NSStringFromClass(objectClass)];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (PMCoreDataObject *mo in result)
    {
        PMBaseObject *baseObject = [_objects valueForKey:mo.key];
        
        if (!baseObject)
        {
            baseObject = [self _baseObjectFromModelObject:mo];
            [self insertObject:baseObject];
        }
        
        [array addObject:baseObject];
    }
    
    return array;
}

#pragma mark Private Methods

- (void)_updatePersistentModelObjectOfBaseObject:(PMBaseObject*)baseObject
{    
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeRootObject:baseObject];
    [archiver finishEncoding];
    
    id<PMPersistentObject> object = [_persistentStore persistentObjectWithKey:baseObject.key];
    
    if (!object)
        object = [_persistentStore createPersistentObjectWithKey:baseObject.key ofType:NSStringFromClass([baseObject class])];
    
    object.lastUpdate = baseObject.lastUpdate;
    object.data = data;
}

- (PMBaseObject*)_baseObjectFromPersistentStoreWithKey:(NSString*)key
{
    id<PMPersistentObject> object = [_persistentStore persistentObjectWithKey:key];
    
    if (object)
    {
        PMBaseObject *baseObject = [self _baseObjectFromModelObject:object];
        [self insertObject:baseObject];
        
        return baseObject;
    }
    
    return nil;
}

- (PMBaseObject*)_baseObjectFromModelObject:(id<PMPersistentObject>)modelObject
{
    NSAssert(modelObject != nil, @"ModelObject should not be nil");
    NSAssert(modelObject.key != nil, @"Model Object of type %@ has a key == ", modelObject.type, modelObject.key);
    
    NSData *data = modelObject.data;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    PMBaseObject *baseObject = [unarchiver decodeObject];
    [baseObject registerToContext:self];
    baseObject.lastUpdate = modelObject.lastUpdate;
    
    return baseObject;
}

@end
