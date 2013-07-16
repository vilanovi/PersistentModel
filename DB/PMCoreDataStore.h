//
//  DMPersistentStore.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMPersistentStore.h"

/*!
 * CoreData storage type.
 */
typedef enum __PMCoreDataStoreType
{
    /*!
     * Use SQLite within CoreData.
     */
    PMCoreDataStoreTypeSQLite,
    
    /*!
     * Use binary storage within CoreData.
     */
    PMCoreDataStoreTypeBinary
} PMCoreDataStoreType;

/*!
 * CoreData implementation for the PMPersistentStore.
 */
@interface PMCoreDataStore : PMPersistentStore

/*!
 * Default initializer.
 * @param url The url of the persistent store.
 * @param type The selected PMCoreDataStoreType. 
 * @return The initialized instance.
 */
- (id)initWithURL:(NSURL *)url storeType:(PMCoreDataStoreType)type;

/*!
 * The current store type.
 */
@property (nonatomic, assign, readonly) PMCoreDataStoreType storeType;

@end
