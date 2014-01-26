//
//  wsTileObject.h
//  Open
//
//  Created by Rich Stoner on 1/17/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import <Foundation/Foundation.h>
@class wsImageObject;

@interface wsTileObject : NSObject

@property(nonatomic, readonly) GLKVector3 tl;
@property(nonatomic, readonly) GLKVector3 tr;
@property(nonatomic, readonly) GLKVector3 bl;
@property(nonatomic, readonly) GLKVector3 br;

@property(nonatomic, readonly) GLKVector3 centroid;
@property(nonatomic, readonly) GLKVector3 scaledSize;


@property(nonatomic, assign) BOOL shouldDraw;


- (id)initWithParentImage:(wsImageObject*) theImageObject;

-(void) renderWithEffect:(GLKBaseEffect*) theEffect;

-(void) updateTextureWithImage:(UIImage*) image;

-(BOOL) updateMVmatrix:(GLKMatrix4) theMatrix;

-(void) updateIndex:(GLKVector3) newIndex;

@end
