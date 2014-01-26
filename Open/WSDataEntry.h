//
//  WSDataEntry.h
//  Open
//
//  Created by Rich Stoner on 10/29/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSDataObject.h"

@interface WSDataEntry : NSObject

@property (strong, nonatomic) WSDataObject* data;
@property (strong, nonatomic) NSArray *children;

@end
