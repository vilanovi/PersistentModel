//
//  DMModelObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PMPersistentObject.h"

/*!
 * This class represents the PersistentObject for a CoreData storage.
 */
@interface PMCoreDataObject : NSManagedObject <PMPersistentObject>

// *** PMPersistentObject ************************* //
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSString *type;
// ************************************************ //

@end