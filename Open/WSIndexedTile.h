//
//  WSIndexedTiled.h
//  Open
//
//  Created by Rich Stoner on 11/17/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSGenericTiledImage.h"

@interface WSIndexedTile : WSGenericTiledImage

@property(nonatomic, strong) GLKTextureInfo* texture;

// provided
@property(nonatomic, assign, readwrite) int row;
@property(nonatomic, assign, readwrite) int col;
@property(nonatomic, assign, readwrite) int level;
@property(nonatomic, strong) NSURL* url;

//-(id) initWithZ:(int)z
//        withRow:(int)row
//        withCol:(int)col
//        fromURL:(NSURL*) url
//        andSize:(CGSize) originalSize;


-(void) updateMVMatrixWithViewMatrix:(GLKMatrix4) theViewMatrix;

-(void) drawThisTileWithEffect:(GLKBaseEffect*) theEffect;

-(void) drawWithEffect:(GLKBaseEffect*) theEffect;

-(void) loadTextureFromURLWithContext:(EAGLContext*) theContext;

@end

