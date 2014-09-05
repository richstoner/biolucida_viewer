//
//  wsSystemObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsSystemObject.h"

@implementation wsSystemObject

@synthesize title, description;

-(NSString*) localizedName {
    return self.title;
}

-(NSString*) localizedDescription {
    return self.description;
}

@end
