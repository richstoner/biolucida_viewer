//
//  wsDataObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "wsObject.h"

@interface wsDataObject : wsObject

/**
 An icon to represent the object
 */
@property(nonatomic, strong) NSString* fontAwesomeIconString;

/**
 A local png file used to represent this object
 */
@property(nonatomic, strong) NSString* localIconString;


@end


