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





//
//#pragma mark - Mantle methods
//
////+ (NSDateFormatter *)dateFormatter {
////    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
////    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
////    return dateFormatter;
////}
//
//// by the way, creating NSDateFormatters is expensive.  So we create a static instance...
//
//
//
//+ (NSDictionary *)JSONKeyPathsByPropertyKey {
//    return @{
//             @"notificationString": @"notification",
//             @"versionString": @"version",
//             @"createDate": @"create_date",
//             @"modifyDate": @"modify_date",
//             @"localizedName": NSNull.null,
//             @"localizedDescription": NSNull.null
//             };
//}
//
////+ (NSValueTransformer *)URLJSONTransformer {
////    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
////}
////
////+ (NSValueTransformer *)HTMLURLJSONTransformer {
////    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
////}
//
////
////+ (NSValueTransformer *)stateJSONTransformer {
////    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
////                                                                           @"open": @(GHIssueStateOpen),
////                                                                           @"closed": @(GHIssueStateClosed)
////                                                                           }];
////}
//
////+ (NSValueTransformer *)assigneeJSONTransformer {
////    return [NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:GHUser.class];
////}
//
//+ (NSValueTransformer *)createDateJSONTransformer {
//    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
//        return [self.dateFormatter dateFromString:str];
//    } reverseBlock:^(NSDate *date) {
//        return [self.dateFormatter stringFromDate:date];
//    }];
//}
//
//+ (NSValueTransformer *)modifyDateJSONTransformer {
//    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
//        return [self.dateFormatter dateFromString:str];
//    } reverseBlock:^(NSDate *date) {
//        return [self.dateFormatter stringFromDate:date];
//    }];
//}


@end
