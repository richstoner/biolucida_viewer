//
//  wsRemoteImageObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsRemoteImageObject.h"

@implementation wsRemoteImageObject

- (id)init
{
    self = [super init];
    if (self) {
        
        
        
    }
    return self;
}

-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
    NSDictionary* local_keymap = @{
                                   @"url" :        @[@"url", @"url"],
                                   };
    
    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}


@end
