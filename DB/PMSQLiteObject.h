//
//  PMSQLiteObject.h
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import <Foundation/Foundation.h>
#import "PMPersistentObject.h"

@class PMSQLiteStore;

@interface PMSQLiteObject : NSObject <PMPersistentObject>

- (id)initWithDataBaseIdentifier:(NSInteger)dbID;
- (id)initWithKey:(NSString*)key andType:(NSString*)type;

@property (nonatomic, assign) NSInteger dbID;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDate *lastUpdate;
@property (nonatomic, strong) NSData *data;

@property (nonatomic, assign, readonly) BOOL hasChanges;

@property (nonatomic, weak) PMSQLiteStore *persistentStore;

@end
