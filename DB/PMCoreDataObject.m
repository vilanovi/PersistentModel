//
//  PMCoreDataObject.m
//  Created by Joan Martin.
//  Take a look to my repos at http://github.com/vilanovi
//

#import "PMCoreDataObject.h"

@implementation PMCoreDataObject

@dynamic key;
@dynamic data;
@dynamic lastUpdate;
@dynamic type;

- (NSString*)description
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    }
    
    return [NSString stringWithFormat:@"%@ : <key:%@> <type:%@> <lastUpdate:%@>",[super description], self.key, self.type, [dateFormatter stringFromDate:self.lastUpdate]];
}

@end
