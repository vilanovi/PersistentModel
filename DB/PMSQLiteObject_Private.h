//
//  PMSQLiteObject_Private.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMSQLiteObject.h"

/*!
 * Main category extension for private methods.
 */
@interface PMSQLiteObject ()

/*!
 * Use this method to modify the readonly 'hasChanges' property in a 'PMSQLiteObject'.
 * @param hasChanges Flag indicating if has changes.
 */
- (void)setHasChanges:(BOOL)hasChanged;

@end
