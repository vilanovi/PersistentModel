//
//  PMSQLiteObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import "PMPersistentObject.h"

@class PMSQLiteStore;

/*!
 * This class represents the PersistentObject for a SQLite storage.
 */
@interface PMSQLiteObject : NSObject <PMPersistentObject>

/// ---------------------------------------------------------------------------------------------------------
/// @name Creating instances and initializing
/// ---------------------------------------------------------------------------------------------------------

/*!
 * Initializer to identify the current PersistentObject to a database entry.
 * @param dbID The database identifeir.
 * @return The initialized instance.
 */
- (id)initWithDataBaseIdentifier:(NSInteger)dbID;

/*!
 * Use this initializer for init the current PersistentObject when there is not entry created yet into the database.
 * @param key The model object identifier.
 * @param type The model object type.
 * @return The initialized instance.
 */
- (id)initWithKey:(NSString*)key andType:(NSString*)type;

/// ---------------------------------------------------------------------------------------------------------
/// @name Main Attributes
/// ---------------------------------------------------------------------------------------------------------

/*!
 * SQLite database identifier.
 */
@property (nonatomic, assign) NSInteger dbID;

// *** PMPersistentObject ************************* //
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSData *data;
// ************************************************ //

/*!
 * This property track changes of the current PersistentObject.
 */
@property (nonatomic, assign, readonly) BOOL hasChanges;

/// ---------------------------------------------------------------------------------------------------------
/// @name Persistent Store Management
/// ---------------------------------------------------------------------------------------------------------

/*!
 * Weak reference to the persistent store the current object is related to.
 */
@property (nonatomic, weak) PMSQLiteStore *persistentStore;

@end
