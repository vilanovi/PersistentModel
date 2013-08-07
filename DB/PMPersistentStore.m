//
//  PMPersistentStore.m
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

#import "PMPersistentObject.h"

NSString * const PMPersistentStoreObjectKey = @"PMPersistentStoreObjectKey";

@implementation PMPersistentStore

- (id)initWithURL:(NSURL*)url
{
    if (self.class == [PMPersistentStore class])
    {
        NSString *reason = @"PMPersistentStore cannot be instanciated thus it's an abstract class. Try by instanciating PMSQliteStore or PMCoreDataStore.";
        NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
        [exception raise];
        return nil;
    }

    self = [super init];
    if (self)
    {
        _url = url;
    }
    return self;
}

- (id<PMPersistentObject>)persistentObjectWithKey:(NSString*)key
{
    // Subclasses must override.
    return nil;
}

- (NSArray*)persistentObjectsOfType:(NSString*)type
{
    // Subclasses must override.
    return nil;
}

- (id<PMPersistentObject>)createPersistentObjectWithKey:(NSString*)key ofType:(NSString*)type
{
    // Subclasses must override.
    return nil;
}

- (void)deletePersistentObjectWithKey:(NSString*)key
{
    // Subclasses must override.
}

- (BOOL)deleteEntriesOfType:(NSString*)type olderThan:(NSDate*)date policy:(PMOptionDelete)option
{
    // Subclasses must override.
    return NO;
}

- (BOOL)save
{
    // Subclasses must override.
    return NO;
}

@end
