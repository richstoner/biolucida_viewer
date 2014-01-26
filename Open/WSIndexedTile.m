//
//  WSIndexedTiled.m
//  Open
//
//  Created by Rich Stoner on 11/17/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSIndexedTile.h"

@interface WSIndexedTile ()

// calculate
@property(nonatomic, assign, readwrite) GLKVector2 relativeSize; // relative percentage of original size
@property(nonatomic, assign, readwrite) GLKVector2 powerOfTwoSize;
@property(nonatomic, assign, readwrite) GLKVector2 translation;

@property (nonatomic, assign) GLKVector3 rotation;
@property (nonatomic, assign) GLKVector3 tileOrigin;
@property (nonatomic, assign) GLKVector3 position;
@property (nonatomic, assign) GLKVector3 scale;
@property (nonatomic, assign) GLKMatrix4 modelViewMatrix;

@property(nonatomic, strong) NSMutableArray* children;

// utility
@property (strong) GLKTextureLoader *asyncTextureLoader;



@end

@implementation WSIndexedTile



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


//
//-(id) initWithZ:(int)z
//        withRow:(int)row
//        withCol:(int)col
//        fromURL:(NSURL*)url
//        andSize:(CGSize)originalSize
//{
//    self = [super init];
//    if (self) {
//        
//        // set some logical base params
//        
//        self.rotation = GLKVector3Make(- M_PI_2, 0, 0);
//        self.position = GLKVector3Make(-1.0, 0.0, 0.0);
//        
//        self.scale = GLKVector3Make(1.0, 1.0, 1.0);
//        self.modelViewMatrix = GLKMatrix4Identity;
//        
//        // when I'm initialized, do the following
//        
//        
//        // a figure out where I am based on index
//        
//        
//        self.nativeSize = originalSize;
//        self.tileSize = CGSizeMake(256, 256);
//        self.row = row;
//        self.col = col;
//        self.level = z;
////        self.maximumZoom =
//        self.baseURL = url;
//        
//        
//        int npot_w = [self pow2roundup:self.nativeSize.width];
//        int npot_h = [self pow2roundup:self.nativeSize.height];
//        
//        int max_dim_pot = MAX(npot_h, npot_w);
//        
//        NSLog(@"next pot %d %d -> %d, %d", npot_w, npot_h, max_dim_pot, self.level);
//        
//        self.powerOfTwoSize = GLKVector2Make(max_dim_pot, max_dim_pot);
//        
//        //    self.nextPotSize = GLKVector3Make(max_dim_pot, max_dim_pot, 1);
//        
//        float aspect_ratio = self.nativeSize.width / self.nativeSize.height;
//        
//        self.maximumZoom = (int)log2((double)max_dim_pot) - log2(256);
//        
//
//        
//        [self determineRelativeLocation];
//
//        
//        
//        // b figure out how big I should be
//        
//        // c figure out my url (calculate tilegroup)
//        
//        // create my children
//        
//        
//        
//        
//        
//        
//    }
//    return self;
//}

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




-(void) loadTextureFromURLWithContext:(EAGLContext*) theContext
{
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

    int tileGroup = [self tileGroupForZoom:self.level row:self.row col:self.col];
    
    NSURL* tileLocation = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"TileGroup%d/%d-%d-%d.jpg", tileGroup, self.level, self.row, self.col]];
    
                           NSLog(@"%@", tileLocation);
                           
    [self.asyncTextureLoader textureWithContentsOfURL:tileLocation
                                              options:options
                                                queue:queue
                                    completionHandler:complete];
}
     
