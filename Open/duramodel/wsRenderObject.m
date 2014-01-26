//
//  wsRenderObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsRenderObject.h"

@interface wsRenderObject ()
{
    NSMutableData *wireFrameData;

}

@end

@implementation wsRenderObject

- (id)init
{
    self = [super init];
    if (self) {
        self.notificationString = kNotificationPresentObject;
        self.actions = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Internals

-(void) addAction:(wsActionObject*) newAction
{
    [self.actions addObject:newAction];
}

#pragma mark - Empty base methods - 



-(void) prepareWithContext:(EAGLContext*) theContext
{
    VerboseLog();
}

-(void) render
{
    VerboseLog();
}

-(void) renderSelect
{
//    VerboseLog();
}

-(void) renderWithTouch:(GLKVector3)selectedObject
{
    VerboseLog();
}

-(void) tearDownGL
{
    VerboseLog();
}

-(void) handleTouchForSelection:(GLKVector3) selectionVector withSource:(GLKVector2)sourceVector andDelta:(GLKVector2) deltaVector;
{
    VerboseLog();
}

-(void) renderWithHighlight
{
    VerboseLog();
}

#pragma mark - 3d methods

-(GLKMatrix4) modelMatrixWithPosition:(GLKVector3) position withRotation:(GLKVector3) rotation withScale:(GLKVector3)scale
{
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(rotation.x));
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(GLKMathDegreesToRadians(rotation.y));
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(GLKMathDegreesToRadians(rotation.z));
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(scale.x, scale.y, scale.z);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                
                                                                                xRotationMatrix))));
    return modelMatrix;
}

-(void) updateMVPMatrix:(GLKMatrix4) theViewMatrix
{
    self.parentMVPMatrix = theViewMatrix;
    
    GLKVector3 rotation = self.baseRotation;
    GLKVector3 position = self.basePosition;
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(rotation.x));
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(GLKMathDegreesToRadians(rotation.y));
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(GLKMathDegreesToRadians(rotation.z));
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(        self.baseScale.x,         self.baseScale.y,         self.baseScale.z);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                xRotationMatrix))));
    
    self.baseMVPMatrix = GLKMatrix4Multiply(theViewMatrix, modelMatrix);
}


#pragma mark - Bounding box methods

- (GLKVector3*)wireFrameCubeVertices {
    if (wireFrameData == nil)
        wireFrameData = [NSMutableData dataWithLength:sizeof(GLKVector3)*24];
    return [wireFrameData mutableBytes];
}


- (void) calculateBoundingBox
{
    // wireframe cube
    
    
    // bottom
    GLKVector3 v0 = GLKVector3Make(self.boundingBox.bbl.x, self.boundingBox.bbl.y, self.boundingBox.bbl.z);
    GLKVector3 v1 = GLKVector3Make(self.boundingBox.bbh.x, self.boundingBox.bbl.y, self.boundingBox.bbl.z);
    GLKVector3 v2 = GLKVector3Make(self.boundingBox.bbh.x, self.boundingBox.bbh.y, self.boundingBox.bbl.z);
    GLKVector3 v3 = GLKVector3Make(self.boundingBox.bbl.x, self.boundingBox.bbh.y, self.boundingBox.bbl.z);
    
    // top
    GLKVector3 v4 = GLKVector3Make(self.boundingBox.bbl.x, self.boundingBox.bbl.y, self.boundingBox.bbh.z);
    GLKVector3 v5 = GLKVector3Make(self.boundingBox.bbh.x, self.boundingBox.bbl.y,  self.boundingBox.bbh.z);
    GLKVector3 v6 = GLKVector3Make(self.boundingBox.bbh.x,  self.boundingBox.bbh.y,  self.boundingBox.bbh.z);
    GLKVector3 v7 = GLKVector3Make(self.boundingBox.bbl.x,  self.boundingBox.bbh.y,  self.boundingBox.bbh.z);
    
    // -z
    self.wireFrameCubeVertices[0] = v0;
    self.wireFrameCubeVertices[1] = v1;
    self.wireFrameCubeVertices[2] = v1;
    self.wireFrameCubeVertices[3] = v2;
    self.wireFrameCubeVertices[4] = v2;
    self.wireFrameCubeVertices[5] = v3;
    self.wireFrameCubeVertices[6] = v3;
    self.wireFrameCubeVertices[7] = v0;
    
    // opposite side (+z)
    self.wireFrameCubeVertices[8] = v4;
    self.wireFrameCubeVertices[9] = v5;
    self.wireFrameCubeVertices[10] = v5;
    self.wireFrameCubeVertices[11] = v6;
    self.wireFrameCubeVertices[12] = v6;
    self.wireFrameCubeVertices[13] = v7;
    self.wireFrameCubeVertices[14] = v7;
    self.wireFrameCubeVertices[15] = v4;
    
    // connecting the sides
    self.wireFrameCubeVertices[16] = v0;
    self.wireFrameCubeVertices[17] = v4;
    self.wireFrameCubeVertices[18] = v1;
    self.wireFrameCubeVertices[19] = v5;
    self.wireFrameCubeVertices[20] = v2;
    self.wireFrameCubeVertices[21] = v6;
    self.wireFrameCubeVertices[22] = v3;
    self.wireFrameCubeVertices[23] = v7;
}

-(void) renderBounds
{
    
    //    glEnable(GL_BLEND);
    //    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.wireFrameCubeVertices);
    
    
    self.effect.transform.modelviewMatrix = self.baseMVPMatrix;
    
    self.effect.light0.enabled = GL_FALSE;
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_LINES, 0, 24);
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.useConstantColor = GL_FALSE;
    
}

-(void) renderBoundsHighlight
{
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.wireFrameCubeVertices);
    
    
    self.effect.transform.modelviewMatrix = self.baseMVPMatrix;
    
    self.effect.light0.enabled = GL_FALSE;
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    glLineWidth(3.0);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_LINES, 0, 24);
    
    glLineWidth(1.0);
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.useConstantColor = GL_FALSE;
    
    
}





#pragma mark - Internals -

-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
//    NSDictionary* local_keymap = @{};
//    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}

@end
