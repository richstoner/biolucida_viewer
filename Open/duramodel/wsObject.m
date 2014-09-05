//
//  wsObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsObject.h"

@implementation wsObject

- (id)init
{
    self = [super init];
    if (self) {
//        VerboseLog();
        
        self.createDate = [NSDate date];
        self.modifyDate = [NSDate date];
        
    }
    return self;
}


- (BOOL) hasLocalMetadata {
    
    // if metadata path is present
    // and a file exists at that path
    
    if (self.metadataPath == nil) {
        return NO;
    }
    
    NSFileManager* fm = [NSFileManager defaultManager];
    
    return [fm fileExistsAtPath:self.metadataPath.path];
}


/**
 
 */
-(NSDictionary*) keyMap {
    
    NSDictionary* km = @{
                         @"databaseID": @[@"id", @"object"],                         
                         @"notificationString": @[@"notifcation", @"object"],
                         @"versionString": @[@"version_string", @"object"],
                         @"createDate" : @[@"create_date", @"date"],
                         @"modifyDate" : @[@"modify_date", @"date"],
                         @"children" : @[@"children", @"array"]
                         };
    return km;
}


@end