- (int) tileGroupForZoom:(int)zoom row:(int)row col:(int)col
{
    int tilecount = 0;
    int thisZoomRows, thisZoomCols, total;
    
    for (int i = 0; i < zoom; i++)
    {
        thisZoomRows = ceil(self.nativeSize.height / (self.tileSize.height * pow(2.0, self.maximumZoom - i)));
        thisZoomCols = ceil(self.nativeSize.width / (self.tileSize.width * pow(2.0, self.maximumZoom - i)));
        total = thisZoomRows*thisZoomCols;
        tilecount += total;
    }
    
    int finalCols = ceil(self.nativeSize.width / (self.tileSize.width * pow(2.0, self.maximumZoom - zoom)));
    tilecount += row * finalCols + col;
    
    return floor(tilecount / 256.0);
}

-(void) determineRelativeLocation
{
    
//
//    int nextEI = ceil(self.nativeSize.width / (256 * pow(2.0,  max_levels - self.level -1  )));
//    int nextEJ = ceil(self.nativeSize.height/ (256 * pow(2.0,  max_levels - self.level -1  )));
//    
    
//    if (aspect_ratio <= 1) {
//        self.scale = GLKVector3Make(1.0, 10.0, 10.0 / aspect_ratio);
//    }
//    else{
//        //wider than tall
//        self.scale = GLKVector3Make(1.0, 10.0 / aspect_ratio, 10.0);
//    }
    
//    self.sizeInGlCoords = GLKVector2Make(self.scale.z, self.scale.x);
    
//    NSLog(@"In gl space: %f x %f", self.sizeInGlCoords.x, self.sizeInGlCoords.y);
    
    int eI = ceil(self.nativeSize.width / (256 * pow(2.0,          self.maximumZoom - self.level )));
    int eJ = ceil(self.nativeSize.height/ (256 * pow(2.0,          self.maximumZoom - self.level )));

    
    NSLog(@"%d levels, %d %d",         self.maximumZoom, eI, eJ);
    
    //    for (int i=0; i<=max_levels; i++) {
    
    
    NSLog(@"at %d, there are %d x %d indices", self.level, eI, eJ);
    
    BOOL validDims = YES;
    
    if (self.row >= eI) {
        NSLog(@"error - invalid dimension row >= eI");
        validDims = NO;
    }
    
    if (self.col >= eJ) {
        NSLog(@"error - invalid dimension col >= eJ");
        validDims = NO;
    }
    
    if (validDims) {
        
        NSLog(@"Valid dimensions, continuing...");
        
        
        int scaled_tile_size = 256 * pow(2.0,  self.maximumZoom - self.level);
        
        int x_origin = self.col * scaled_tile_size;
        int x_extent = (self.col +1) * scaled_tile_size;
        int x_centr = x_origin + ((x_extent - x_origin) / 2);
        
        int y_origin = self.row * scaled_tile_size;
        int y_extent = (self.row + 1) * scaled_tile_size;
        int y_centr = y_origin + ((y_extent - y_origin) / 2);
        
        NSLog(@"native coords: %d %d -> %d %d", x_origin, y_origin, x_extent, y_extent);
        
        float rel_x_centr = x_centr / self.powerOfTwoSize.x;
        float rel_y_centr = y_centr / self.powerOfTwoSize.y;
        
        self.tileOrigin = GLKVector3Make(0, rel_x_centr * 10, rel_y_centr * 10);
        
        
    }
    
    
    
//    NSLog(@"at %d, there are %d x %d indices", self.level+1, nextEI, nextEJ);
}

- (void) updateMVMatrixWithViewMatrix:(GLKMatrix4) theViewMatrix
{
    //    VerboseLog();
    
    GLKVector3 newPosition = GLKVector3Add(self.position, self.tileOrigin);
    
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(newPosition.x, newPosition.y, newPosition.z);
    
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(self.scale.x,self.scale.y,self.scale.z);
    
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(self.rotation.x);
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(self.rotation.y);
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(self.rotation.z);
    
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                xRotationMatrix))));
    
    self.modelViewMatrix = GLKMatrix4Multiply(theViewMatrix, modelMatrix);
    
    
}

- (void) drawWithEffect:(GLKBaseEffect*) theEffect
{
    [self drawThisTileWithEffect:theEffect];
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



@end
