//
//  wsServerObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsServerObject.h"

@implementation wsServerObject

@synthesize title, description;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (NSString*) localizedName
{
    return self.title;
}


- (NSString*) localizedDescription
{
    return self.url.absoluteString;
}


#pragma mark - internals


-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];

    NSDictionary* local_keymap = @{
        @"title" :      @[ @"title", @"object"],
        @"url" :        @[@"url", @"url"],
        @"username" :   @[@"username", @"object"],
        @"password" :   @[@"password", @"object"]
    };
    
    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}

@end
