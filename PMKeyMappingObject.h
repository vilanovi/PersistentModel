//
//  MMKeyMappingObject.h
//  Created by Joan Martin on 1/9/13.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>

@interface PMKeyMappingObject : NSObject

- (id)initWithMapping:(NSDictionary*)mapping;

@property (nonatomic, strong, readonly) NSArray *mappings;
@property (nonatomic, assign) BOOL logUndefinedMappings;

- (void)addKeyMapping:(NSDictionary*)dictionary;
- (void)removeKeyMapping:(NSDictionary*)dictionary;

- (NSDictionary*)dictionaryWithValuesForKeys:(NSArray*)keys;

- (NSString*)mapKey:(NSString*)key;

/*!
 * Subclasses may override this method in order to customize the "setter" of a specific value for a given key.
 * @param value The value to set.
 * @param key The value identifier.
 * @return The validated value.
 * @discussion The default implementation of this method does nothing and just returns the value parameter.
 */
- (id)validateValue:(id)value forMappedKey:(NSString*)key;

- (void)setValue:(id)value forMappedKey:(NSString *)key;

@end
