//
//  DMModelObject.h
//  Created by Joan Martin on 10/18/12.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PMPersistentObject.h"

@interface PMCoreDataObject : NSManagedObject <PMPersistentObject>

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSDate *lastUpdate;
@property (nonatomic, retain) NSString *type;

@end