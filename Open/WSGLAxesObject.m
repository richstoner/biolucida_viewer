//
//  WSGLAxesObject.m
//  Open
//
//  Created by Rich Stoner on 12/6/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSGLAxesObject.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

struct vertexData
{
	GLKVector3		vertex;
	GLKVector3		normal;
};
typedef struct vertexData vertexData;
typedef vertexData* vertexDataPtr;



GLfloat gCubeVertexData[216] =
{
    //x      y         z               nx     ny     nz
    1.0f, -1.0f, -1.0f,         1.0f,  0.0f,  0.0f,
    1.0f,  1.0f, -1.0f,         1.0f,  0.0f,  0.0f,
    1.0f, -1.0f,  1.0f,         1.0f,  0.0f,  0.0f,
    1.0f, -1.0f,  1.0f,         1.0f,  0.0f,  0.0f,
    1.0f,  1.0f,  1.0f,         1.0f,  0.0f,  0.0f,
    1.0f,  1.0f, -1.0f,         1.0f,  0.0f,  0.0f,
    
    1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,
    -1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,
    1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,
    1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,
    -1.0f,  1.0f, -1.0f,         0.0f,  1.0f,  0.0f,
    -1.0f,  1.0f,  1.0f,         0.0f,  1.0f,  0.0f,
    
    -1.0f,  1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f, -1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f,  1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f,  1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f, -1.0f, -1.0f,        -1.0f,  0.0f,  0.0f,
    -1.0f, -1.0f,  1.0f,        -1.0f,  0.0f,  0.0f,
    
    -1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,
    1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,
    -1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,
    -1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,
    1.0f, -1.0f, -1.0f,         0.0f, -1.0f,  0.0f,
    1.0f, -1.0f,  1.0f,         0.0f, -1.0f,  0.0f,
    
    1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    -1.0f,  1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    -1.0f, -1.0f,  1.0f,         0.0f,  0.0f,  1.0f,
    
    1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,         0.0f,  0.0f, -1.0f,
    -1.0f,  1.0f, -1.0f,         0.0f,  0.0f, -1.0f
};

@interface WSGLAxesObject ()
{
    GLuint axesVertexBuffer;
}

@property (strong, nonatomic)   EAGLContext *context;
@property (strong, nonatomic)   GLKBaseEffect *effect;

@property (nonatomic, assign) GLKMatrix4 parentMVPMatrix;
@property (nonatomic, assign) GLKMatrix4 baseMVPMatrix;
@property (nonatomic, assign) GLKMatrix4 mvpX;
@property (nonatomic, assign) GLKMatrix4 mvpY;
@property (nonatomic, assign) GLKMatrix4 mvpZ;

@property(nonatomic, assign) GLKVector3 basePosition;
@property(nonatomic, assign) GLKVector3 baseScale;
@property(nonatomic, assign) GLKVector3 baseRotation;


@end

@implementation WSGLAxesObject

@synthesize context = _context;
@synthesize effect  = _effect;


- (id)init
{
    self = [super init];
    if (self) {
        
        self.basePosition = GLKVector3Make(1,1,1);
        self.baseRotation = GLKVector3Make(0, 0, 0);
        self.baseScale = GLKVector3Make(0.1, 0.10, 0.10);
        
    }
    return self;
}



- (void) prepareWithContext:(EAGLContext*) theContext
{
    VerboseLog();
    
    [self setContext:theContext];
    
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [GLKBaseEffect new];
    self.effect.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    
//    self.effect.light0.enabled  = GL_TRUE;
    
//    GLfloat ambientColor        = 1.0f;
//    GLfloat alpha               = 1.0f;
//    
//    self.effect.light0.ambientColor = GLKVector4Make(ambientColor, ambientColor, ambientColor, alpha);
//    
//    GLfloat diffuseColor        = 1.0f;
//    
//    self.effect.light0.diffuseColor = GLKVector4Make(diffuseColor, diffuseColor, diffuseColor, alpha);
//    
//    // Spotlight
//    GLfloat specularColor       = 0.3f;
//    
//    self.effect.light0.specularColor    = GLKVector4Make(0.0, 0.0f, specularColor, alpha);
//    self.effect.light0.position         = GLKVector4Make(5.0f, 10.0f, 10.0f, 0.0);
//    self.effect.light0.spotDirection    = GLKVector3Make(0.0f, 0.0f, -1.0f);
//    self.effect.light0.spotCutoff       = 20.0; // 40° spread total.
//    
//    self.effect.lightingType = GLKLightingTypePerPixel;
    
    [self allocateAxesBuffers];
}

