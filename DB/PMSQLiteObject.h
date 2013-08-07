//
//  PMSQLiteObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//
// Copyright (c) 2013 Joan Martin, vilanovi@gmail.com.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

#import <Foundation/Foundation.h>
#import "PMPersistentObject.h"

@class PMSQLiteStore;

/*!
 * This class represents the PersistentObject for a SQLite storage.
 */
@interface PMSQLiteObject : NSObject <PMPersistentObject>

/// ---------------------------------------------------------------------------------------------------------
/// @name Creating instances and initializing
/// ---------------------------------------------------------------------------------------------------------

/*!
 * Initializer to identify the current PersistentObject to a database entry.
 * @param dbID The database identifeir.
 * @return The initialized instance.
 */
- (id)initWithDataBaseIdentifier:(NSInteger)dbID;

/*!
 * Use this initializer for init the current PersistentObject when there is not entry created yet into the database.
 * @param key The model object identifier.
 * @param type The model object type.
 * @return The initialized instance.
 */
- (id)initWithKey:(NSString*)key andType:(NSString*)type;

/// ---------------------------------------------------------------------------------------------------------
/// @name Main Attributes
/// ---------------------------------------------------------------------------------------------------------

/*!
 * SQLite database identifier.
 */
@property (nonatomic, assign) NSInteger dbID;

// *** PMPersistentObject ************************* //
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSData *data;
// ************************************************ //

/*!
 * This property track changes of the current PersistentObject.
 */
@property (nonatomic, assign, readonly) BOOL hasChanges;

/// ---------------------------------------------------------------------------------------------------------
/// @name Persistent Store Management
/// ---------------------------------------------------------------------------------------------------------

/*!
 * Weak reference to the persistent store the current object is related to.
 */
@property (nonatomic, weak) PMSQLiteStore *persistentStore;

@end
