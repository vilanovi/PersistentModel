//
//  DMPersistentStore.h
//  Created by Joan Martin on 1/23/13.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMPersistentStore.h"

typedef enum __PMCoreDataStoreType
{
    PMCoreDataStoreTypeSQLite,
    PMCoreDataStoreTypeBinary
} PMCoreDataStoreType;

@interface PMCoreDataStore : PMPersistentStore

- (id)initWithURL:(NSURL *)url storeType:(PMCoreDataStoreType)type;

@property (nonatomic, assign, readonly) PMCoreDataStoreType storeType;

@end