- (void) allocateAxesBuffers
{
    VerboseLog();
    
    glGenBuffers(1, &axesVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    // Vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, vertex)); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, normal)); // for model,
    
    
    // need to unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    
}

- (void)tearDownGL
{
    
    glDeleteBuffers(1, &axesVertexBuffer);

    self.effect = nil;
}


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

-(void) updateMVPMatrix:(GLKMatrix4)theViewMatrix
{
    
    self.parentMVPMatrix = theViewMatrix;
    
    GLKVector3 rotation = GLKVector3Make(0.0, 0, 0.0);
    GLKVector3 position = GLKVector3Make(0.0, 0.0, 0.0);
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
    
    
    self.mvpX = GLKMatrix4Multiply(self.baseMVPMatrix, [self modelMatrixWithPosition:GLKVector3Make(4.0, 0.0, 0.0)
                                                                                withRotation:GLKVector3Make(0,0,0 )
                                                                                   withScale:GLKVector3Make(5.0,0.1,0.1) ]);
    
    self.mvpY = GLKMatrix4Multiply(self.baseMVPMatrix, [self modelMatrixWithPosition:GLKVector3Make(0.0, 4, 0.0)
                                                                                  withRotation:GLKVector3Make(0, 0, 0)
                                                                                     withScale:GLKVector3Make(0.1, 5.0, 0.1) ]);
    
    
    
    self.mvpZ = GLKMatrix4Multiply(self.baseMVPMatrix, [self modelMatrixWithPosition:GLKVector3Make(0.0, 0.0, 4)
                                                                                  withRotation:GLKVector3Make(0, 0, 0)
                                                                                     withScale:GLKVector3Make(0.1,0.1,5.0) ]);
    
    
    
    
}


-(void) drawX
{
    self.effect.transform.modelviewMatrix = self.mvpX;

    self.effect.constantColor = GLKVector4Make(1.0, 0.0, 0.0, 1.0);
    self.effect.useConstantColor = YES;

    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

-(void) drawY
{
    self.effect.transform.modelviewMatrix = self.mvpY;
    
    self.effect.constantColor = GLKVector4Make(0.0, 1.0, 0.0, 1.0);
    self.effect.useConstantColor = YES;
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    self.effect.useConstantColor = NO;
}


-(void) drawZ
{
    self.effect.transform.modelviewMatrix = self.mvpZ;

    self.effect.constantColor = GLKVector4Make(0.0, 0.0, 1.0, 1.0);
    self.effect.useConstantColor = YES;
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    
}

-(void) render
{
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//
//    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
//    
//    // Vertices
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, vertex)); // for model, normals, and texture
//    
//    // Normals
//    glEnableVertexAttribArray(GLKVertexAttribNormal);
//    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, normal)); // for model,
//    
//    self.effect.transform.projectionMatrix = self.parentProjectionMatrix;
//    
//    [self drawX];
//    [self drawY];
//    [self drawZ];
//    
//    glDisableVertexAttribArray(GLKVertexAttribPosition);
//    glDisable(GL_BLEND);
//
//    glBindBuffer(GL_ARRAY_BUFFER, 0);

}

-(void) renderWithTouch:(GLKVector3)selectedObject
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
    
    // Vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, vertex)); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, normal)); // for model,
    
    self.effect.transform.projectionMatrix = self.parentProjectionMatrix;
    
    [self drawX];
    [self drawY];
    [self drawZ];
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisable(GL_BLEND);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    
}



@end
