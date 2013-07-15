//
//  PMBaseObject.h
//  Created by Joan Martin on 10/17/12.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import "PMKeyMappingObject.h"

extern NSString * const PMPersistentModelNilKeyException;

@class PMObjectContext;

/*!
 * Superclass of persistent objects. 
 * This class contains all the logic in order to manipulate properties via KVC.
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

+ (NSSet*)keysForPersistentValues;

+ (NSDictionary*)dictionaryWithKeysForMappingKeys;

@end
