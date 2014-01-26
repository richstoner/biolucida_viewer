//
//  wsBoundingBox.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//


#import "wsBounds.h"

@implementation wsBounds

-(GLKVector3) bb_center
{
  return GLKVector3DivideScalar(GLKVector3Add(self.bbh, self.bbl), 2);
}

+ (id) createBoundsForSize:(CGSize) theSize
{
    return [wsBounds createBoundsForSize:theSize withOrigin:GLKVector3Make(0, 0, 0)];
}

+ (id) createBoundsForSize:(CGSize) theSize withOrigin:(GLKVector3) theOrigin
{
    return [wsBounds createBoundsForVec3:GLKVector3Make(theSize.width, theSize.height, 0) withOrigin:theOrigin];
}

+ (id) createBoundsForVec3:(GLKVector3) theSize withOrigin:(GLKVector3) theOrigin
{
    wsBounds* box = [wsBounds new];
    
    box.bbl = GLKVector3Make(-theSize.x/2 + theOrigin.x, -theSize.x/2 + theOrigin.y, -theSize.z/2 +  theOrigin.z);
    
    box.bbh = GLKVector3Make( theSize.x/2 + theOrigin.x,  theSize.x/2 + theOrigin.y, theSize.z/2 + theOrigin.z);
    
    return box;
}

@end
