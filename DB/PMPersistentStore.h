//
//  PMPersistentStore.h
//  Created by Joan Martin on 2/15/13.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import "PMPersistentObject.h"

typedef enum __PMOptionDelete
{
    PMOptionDeleteByCreationDate,
    PMOptionDeleteByAccessDate,
    PMOptionDeleteByUpdateDate
} PMOptionDelete;

/*!
 * This is an abstract class.
 */
@interface PMPersistentStore : NSObject

- (id)initWithURL:(NSURL*)url;

@property (nonatomic, strong) NSURL *url;

- (id<PMPersistentObject>)persistentObjectWithKey:(NSString*)key;

- (NSArray*)persistentObjectsOfType:(NSString*)type;

- (id<PMPersistentObject>)createPersistentObjectWithKey:(NSString*)key ofType:(NSString*)type;

- (void)deletePersistentObjectWithKey:(NSString*)key;

- (void)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option;

- (BOOL)save;

@end
