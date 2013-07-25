//
//  PMSQLiteStore.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMPersistentStore.h"

@class PMSQLiteObject;

/*!
 * SQLite implementation for the PMPersistentStore.
 *
 * This class uses the FMDB SQLite database management.
 * You can download the latest version in https://github.com/ccgus/fmdb
 */
@interface PMSQLiteStore : PMPersistentStore

/// ---------------------------------------------------------------------------------------------------------
/// @name Managing the Store
/// ---------------------------------------------------------------------------------------------------------

/*!
 * Call this method to close the store.
 */
- (void)closeStore;

/*!
 * Call this method to clean the current cached persisted objects.
 */
- (void)cleanCache;

@end
