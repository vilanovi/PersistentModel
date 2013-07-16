//
//  PMBaseObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMKeyMappingObject.h"

extern NSString * const PMBaseObjectNilKeyException;

@class PMObjectContext;

/*!
 * Superclass of persistent objects. Persistent objects will have to be a subclass of this one.
 *
 * In order to persist properties, you can choose between:
 *       1. Manually encode and decode your properties using the NSCoding protocol methods
 *       2. Override the method "+keysForPersistentValues" and return a set of strings with the names of those properties you want to persist.
 *
 * Also, this class is subclass of "PMKeyMappingObject". That means you can add additional key-value mappings to get and set properties with multiple names.
 * In order to implement this functionality override the static method "+dictionaryWithKeysForMappingKeys" and return the additional mappings between the property names and custom names.
 * In the dictionary, the key is the additional key-value accessor name and the value is the property name:
 *
 *   + (NSDictionary*)dictionaryWithKeysForMappingKeys
 *   {
 *       return @{@"my_custom_key_name" : @"key"};
 *   }
 */
@interface PMBaseObject : PMKeyMappingObject <NSCoding, NSCopying>

/*!
 * Default init method.
 * @param context The context to register the object. Can be nil.
 * @param key The key to identify the created object. This key has to be unique for the given context. 
 * @discussion If initializing the object with a repeated key for the given context, this method retuns nil.
 */
- (id)initWithContext:(PMObjectContext*)context andKey:(NSString*)key;

/*!
 * Init method for initializing from a dictionary.
 * @param context The context to register the object. Can be nil.
 * @param dictionary A dictionary containing the set of values to be initialized via KVC. The property key is required to initialize the object.
 * @discussion If the key is not contained in the dictionary or already exists an object with this key in the given context, the method returns nil.
 */
- (id)initWithContext:(PMObjectContext*)context andValues:(NSDictionary*)dictionary;

/*!
 * Init method for initializing from a dictionary.
 * @param context The context to register the object. Can be nil.
 * @param dictionary A dictionary containing the set of values to be initialized via KVC. The property key is required to initialize the object.
 * @param flag Setting it to NO, undefined mappings won't be logged.
 * @discussion If the key is not contained in the dictionary or already exists an object with this key in the given context, the method returns nil.
 */
- (id)initWithContext:(PMObjectContext*)context andValues:(NSDictionary*)dictionary logUndefinedMappings:(BOOL)flag;

/*!
 * Default static method for creating an object.
 * @param key The key to identify the created object. This key has to be unique for the given context and cannot be nil.
 * @param context The context to register the object. Can be nil.
 * @param flag If NO, this method will return only previously created objects and won't create new instances for the given key.
 * @discussion If initializing the object with a repeated key for the given context, this method retuns nil.
 */
+ (PMBaseObject*)baseObjectWithKey:(NSString *)key inContext:(PMObjectContext*)context allowsCreation:(BOOL)flag;

/*!
 * Static method for creating and initializing from a dictionary.
 * @param dictionary A dictionary containing the set of values to be initialized via KVC. The property key is required to initialize the object.
 * @param context The context to register the object. Can be nil.
 * @discussion If the key is not contained in the dictionary or already exists an object with this key in the given context, the method returns nil.
 */
+ (PMBaseObject*)baseObjectWithDictionary:(NSDictionary*)dictionary inContext:(PMObjectContext*)context;

/*! 
 * The context where the object is registered to.
 * @discussion This value can be nil if the object is not registered in any context.
 */
@property (nonatomic, weak, readonly) PMObjectContext *context;

/*! 
 * The unique key that identifies the object 
 */
@property (nonatomic, strong) NSString *key;

/*! 
 * The date of the last update.
 * @discussion It is your responsability to refresh this property and set the latest change date of the current object. By default the nothing is done.
 */
@property (nonatomic, strong) NSDate *lastUpdate;

/*! 
 * YES if any attribute has been changed since the last save, otherwise NO 
 * @discussion The tracking of this property is done via KVC. If you set properties directly, you must set the has changes flag manually. Setting this flag to YES marks this object to be saved in the next context saving call. 
 */
@property (nonatomic, assign) BOOL hasChanges;

/*! 
 * In order to delete an object from the context, call this method.
 * @discussion This method invokes automatically the method "-deleteObject:" from the registered PMObjectContext.
 */
- (void)deleteObjectFromContext;

/*!
 * Use this method in order to regsiter a new object to the context.
 * @param context The context to regsiter the current object.
 * @return YES if succeed, otherwise NO.
 * @discussion If another object with the same key is registered in the context, this method will fail to register the new object and return NO.
 */
- (BOOL)registerToContext:(PMObjectContext*)context;

/*!
 * Set of property names that are automatically persistent via KVC access.
 * @discussion Subclasses may override this method to mark those properties to be persistent. Values will be accessed via KVC. By default this class returns an empty set.
 */
+ (NSSet*)keysForPersistentValues;

/*!
 * Dictionary with additional mappings for the current properties. In the dictionary, the key is the additional key-value accessor name and the value is the property name.
 * @discussion Subclasses may override this method to set additional mappings for class properties. By default this method returns an empty dictionary.
 *
 *   + (NSDictionary*)dictionaryWithKeysForMappingKeys
 *   {
 *       return @{@"my_custom_key_name" : @"key"};
 *   }
 */
+ (NSDictionary*)dictionaryWithKeysForMappingKeys;

@end
