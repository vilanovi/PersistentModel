//
//  PMBaseObject.h
//  Created by Joan Martin on 10/17/12.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import "PMKeyMappingObject.h"

@class PMObjectContext;

/*!
 * Superclass of all model objects. This class contains all the logic in order to manipulate properties via KVC.
 */
@interface PMBaseObject : PMKeyMappingObject <NSCoding, NSCopying>

- (id)initWithContext:(PMObjectContext*)context andKey:(NSString*)key;
- (id)initWithContext:(PMObjectContext*)context andValues:(NSDictionary*)dictionary;
- (id)initWithContext:(PMObjectContext*)context andValues:(NSDictionary*)dictionary logUndefinedMappings:(BOOL)flag;

+ (PMBaseObject*)baseObjectWithDictionary:(NSDictionary*)dictionary inContext:(PMObjectContext*)context;
+ (PMBaseObject*)baseObjectWithKey:(NSString *)key inContext:(PMObjectContext*)context allowsCreation:(BOOL)flag;

@property (nonatomic, weak, readonly) PMObjectContext *context;

/*! The unique key that identifies the object */
@property (nonatomic, strong) NSString *key;

/*! The date of the last update */
@property (nonatomic, strong) NSDate *lastUpdate;

/*! Indicates if we trust the current object data. This value is computed using the lastUpdate value and the response of the method -trustedTimeIntervalFromLastUpdate.*/
@property (nonatomic, readonly) BOOL hasTrustedData;

/*! This method returns the trusted time since the last update. Subclasses may override in order to set a custom value. The default value is 1 hour.*/
- (NSTimeInterval)trustedTimeIntervalFromLastUpdate;

/*! YES if any attribute has been changed since the last save, otherwise NO */
@property (nonatomic, assign) BOOL hasChanges;

- (void)deleteObjectFromContext;
- (BOOL)registerToContext:(PMObjectContext*)context;

+ (NSSet*)keysForPersistentValues;
+ (NSDictionary*)dictionaryWithKeysForMappingKeys;

@end
