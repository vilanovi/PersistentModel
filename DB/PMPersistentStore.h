//
//  PMPersistentStore.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>

@protocol PMPersistentObject;

/*!
 * Multiples deleting options.
 */
typedef enum __PMOptionDelete
{
    /*!
     * Delete by comparing creation date.
     */
    PMOptionDeleteByCreationDate,
    
    /*!
     * Delete by comparing access date.
     */
    PMOptionDeleteByAccessDate,
    
    /*!
     * Delete by comparing updating date.
     */
    PMOptionDeleteByUpdateDate
} PMOptionDelete;


/*!
 * This value is used as Key in NSException and NSNotifications userInfo dictionary.
 */
extern NSString * const PMPersistentStoreObjectKey;

/*!
 * This is an abstract class that encapsulates the main functionalities for the persistent store.
 * Subclasses may override all methods and implement them following the specifications.
 */
@interface PMPersistentStore : NSObject

/*!
 * Default initializer.
 * @param url The url of the persistent store. Cannot be nil.
 * @return The initialized instance.
 */
- (id)initWithURL:(NSURL*)url;

/*!
 * The url of the persistent store.
 */
@property (nonatomic, strong, readonly) NSURL *url;

/*!
 * This method should retrieve from the store the object with the given key identifier. If the object is not found in the store, return nil.
 * @param key The model object identifier. Cannot be nil.
 * @return The associated persistent object or nil.
 */
- (id<PMPersistentObject>)persistentObjectWithKey:(NSString*)key;

/*!
 * This method queries all stored objects for the given type.
 * @param type The model object type. Cannot be nil.
 * @return An array with all stored objects of the given type.
 */
- (NSArray*)persistentObjectsOfType:(NSString*)type;

/*!
 * Creates a new persistent object and returns it for a model object key and type.
 * @param key The model object identifier. Cannot be nil.
 * @param type The model object type. Cannot be nil.
 * @return The persistent object.
 * @discussion If already exists an object with the given key, this method raises a NSInvalidArgumentException exception with the existent object in the userInfo exception field (accessible via the key 'PMPersistentStoreObjectKey'). In order to persist changes it is needed to call the method 'save'.
 */
- (id<PMPersistentObject>)createPersistentObjectWithKey:(NSString*)key ofType:(NSString*)type;

/*!
 * Removes a persistent object from the store.
 * @param key The model object identifier. Cannot be nil.
 * @discussion In order to persist changes it is needed to call the method 'save'.
 */
- (void)deletePersistentObjectWithKey:(NSString*)key;

/*!
 * Removes all persistent objects for the given type, date and policy.
 * @param type The model object type. If nil, type is ignored.
 * @param date This is a time offset to query object into the store.
 * @param option Deleting policy can be by creation date, access date or update date.
 * @return YES if the deletion is successful, otherwise NO.
 * @discussion This method might operate direclty on the storage without need of performing posterior 'save' of the current persistent store.
 */
- (BOOL)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option;

/*!
 * Call this method to persist changes.
 * @return YES if saved successfully, NO otherwise.
 * @discussion This method is executed in the current thread. A NO value as return indicates that the saving is not successful, not that the saving is not performed. That means that part of the persistent model could be saved, part not.
 */
- (BOOL)save;

@end
