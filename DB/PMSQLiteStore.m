//
//  PMSQLiteStore.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMSQLiteStore.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabasePool.h"
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"

#import "PMSQLiteObject_Private.h"

NSString * const PMSQLiteStoreUpdateException = @"PMSQLiteStoreUpdateException";

#define UpdateException [NSException exceptionWithName:PMSQLiteStoreUpdateException reason:nil userInfo:nil]

@implementation PMSQLiteStore
{
    FMDatabaseQueue *_dbQueue;
    NSMutableDictionary *_dictionary;
    
    NSMutableSet *_insertedObjects;
    NSMutableSet *_deletedObjects;
    NSMutableSet *_updatedObjects;
}

- (id)initWithURL:(NSURL *)url
{
    self = [super initWithURL:url];
    if (self)
    {
        _dictionary = [NSMutableDictionary dictionary];
        
        _insertedObjects = [NSMutableSet set];
        _deletedObjects = [NSMutableSet set];
        _updatedObjects = [NSMutableSet set];
        
        if (url)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]])
            {
                _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[url path]];
            }
            else
            {
                _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[url path]];
                [self _createTables];
            }
        }
    }
    return self;
}

#pragma mark Public Methods

- (void)closeStore
{
    [_dbQueue close];
}

- (PMSQLiteObject*)createPersistentObjectWithKey:(NSString*)key ofType:(NSString*)type
{
    NSAssert(key != nil, @"Trying to save base object of type %@ with a nil key", type);
    NSAssert(type != nil, @"Trying to save base object with key %@ with a nil type", key);
    
    PMSQLiteObject *object = [[PMSQLiteObject alloc] initWithKey:key andType:type];
    object.persistentStore = self;
    
    [_dictionary setValue:object forKey:key];
    [_insertedObjects addObject:object];
    
    return object;
}

- (PMSQLiteObject*)persistentObjectWithKey:(NSString*)key
{
    __block PMSQLiteObject *persistentObject = [_dictionary valueForKey:key];
    
    if (!persistentObject)
    {
        [_dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT Objects.id, Objects.type, Objects.updateDate, Data.data FROM Objects JOIN Data ON Objects.id = Data.id WHERE Objects.key = %@", key];
            
            if ([resultSet next])
            {
                persistentObject = [[PMSQLiteObject alloc] initWithDataBaseIdentifier:[resultSet intForColumnIndex:0]];
                persistentObject.persistentStore = self;
                persistentObject.key = key;
                persistentObject.type = [resultSet stringForColumnIndex:1];
                persistentObject.lastUpdate = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:2]];
                persistentObject.data = [resultSet dataForColumnIndex:3];
                
                [resultSet close];
            }
        }];
        
        [_dictionary setValue:persistentObject forKey:key];
    }
    
    [self _didAccessObjectWithID:persistentObject.dbID];
    
    return persistentObject;
}

- (NSArray*)persistentObjectsOfType:(NSString*)type
{
    __block  NSMutableArray *array = nil;
    
    NSMutableArray *dbIDs = [NSMutableArray array];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT Objects.id, Objects.key, Objects.type, Objects.updateDate, Data.data FROM Objects JOIN Data ON Objects.id = Data.id WHERE Objects.type = %@", type];
        
        array = [NSMutableArray array];
        
        while ([resultSet next])
        {
            PMSQLiteObject *persistentObject = [[PMSQLiteObject alloc] initWithDataBaseIdentifier:[resultSet intForColumnIndex:0]];
            persistentObject.persistentStore = self;
            persistentObject.key = [resultSet stringForColumnIndex:1];
            persistentObject.type = [resultSet stringForColumnIndex:2];
            persistentObject.lastUpdate = [NSDate dateWithTimeIntervalSince1970:[resultSet doubleForColumnIndex:3]];
            persistentObject.data = [resultSet dataForColumnIndex:4];
                        
            [array addObject:persistentObject];
            [dbIDs addObject:@(persistentObject.dbID)];
        }
        
        [resultSet close];
    }];

    for (NSNumber *dbID in dbIDs)
        [self _didAccessObjectWithID:[dbID integerValue]];
    
    return array;
}

- (void)deletePersistentObjectWithKey:(NSString*)key
{
    PMSQLiteObject *object = [self persistentObjectWithKey:key];
    
    [_dictionary removeObjectForKey:key];
    
    // If the object is queued to be inserted, remove from the queue.
    if ([_insertedObjects containsObject:object])
    {
        [_insertedObjects removeObject:object];
    }
    // If the object is queued to save changeds, remove form the queue and add to deleted objects list.
    else if ([_updatedObjects containsObject:object])
    {
        [_updatedObjects removeObject:object];
        [_deletedObjects addObject:object];
    }
    else
    {
        // If exists persistent object, add to deleted objects list
        if (object)
            [_deletedObjects addObject:object];
        
        // otherwise, there is nothing to do, the object is not stored in persistence.
    }
}

