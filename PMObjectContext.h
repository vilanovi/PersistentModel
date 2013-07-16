//
//  PMObjectContext.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>

@class PMBaseObject;
@class PMPersistentStore;

/*!
 * After a successful save, this notification is posted.
 * UserInfo will contain the keys 'PMObjectContextSavedObjectsKey' and 'PMObjectContextDeletedObjectsKey' to retrieve the saved and deleted objects respectively.
 */
extern NSString * const PMObjectContextDidSaveNotification;

/*!
 * Key to be used in the UserInfo dictionary of the 'PMObjectContextDidSaveNotification' notification to retrieve the saved objects.
 */
extern NSString * const PMObjectContextSavedObjectsKey;

/*!
 * Key to be used in the UserInfo dictionary of the 'PMObjectContextDidSaveNotification' notification to retrieve the deleted objects.
 */
extern NSString * const PMObjectContextDeletedObjectsKey;

/*!
 * TODO
 */
@interface PMObjectContext : NSObject

/*!
 * Default initializer. 
 * @param persistentStore The persistent store to use. If nil any peristent store will be used and model won't be able to persist.
 */
- (id)initWithPersistentStore:(PMPersistentStore*)persistentStore;

/*!
 * The current used persistent store.
 */
@property (nonatomic, strong, readonly) PMPersistentStore *persistentStore;

/*!
 * Boolean indicating if there are changes to save or not. YES if any new object has been inserted, deleted or modifyed, otherwise NO
 * @discussion This property works withing the 'hasChanges' property of 'PMBaseObject'. Remember that in 'PMBaseObject' changes are tracked via KVC methods. If you modify an object directly is your responsibility to set the flag 'hasChanges' to YES.
 */
@property (nonatomic, assign, readonly) BOOL hasChanges;

/*!
 * Returns the object for for the given identifier key.
 * @param key A unique key identifying the object.
 * @return The persistent instance associated to the given key.
 * @discussion The method returns the "living instance" of the object if already awaked, otherwase it awakes from the persistence layer the object and returns it. If the object has never been created, returns nil.
 */
- (PMBaseObject*)objectForKey:(NSString*)key;

/*!
 * Call this method to check the existence of an object for a given key in the current context (living instances).
 * @param key A unike key identifying the object.
 * @return YES if exists an object with the given key in the current context, otherwise NO.
 */
- (BOOL)containsObjectWithKey:(NSString*)key;

/*!
 * This method returns all living instances registered on that context.
 * @return An array with all living instances for the current context.
 */
- (NSArray*)registeredObjects;

/*!
 * Use this method to insert unregistered 'PMBaseObject's into the current context.
 * @param object The object to insert. This argument cannot be nil, otherwise a 'NSInvalidArgumentException' exception will be rised.
 * @return YES if the object has beeen inserted, NO otherwise.
 * @discussion If there is another object in the context with the same key, the given object won't be inserted into the context and the method will return NO. To persist changes a 'save' is required
 */
- (BOOL)insertObject:(PMBaseObject*)object;

/*!
 * Use this method to delete a registered object from the context.
 * @param object The object to delete.
 * @discussion This method will unregister the object from the context by setting the object.context to nil and stop tracking changes of it. To persist changes a 'save' is required.
 */
- (void)deleteObject:(PMBaseObject*)object;

/*!
 * Saves the current context into the persistent store. This method is equivalent to '-saveWithCompletionBlock:' with a NULL block as argument.
 */
- (void)save;

/*!
 * Saves the current context into the persistent store. 
 * @param completionBlock This block is called once the save is finished and contains a parameter 'succeed' to check if the saving has been successful.
 * @discussion This method operates in a background thread (even calling the completion block).
 */
- (void)saveWithCompletionBlock:(void (^)(BOOL succeed))completionBlock;

/*!
 * When having multiple contexts operating on the same persistent store, call this method from the 'PMObjectContextDidSaveNotification' posted by other contexts to update the current state of the current context.
 */
- (void)mergeChangesFromContextDidSaveNotification:(NSNotification*)notification;

/*!
 * Queries to the persistent store and returns all objects stored of the given class.
 * @param objectClass The class to retrieve all stored objects.
 * @return An array with all instances of the specified class.
 */
- (NSArray*)objectsOfClass:(Class)objectClass;

@end
