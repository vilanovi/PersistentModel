//
//  PMSQLiteStore.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMPersistentStore.h"

@class PMSQLiteObject;

extern NSString * const PMSQLiteStoreUpdateException;

@interface PMSQLiteStore : PMPersistentStore

- (void)closeStore;
- (void)cleanCache;

@end
