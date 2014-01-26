//
//  wsRenderObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//



@protocol wsRenderObjectDelegate;

@interface wsRenderObject : wsDataObject
{

    
}

/**
 A unique layer ID that can be used during selection to identify which object in 3space belongs to which layer
 */
@property (nonatomic, assign) uint8_t layerID;

/**
 The bounding box that defines the extents of the image, in world coordinates
 */
@property (nonatomic, strong) wsBounds* boundingBox;

/**
 An array of wsActionObjects that this object supports
 */
@property(nonatomic, strong) NSMutableArray* actions;

/**
 Trigger any changes if the collection has updated information
 */
@property (nonatomic, weak) id<wsRenderObjectDelegate> delegate;

/**
 The parent PM, used for rendering in 3D
 */
@property (nonatomic, assign) GLKMatrix4 parentProjectionMatrix;


/**
 The GL ES2 contenxt
 */
@property (strong, nonatomic)   EAGLContext *context;

/**
 THe shared GLKit effect (lighting)
 */
@property (strong, nonatomic)   GLKBaseEffect *effect;

/**
 The parent matrix set by the camera
 */
@property (nonatomic, assign) GLKMatrix4 parentMVPMatrix;

/**
 The base transform from base position, scale, and rotation
 */
@property (nonatomic, assign) GLKMatrix4 baseMVPMatrix;

/**

 */
@property(nonatomic, assign) GLKVector3 basePosition;

/**

 */
@property(nonatomic, assign) GLKVector3 baseScale;

/**

 */
@property(nonatomic, assign) GLKVector3 baseRotation;





#pragma mark - bounding box

@property(readonly) GLKVector3* wireFrameCubeVertices;

- (void) calculateBoundingBox;

- (void) renderBounds;

- (void) renderBoundsHighlight;


@property (nonatomic, assign) BOOL shouldHide;



-(void) addAction:(wsActionObject*) newAction;



-(void) updateMVPMatrix:(GLKMatrix4) theViewMatrix;

-(void) prepareWithContext:(EAGLContext*) theContext;

-(void) render;

-(void) renderSelect;

-(void) renderWithHighlight;

-(void) renderWithTouch:(GLKVector3)selectedObject;

-(void) handleTouchForSelection:(GLKVector3) selectionVector withSource:(GLKVector2)sourceVector andDelta:(GLKVector2) deltaVector;

-(void) tearDownGL;

-(GLKMatrix4) modelMatrixWithPosition:(GLKVector3) position withRotation:(GLKVector3) rotation withScale:(GLKVector3)scale;



@end







@protocol wsRenderObjectDelegate <NSObject>

-(void) renderObjectHasData:(wsRenderObject*) renderObject;

-(void) renderObjectSelectionChanged:(wsRenderObject*) renderObject;

-(void) renderObjectHasNewData:(wsRenderObject*) renderObject;



//-(void) collectionObjectHasNewData:(wsCollectionObject*) collectionObject;
//
//-(void) collectionObjectFailedToLoad:(wsCollectionObject*) collectionObject;

@end