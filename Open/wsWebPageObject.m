//
//  wsWebPageObject.m
//  Open
//
//  Created by Rich Stoner on 1/20/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsWebPageObject.h"

@implementation wsWebPageObject

- (id)init
{
    self = [super init];
    if (self) {

        self.notificationString = kNotificationPresentObject;

    }
    return self;
}

-(NSString*) localizedName {
    return self.title;
}

-(NSString*)localizedDescription {
    if (self.description.length > 0) {
        return self.description;
    }
    
    return self.url.absoluteString;
}

-(NSURL*) url {
    
    
    // try to return the server-based url first
    if (self.server != nil) {
        
        return [self.server.url URLByAppendingPathComponent:self.basePath];
        
    }
    
    // then fail to a fully defined URL
    else if (self.fullURL)
    {
        return self.fullURL;
    }

    return nil;

    
}


@end
