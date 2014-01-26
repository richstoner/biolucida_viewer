//
//  wsCollectionPath.m
//  Open
//
//  Created by Rich Stoner on 12/31/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsCollectionPath.h"

@implementation wsCollectionPath

- (BOOL)isEqual:(id)other
{
    if ([other isMemberOfClass:[self class]])
    {
        wsCollectionPath* o = (wsCollectionPath*)other;
        if (o.section == self.section && o.row == self.row ) {
            return YES;
        }
    }
    
 return NO;
 }
         
// - (NSUInteger)hash {
//     return [self identifier];
// }


//-(NSUInteger) identifier
//{
//    NSUInteger i = 1000*self.section + self.row;
//    return i;
//}

@end
