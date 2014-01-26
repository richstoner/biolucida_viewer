//
//  wsRemoteImageObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsImageObject.h"

@interface wsRemoteImageObject : wsImageObject

/**
 A base URl for the image content. The child class will determine how this gets accessed. It can point to a remote resource or local path.
 */
@property (strong, nonatomic) NSURL* url;


/**
 A URL that provides the small thumbnail
 */
@property(nonatomic, readonly) NSURL* thumbnailURL;

/**
 A URL that provides a valid aspect ratio thumbnail used for as the background in a tiled view
 */
@property(nonatomic, readonly) NSURL* backgroundURL;


@end
