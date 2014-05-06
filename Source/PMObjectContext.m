//
//  PMObjectContext.m
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

#import "PMObjectContext.h"

#import "PMBaseObject.h"
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
        object = [self pmd_baseObjectFromPersistentStoreWithKey:key];
    
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

- (BOOL)insertObject:(PMBaseObject*)object
{
    if (object == nil)
    {
        NSString *reason = @"You cannot insert a nil object into a context.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return NO;
    }
    
    if ([self containsObjectWithKey:object.key])
        return NO;
    
    _hasChanges = YES;
    [_objects setValue:object forKey:object.key];
    return YES;
}

- (void)deleteObject:(PMBaseObject*)object
{
    if (object == nil)
    {
        NSString *reason = @"You cannot delete a nil object from a context.";
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        [exception raise];
        return;
    }
    
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
    void (^saveBlock)() = ^{
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
                [self pmd_updatePersistentModelObjectOfBaseObject:object];
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
    };
    
    if ([NSThread isMainThread])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            saveBlock();
        });
    }
    else
    {
        saveBlock();
    }
}

- (void)mergeChangesFromContextDidSaveNotification:(NSNotification*)notification
{
    PMObjectContext *savedContext = notification.object;
    
    // If it is the same context, nothing to do
    if (savedContext == self)
        return;
    
    // If both context doesn't share the same persistent store, nothing to do
    if (savedContext.persistentStore != _persistentStore && _persistentStore != nil)
        return;
    
//    // If both context doesn't share the same persistent store url, nothing to do
//    if (![[savedContext.persistentStore.url path] isEqualToString:[_persistentStore.url path]])
//        return;
    
    NSArray *savedObjects = [notification.userInfo valueForKey:PMObjectContextSavedObjectsKey];
    
    for (PMBaseObject *object in savedObjects)
    {
        PMBaseObject *myObject = [_objects valueForKey:object.key];
        
        if (myObject)
        {
            NSDictionary *keyedValues = [object dictionaryWithValuesForKeys:[[object keysForPersistentValues] allObjects]];
            
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
    
    for (id <PMPersistentObject> mo in result)
    {
        PMBaseObject *baseObject = [_objects valueForKey:mo.key];
        
        if (!baseObject)
        {
            baseObject = [self pmd_baseObjectFromModelObject:mo];
            baseObject.hasChanges = NO;
            [self insertObject:baseObject];
        }
        
        [array addObject:baseObject];
    }
    
    return array;
}

#pragma mark Private Methods

- (void)pmd_updatePersistentModelObjectOfBaseObject:(PMBaseObject*)baseObject
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

- (PMBaseObject*)pmd_baseObjectFromPersistentStoreWithKey:(NSString*)key
{
    id<PMPersistentObject> object = [_persistentStore persistentObjectWithKey:key];
    
    if (object)
    {
        PMBaseObject *baseObject = [self pmd_baseObjectFromModelObject:object];
        baseObject.hasChanges = NO;
        [self insertObject:baseObject];

        return baseObject;
    }
    
    return nil;
}

- (PMBaseObject*)pmd_baseObjectFromModelObject:(id<PMPersistentObject>)modelObject
{    
    NSAssert(modelObject != nil, @"ModelObject should not be nil");
    NSAssert(modelObject.key != nil, @"Model Object of type %@ has a key == ", modelObject.type, modelObject.key);
    
    NSData *data = modelObject.data;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    PMBaseObject *baseObject = [unarchiver decodeObject];
    baseObject.key = modelObject.key;
    [baseObject registerToContext:self];
    baseObject.lastUpdate = modelObject.lastUpdate;
    
    return baseObject;
}

@end
