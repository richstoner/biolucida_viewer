//
//  wsImageObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsRenderObject.h"

@class wsTileObject;

@interface wsImageObject : wsRenderObject


/**
 The native image size in pixels (this makes the assumption that the image contains 1 pixel of Z dimension)
 */
@property(nonatomic, assign) CGSize nativeSize;

/**
 the maximum tile dimension when request this image from a remote source. If == 0,0, assume no tiling present.
 */
@property(nonatomic, assign) CGSize tileSize;



/**
 A reasonably short title string to identify the image
 */
@property (strong, nonatomic) NSString* title;

/**
 A reasonbly short description to describe the image
 */
@property (strong, nonatomic) NSString* description;



/**
 The maximum zoom level in the a pyramid representation (zero indexed)
 */
@property(nonatomic, readonly) int maximumZoom;


@property (strong) GLKTextureLoader *asyncTextureLoader;


#pragma mark - necessary methods for rendering


-(NSURL*) getTileURLforIndex:(GLKVector3) theIndex;

-(void) drawInRect:(CGRect) tileRect forScale:(CGFloat) scale row:(int)row col:(int) col;

-(GLKVector3) maximumBoundsForZoom:(int)zoom;

-(CGFloat) smallestTexelInTile:(wsTileObject*) theTile;

-(BOOL) hasCachedTileForIndex:(GLKVector3) theIndex;

-(void) downloadTileForIndex:(GLKVector3) theIndex;

-(NSString*) localPathForTileWithIndex:(GLKVector3) theIndex;


-(void) registerNotifications;

-(void) unregisterNotifications;

@end