- (void)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option // <-- THIS METHOD SHOULD BE IN CONTEXT, NOT IN DB
{
    NSString *optionDate = nil;
    switch (option)
    {
        case PMOptionDeleteByAccessDate:
            optionDate = @"accessDate";
            break;

        case PMOptionDeleteByCreationDate:
            optionDate = @"creationDate";
            break;
            
        case PMOptionDeleteByUpdateDate:
            optionDate = @"updateDate";
            break;
    }
    
    NSString *query1 = nil;
    NSString *query2 = nil;

    if (type && ! date)
    {
        query1 = [NSString stringWithFormat:@"DELETE FROM Data WHERE id IN (SELECT Objects.id FROM Objects WHERE type = \"%@\")",type];
        query2 = [NSString stringWithFormat:@"DELETE FROM Objects WHERE type = \"%@\"", type];
    }
    else if (!type && date)
    {
        query1 = [NSString stringWithFormat:@"DELETE FROM Data WHERE id IN (SELECT Objects.id FROM Objects WHERE %@ < %f)",optionDate, [date timeIntervalSince1970]];
        query2 = [NSString stringWithFormat:@"DELETE FROM Objects WHERE %@ < %f",optionDate, [date timeIntervalSince1970]];
    }
    else if (type && date)
    {
        query1 = [NSString stringWithFormat:@"DELETE FROM Data WHERE id IN (SELECT Objects.id FROM Objects WHERE type = \"%@\" AND %@ < %f)", type, optionDate, [date timeIntervalSince1970]];
        query2 = [NSString stringWithFormat:@"DELETE FROM Objects WHERE type = \"%@\" AND %@ < %f",type, optionDate, [date timeIntervalSince1970]];
    }
    else //if (!type && !date)
    {
        query1 = @"DELETE FROM Data";
        query2 = @"DELETE FROM Objects";
    }
    
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try
        {
            if(![db executeUpdate:query1])
                @throw UpdateException;
            
            if (![db executeUpdate:query2])
                @throw UpdateException;
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }
    }];
}

- (BOOL)save
{
    @synchronized(self)
    {
        NSMutableSet *insertedObjects = [_insertedObjects copy];
        [_insertedObjects removeAllObjects];
        
        NSMutableSet *deletedObjects = [_deletedObjects copy];
        [_deletedObjects removeAllObjects];
        
        NSMutableSet *updatedObjects = [_updatedObjects copy];
        [_updatedObjects removeAllObjects];
        
        
        // -- Inserted Objects -- //
        for (PMSQLiteObject *object in insertedObjects)
        {
            [self _insertPersistentObject:object];
        }
        
        // -- Deleted Objects -- //
        for (PMSQLiteObject *object in deletedObjects)
        {
            [self _deletePersistentObject:object];
        }
        
        // -- Updated Objects -- //
        for (PMSQLiteObject *object in updatedObjects)
        {
            [self _updatePersistentObject:object];
            [object setHasChanges:NO];
        }
    }
    
    return YES;
}

- (void)cleanCache
{
    [_dictionary removeAllObjects];
}

#pragma mark Private Methods

- (void)didChangePersistentObject:(PMSQLiteObject*)object
{
    if (object.dbID != NSNotFound)
        [_updatedObjects addObject:object];
}

- (void)_createTables
{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try
        {
            [db executeUpdate:@"DROP TABLE Objects"];
            [db executeUpdate:@"DROP TABLE Data"];
            [db executeUpdate:@"CREATE TABLE Objects (id INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT UNIQUE NOT NULL, creationDate REAL, type TEXT, updateDate REAL, accessDate REAL)"];
            [db executeUpdate:@"CREATE TABLE Data (id INTEGER PRIMARY KEY, data BLOB, FOREIGN KEY(id) REFERENCES Objects(id))"];
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }
    }];
}

- (void)_insertEmptyPersistentObject:(PMSQLiteObject*)object
{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        @try
        {
            if (![db executeUpdate:@"INSERT INTO Objects (key, creationDate) values (?, ?)", object.key, @([[NSDate date] timeIntervalSince1970])])
                @throw UpdateException;
            
            sqlite_int64 dbID = db.lastInsertRowId;
            object.dbID = dbID;
            
            if(![db executeUpdate:@"INSERT INTO Data (id) values (?)", @(dbID)])
                @throw UpdateException;
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }
    }];
}

- (void)_insertPersistentObject:(PMSQLiteObject*)object
{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        @try
        {
            if (![db executeUpdate:@"INSERT INTO Objects (key, creationDate, type, updateDate, accessDate) values (?, ?, ?, ?, ?)",
                 object.key,
                 @([[NSDate date] timeIntervalSince1970]),
                 object.type,
                 object.lastUpdate,
                 object.lastUpdate
                 ])
                @throw UpdateException;
            
            sqlite_int64 dbID = db.lastInsertRowId;
            object.dbID = dbID;
            
            if(![db executeUpdate:@"INSERT INTO Data (id, data) values (?, ?)", @(dbID), object.data])
                @throw UpdateException;
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }        
    }];
}

- (void)_updatePersistentObject:(PMSQLiteObject*)object
{
    NSAssert(object.dbID != NSNotFound, @"PersistentObject must have a valid database identifier.");
    
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try
        {
            if (![db executeUpdate:@"UPDATE Objects SET type = ?, updateDate = ?, accessDate = ? WHERE id = ?", object.type, object.lastUpdate, object.lastUpdate, @(object.dbID)])
                @throw UpdateException;
            
            if(![db executeUpdate:@"UPDATE Data SET data = ? WHERE id = ?", object.data, @(object.dbID)])
                @throw UpdateException;
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }
    }];
}

- (void)_deletePersistentObject:(PMSQLiteObject*)object
{
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try
        {
        if (![db executeUpdate:@"DELETE FROM Objects WHERE id = ?", @(object.dbID)])
            @throw UpdateException;
            
        if (![db executeUpdate:@"DELETE FROM Data WHERE id = ?", @(object.dbID)])
            @throw UpdateException;
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }
    }];
}

- (void)_didAccessObjectWithID:(NSInteger)dbID
{
    if (dbID == NSNotFound)
        return;
    
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        @try
        {
            if(![db executeUpdate:@"UPDATE Objects SET accessDate = ? WHERE id = ?", @([[NSDate date] timeIntervalSince1970]), @(dbID)])
                @throw UpdateException;
        }
        @catch (NSException *exception)
        {
            if ([exception.name isEqualToString:PMSQLiteStoreUpdateException])
                *rollback = YES;
            else
                @throw exception;
        }
    }];
}

@end
