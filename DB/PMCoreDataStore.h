//
//  DMPersistentStore.h
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

#import "PMPersistentStore.h"

/*!
 * CoreData storage type.
 */
typedef enum __PMCoreDataStoreType
{
    /*!
     * Use SQLite within CoreData.
     */
    PMCoreDataStoreTypeSQLite,
    
    /*!
     * Use binary storage within CoreData.
     */
    PMCoreDataStoreTypeBinary
} PMCoreDataStoreType;

/*!
 * CoreData implementation for the PMPersistentStore.
 */
@interface PMCoreDataStore : PMPersistentStore

/// ---------------------------------------------------------------------------------------------------------
/// @name Creating instances and initializing
/// ---------------------------------------------------------------------------------------------------------
/*!
 * Default initializer.
 * @param url The url of the persistent store.
 * @param type The selected PMCoreDataStoreType. 
 * @return The initialized instance.
 */
- (id)initWithURL:(NSURL *)url storeType:(PMCoreDataStoreType)type;

/// ---------------------------------------------------------------------------------------------------------
/// @name Main attributes
/// ---------------------------------------------------------------------------------------------------------

/*!
 * The current store type.
 */
@property (nonatomic, assign, readonly) PMCoreDataStoreType storeType;

@end
