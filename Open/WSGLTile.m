//////////////////////////////////////////////////////////////////////////////////////
//
//    This software is Copyright © 2013 WholeSlide, Inc. All Rights Reserved.
//
//    Permission to copy, modify, and distribute this software and its documentation
//    for educational, research and non-profit purposes, without fee, and without a
//    written agreement is hereby granted, provided that the above copyright notice,
//    this paragraph and the following three paragraphs appear in all copies.
//
//    Permission to make commercial use of this software may be obtained by contacting:
//
//    Rich Stoner, WholeSlide, Inc
//    8070 La Jolla Shores Dr, #410
//    La Jolla, CA 92037
//    stoner@wholeslide.com
//
//    This software program and documentation are copyrighted by WholeSlide, Inc. The
//    software program and documentation are supplied "as is", without any
//    accompanying services from WholeSlide, Inc. WholeSlide, Inc does not warrant
//    that the operation of the program will be uninterrupted or error-free. The
//    end-user understands that the program was developed for research purposes and is
//    advised not to rely exclusively on the program for any reason.
//
//    IN NO EVENT SHALL WHOLESLIDE, INC BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
//    SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
//    OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WHOLESLIDE,INC
//    HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. WHOLESLIDE,INCSPECIFICALLY
//    DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
//    HEREUNDER IS ON AN "AS IS" BASIS, AND WHOLESLIDE,INC HAS NO OBLIGATIONS TO
//    PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS UNLESS
//    OTHERWISE STATED.
//
//////////////////////////////////////////////////////////////////////////////////////
//
//  WSGLTile.m
//  Open
//
//  Created by Rich Stoner on 11/14/13.
//

#import "WSGLTile.h"

@interface WSGLTile ()
{
    
    
}

@property(nonatomic, assign, readwrite) GLKVector3 nextPotSize;
@property(nonatomic, assign, readwrite) GLKVector2 sizeInGlCoords;


@property(nonatomic, assign, readwrite) GLKVector3 e; // x,y
@property(nonatomic, assign, readwrite) GLKVector3 eMax; // max x y

@property(nonatomic, strong) NSString* slideID;
@property(nonatomic, strong) NSURL* url;

@property(nonatomic, strong) NSMutableArray* children;

@property(nonatomic, assign, readwrite) BOOL textureIsBound;

@property (strong) GLKTextureLoader *asyncTextureLoader;

@property (nonatomic, assign) GLKVector3 rotation;
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 scale;
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;


@end

@implementation WSGLTile


- (id)init
{
    self = [super init];
    if (self) {
        
        self.rotation = GLKVector3Make(- M_PI_2, 0, 0);
        self.position = GLKVector3Make(-1.0, 0.0, 0.0);
        
        self.scale = GLKVector3Make(1.0, 1.0, 1.0);
        self.modelViewMatrix = GLKMatrix4Identity;
        
    }
    return self;
}



//http://stackoverflow.com/questions/364985/algorithm-for-finding-the-smallest-power-of-two-thats-greater-or-equal-to-a-giv

-(int) pow2roundup:(int) x
{
    if (x < 0)
        return 0;
    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;
    return x+1;
}



- (void) prepareTileWithContext:(EAGLContext*) theContext
{
    
    // run the computations needed
    
    int npot_w = [self pow2roundup:self.nativeSize.width];
    int npot_h = [self pow2roundup:self.nativeSize.height];
    
    int max_dim_pot = MAX(npot_h, npot_w);
    NSLog(@"next pot %d %d -> %d", npot_w, npot_h, max_dim_pot);
    
    self.nextPotSize = GLKVector3Make(max_dim_pot, max_dim_pot, 1);
    float aspect_ratio = self.nativeSize.width / self.nativeSize.height;
    if (aspect_ratio <= 1) {
        self.scale = GLKVector3Make(1.0, 10.0, 10.0 / aspect_ratio);
    }
    else{
        
        //wider than tall
        self.scale = GLKVector3Make(1.0, 10.0 / aspect_ratio, 10.0);
    }
    
    self.sizeInGlCoords = GLKVector2Make(self.scale.z, self.scale.x);

    NSLog(@"In gl space: %f x %f", self.sizeInGlCoords.x, self.sizeInGlCoords.y);
    
    int max_levels = (int)log2((double)max_dim_pot) - log2(256);
    
    NSLog(@"%d levels", max_levels);
    
//    for (int i=0; i<=max_levels; i++) {
    
    int eI = ceil(self.nativeSize.width / (256 * pow(2.0,  max_levels - self.level )));
    int eJ = ceil(self.nativeSize.height/ (256 * pow(2.0,  max_levels - self.level )));
    
    int nextEI = ceil(self.nativeSize.width / (256 * pow(2.0,  max_levels - self.level -1  )));
    int nextEJ = ceil(self.nativeSize.height/ (256 * pow(2.0,  max_levels - self.level -1  )));
    
    NSLog(@"at %d, there are %d x %d indices", self.level, eI, eJ);
    NSLog(@"at %d, there are %d x %d indices", self.level+1, nextEI, nextEJ);
    
    for (int i =0;i < nextEI; i++) {
        for (int j=0; j<nextEJ; j++) {
            
//            WSGLTile* tile = [WSGLTile new];
            
//            tile.nativeSize = theImage.nativeSize;
//            tile.tileSize = theImage.tileSize;
//            tile.baseURL = theImage.baseURL;
//            tile.level = 0;
//            tile.baseView = self.view;
            
            
        }
    }
    
//    }
    
    
    
    
    
    // set context 
    
    [self setContext:theContext];
    
    self.asyncTextureLoader = [[GLKTextureLoader alloc] initWithSharegroup:theContext.sharegroup];

    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@YES};
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    void (^complete)(GLKTextureInfo*, NSError*) = ^(GLKTextureInfo *texture,
                                                    NSError *e){
        if(e){
            // give up
            return;
        }
        // run our actual completion code on the main queue
        // so the glDeleteTextures call works
        dispatch_sync(dispatch_get_main_queue(), ^{
            // delete texture
            GLuint name = self.texture.name;
            glDeleteTextures(1, &name);
            // assign loaded texture
            self.texture = texture;
            
            NSLog(@"Texture loaded, name: %d, WxH: %d x %d",
                  self.texture.name,
                  self.texture.width,
                  self.texture.height);


        });
    };
    // load texture in queue and pass in completion block
