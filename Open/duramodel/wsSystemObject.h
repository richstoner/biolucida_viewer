//
//  wsSystemObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsDataObject.h"

@interface wsSystemObject : wsDataObject

/**
 A short name to represent the object or action
 */
@property(nonatomic, strong) NSString* title;

/**
 A short description
 */

@property(nonatomic, strong) NSString* description;


@end
