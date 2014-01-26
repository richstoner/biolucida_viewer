//
//  wsBoundingBox.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

@interface wsBounds : NSObject


/**
 The maximum corner in world coordinates for the bounding box
 */
@property(nonatomic, assign) GLKVector3 bbh;

/**
 The minimum corner in world coordinates
 */
@property(nonatomic, assign) GLKVector3 bbl;


@property(nonatomic, readonly) GLKVector3 bb_center;

/**
 Creates a 3D bounding box from 2d plane, centered at 0,0,0
 */
+ (id) createBoundsForSize:(CGSize) theSize;

/**
 Creates a 3D bounding box from 2d plane, centered at specified origin
 */
+ (id) createBoundsForSize:(CGSize) theSize withOrigin:(GLKVector3) theOrigin;

/**
 Creates a 3D bounding box from 3d bound, centered at specified origin
 */
+ (id) createBoundsForVec3:(GLKVector3) theVecSize withOrigin:(GLKVector3) theOrigin;




@end
