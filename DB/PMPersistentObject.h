//
//  PMPersistentObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>

/*!
 * Persistent objects must implement this protocol to adopt the required schema: `key` (String), `type` (String), `lastUpdate` (Date) and `data` (BLOB).
 */
@protocol PMPersistentObject <NSObject>

/*!
 * Used to identify the model object.
 */
@property (nonatomic, readonly) NSString *key;

/*!
 * Used to identify the type of the model object.
 */
@property (nonatomic, readonly) NSString *type;

/*!
 * Used to retrieve the last update of the model object.
 */
@property (nonatomic) NSDate *lastUpdate;

/*!
 * Used to store the model object data.
 */
@property (nonatomic) NSData *data;

@end
