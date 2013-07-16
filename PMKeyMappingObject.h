//
//  MMKeyMappingObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>

/*!
 * This class add multiple-key accessing via KVC to all its properties.
 * You can define multiple mappings to get and set properties via key-value accessing.
 *
 * This class override the KVC methods '-setValue:forKey:', '-valueForKey:', 'setValue:forUndefinedKey:' and '-valueForUndefinedKey:' in order to perform the multiple key-mapping.
 *
 * A mapping is defined by a dictionary, where keys are the additional names for the properties and values are the real name.
 *
 * If a object has the properties @"users" and @"projectName" you could define the following mapping:
 *
 *      NSDictionary *mapping = @{@"list_of_users": @"users",
 *                                @"server_project_name": @"projectName"};
 *
 * Then, after initialyzing your subclass of PMKeyMappingObject with this mapping, you can get & set properties via the new names.
 *
 *      MyKeyMappingObjectSubclass *object = [MyKeyMappingObjectSubclass alloc] initWithMapping:mapping];
 *      
 *      object.users = @[@"John", @"Anne"];
 *      NSArray *users = [object valueForKey:@"list_of_users"];
 *      NSLog(@"Users: %@", users.description) // $> <NSArray> [John, Anne]
 *
 *      [object setValue:@"The Big Wave" forKey:@"server_project_name"];
 *      NSString *name = object.projectName;
 *      NSLog(@"Project Name: %@", name); // $>The Big Wave
 *
 * This class also supports value validation. In order to validate your properties you can override the custom method '-validateValue:forMappedKey:firingKey:error:' or the default KVC validation methods '-validateValue:forKey:error:' or '-validate<PropertyName>:error:'. In all cases we will use the already mapped keys.
 */
@interface PMKeyMappingObject : NSObject

/*!
 * Default initializer.
 * @param mapping The mapping to be used for the KVC.
 * @return The initialized instance of the current object.
 */
- (id)initWithMapping:(NSDictionary*)mapping;

/*!
 * The current dictionary with key-mappings.
 */
@property (nonatomic, strong) NSDictionary *mappings;

/*!
 * Debug flag to print undefined mappings. 
 * @discussion In a release scheme, undfined mappings are not logged even this property is set to YES.
 */
@property (nonatomic, assign) BOOL logUndefinedMappings;

/*!
 * Add a new mapping dicctionary.
 * @param dictionary A dictionary containing the mappings to add.
 */
- (void)addKeyMapping:(NSDictionary*)dictionary;

/*!
 * Remove a set of mappings.
 * @param dictionary A dictionary containing the mappings to remove.
 * @discussion The mappings are going to be removed only if the given key-value pair are registered as a mapping. If the key-value doesn't correspond to the registered key-value nothing is done.
 */
- (void)removeKeyMapping:(NSDictionary*)dictionary;

/*!
 * Remove a set of mappings by keys.
 * @param keys An array with the list of keys to remove from the mapping.
 */
- (void)removeKeyMappingForKeys:(NSArray*)keys;

/*!
 * Perform a key-mapping.
 * @param key The key to map.
 * @return The mapped key if exist, otherwise the key itself.
 */
- (NSString*)mapKey:(NSString*)key;

@end

@interface PMKeyMappingObject (KeyValueCoding)

/*!
 * Validation method. Used within KVC validation. Subclasses might override this method (calling super if validation is not required) in order to perform validation.
 * @param ioValue Pointer to the value to be validated.
 * @param key The value identifier after the key-mapping conversion. Key is a formal property name.
 * @param firingKey The key with which has been invoked the key value setting (before the key-mapping).
 * @param outError If error, should assign the error to that pointer.
 * @return YES if validation is not required or if the validation succeed. NO if error (specify error in outError).
 * @discussion This method by default call the KVC validation method '-validationValue:forKey:error:', whose search for custom validation methods '-validate<PropertyName>:error:'. You can override this method in order to perform validation (calling supper if validation not required) or override/implement the default KVC validation pattern.
 */
- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forMappedKey:(NSString*)key firingKey:(NSString*)firingKey error:(out NSError *__autoreleasing *)outError;

/*!
 * Equivalent of "-setValue:forKey:" but for already mapped keys.
 * @param value The value to set.
 * @param key The mapped key (property name) to assign the new value.
 * @discussion This method sets directly the value for the given key without performing any kind of validation. If you want to have the validation layer, use '-setValue:forKey' instead.
 */
- (void)setValue:(id)value forMappedKey:(NSString *)key;

@end