//    [self.asyncTextureLoader textureWithContentsOf:@"my_texture_path.png"
//                                               options:options
//                                                 queue:queue
//                                     completionHandler:complete];
    
//    NSLog(@"%@", [self.baseURL URLByAppendingPathComponent:@"TileGroup0/0-0-0.jpg"]);
    
    [self.asyncTextureLoader textureWithContentsOfURL:[self.baseURL URLByAppendingPathComponent:@"TileGroup0/0-0-0.jpg"]
                                              options:options
                                                queue:queue
                                    completionHandler:complete];
    
    
    
}

- (void) updateMVMatrixWithViewMatrix:(GLKMatrix4) theViewMatrix
{
//    VerboseLog();
    
//        GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
//        GLKVector3 position = GLKVector3Make(0.0, 0.0, 0.0);
        GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(self.rotation.x);
        GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(self.rotation.y);
        GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(self.rotation.z);
        GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(self.scale.x,self.scale.y,self.scale.z);
        GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z);
        GLKMatrix4 modelMatrix =
        GLKMatrix4Multiply(translateMatrix,
                           GLKMatrix4Multiply(scaleMatrix,
                                              GLKMatrix4Multiply(zRotationMatrix,
                                                                 GLKMatrix4Multiply(yRotationMatrix,
                                                                                    xRotationMatrix))));
    
    self.modelViewMatrix = GLKMatrix4Multiply(theViewMatrix, modelMatrix);
    
}


//- (float) projectedTexelMinimum
//{
////    glGetFloatv(<#GLenum pname#>, <#GLfloat *params#>)
//    
//    
//}

- (void) drawWithEffect:(GLKBaseEffect*) theEffect
{
    
    // determine if this tile should draw
    
//    float projected_texel =
  
    [self drawThisTileWithEffect:theEffect];

//    if (self.texture != nil)
//    {
//        theEffect.transform.modelviewMatrix = self.modelViewMatrix;
//        theEffect.texture2d0.name = self.texture.name;
//        theEffect.texture2d0.enabled = GL_TRUE;
//        theEffect.texture2d0.envMode = GLKTextureEnvModeReplace;
//        theEffect.texture2d0.target = GLKTextureTarget2D;
//        
//        [theEffect prepareToDraw];
//        
//        glDrawArrays(GL_TRIANGLES, 0, 6);
//        
////        NSLog(@"texture not nil");
//        
////        if (self.textureIsBound) {
//        
//
////        }
////        else {
//            
////            glBindTexture(GL_TEXTURE_2D, self.texture.name);
//            
////            self.textureIsBound = YES;
//        
//            // bind texture, draw next time
//            
////        }
//    }
}

-(void) drawThisTileWithEffect:(GLKBaseEffect*) theEffect
{
    if (self.texture != nil)
    {
        theEffect.transform.modelviewMatrix = self.modelViewMatrix;
        theEffect.texture2d0.name = self.texture.name;
        theEffect.texture2d0.enabled = GL_TRUE;
//        theEffect.texture2d0.envMode = GLKTextureEnvModeReplace;
//        theEffect.texture2d0.target = GLKTextureTarget2D;
        
        [theEffect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
}

- (void) drawBackground:(GLKBaseEffect*) theEffect
{
    
    theEffect.transform.modelviewMatrix = self.modelViewMatrix;
    
//    theEffect.texture2d0.name = self.texture.name;
    theEffect.texture2d0.enabled = GL_FALSE;
//    theEffect.texture2d0.envMode = GLKTextureEnvModeReplace;
//    theEffect.texture2d0.target = GLKTextureTarget2D;
    
    [theEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
}








@end
