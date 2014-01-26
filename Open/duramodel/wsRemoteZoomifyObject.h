//
//  wsRemoteZoomifyObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsRemoteImageObject.h"

@interface wsRemoteZoomifyObject : wsRemoteImageObject

@property (nonatomic, strong) NSURL* thumbnail_base;

-(UIImage*) getImageForZoom:(int)z row:(int)row col:(int)col;

//-(NSURL*) getImageURLForZoom:(int)z row:(int)row col:(int)col;


@end
