//
//  PMSQLiteStore_Private.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMSQLiteStore.h"

@class PMSQLiteObject;

@interface PMSQLiteStore ()

- (void)didChangePersistentObject:(PMSQLiteObject*)object;

@end
