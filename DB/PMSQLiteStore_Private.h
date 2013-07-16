//
//  PMSQLiteStore_Private.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMSQLiteStore.h"

@class PMSQLiteObject;

/*!
 * Main category extension for private methods.
 */
@interface PMSQLiteStore ()

/*!
 * Use this method to notify the udpate of a persistent object.
 * @param object The persistent object.
 * @discussion PMSQLiteObjects uses this method to notify changes to the persistent store.
 */
- (void)didChangePersistentObject:(PMSQLiteObject*)object;

@end
