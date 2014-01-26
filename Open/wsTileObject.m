//
//  wsTileObject.m
//  Open
//
//  Created by Rich Stoner on 1/17/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//


// some standards:

// index.x -> zoom
// index.y -> column index (I)
// index.z -> row index (J)


#import "wsTileObject.h"

@interface wsTileObject ()
{
    GLKVector3 _centroid;
    GLKVector3 _scaledSize;
}


@property(nonatomic, assign) GLKVector3 tileIndex;
@property(nonatomic, strong) wsImageObject* parentImage;

@property(nonatomic, assign) GLKMatrix4 MVMatrix;

@property(nonatomic, assign) GLKMatrix4 LocalOffsetMatrix;


@property(nonatomic, strong) GLKTextureInfo *texture;
@property(nonatomic, strong) NSMutableData *textureCoordsData;
@property(readonly) GLKVector2 *textureCoords;

@property(nonatomic, strong) NSMutableArray* subtiles;

@property(nonatomic, assign) int currentTileSize;


@property(nonatomic, assign) CGFloat minimumTexelSize;
@property(nonatomic, assign) BOOL hasDownloadRequest;

@end

@implementation wsTileObject


- (id)initWithParentImage:(wsImageObject*) theImageObject
{
    self = [super init];
    if (self) {
        
        // set parent image (this is where we get images from)
        self.parentImage = theImageObject;
        
        _centroid = GLKVector3Make(-1,-1, -1);
        _scaledSize = GLKVector3Make(-1,-1, -1);
        
        // set default coords
//        self.textureCoords[0] = GLKVector2Make(0, 0);
//        self.textureCoords[1] = GLKVector2Make(0, 1);
//        self.textureCoords[2] = GLKVector2Make(1, 1);
//        self.textureCoords[3] = GLKVector2Make(1, 0);
        

        self.textureCoords[0] = GLKVector2Make(1, 1);
        self.textureCoords[1] = GLKVector2Make(1, 0);
        self.textureCoords[2] = GLKVector2Make(0, 0);
        self.textureCoords[3] = GLKVector2Make(0, 1);
        
        
        self.subtiles = [NSMutableArray new];
        
        self.LocalOffsetMatrix = GLKMatrix4Identity;
        
    }
    return self;
}



-(GLKVector3) scaledSize
{
    if(_scaledSize.x == -1)
    {
        int currentZoom = (int)self.tileIndex.x;
        
        GLKVector3 maxBounds = [self.parentImage maximumBoundsForZoom:0];
        
        GLKVector3 scaledBounds = GLKVector3MultiplyScalar(maxBounds,  1 / pow(2, currentZoom));
        
//        VerboseLog(@"%@", GLKVector3String(scaledBounds));
        
        _scaledSize = GLKVector3Make(scaledBounds.x, scaledBounds.y, 0);
    }
    
    return _scaledSize;
}


-(GLKVector3) centroid
{
    if (_centroid.x == -1) {
        
        int currentZoom = (int)self.tileIndex.x;
        int currentI = (int)self.tileIndex.y;
        int currentJ = (int)self.tileIndex.z;
        
        GLKVector3 maxBounds = [self.parentImage maximumBoundsForZoom:0];
        
        GLKVector3 nativeTranslate = GLKVector3Make((.5 + currentI) * maxBounds.x, (0.5 + currentJ)* maxBounds.y, 0);
        
        GLKVector3 newScale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 1 / pow(2, currentZoom));
        
        _centroid = GLKVector3Multiply(nativeTranslate, newScale);

//        VerboseLog(@"%@", GLKVector3String(_centroid));

    }
    
    return _centroid;
}

-(GLKVector3)tl
{
    return GLKVector3Add(self.centroid, GLKVector3Multiply(self.scaledSize, GLKVector3Make(-0.5 , -0.5 , 0 )));
}

-(GLKVector3)tr
{
    return GLKVector3Add(self.centroid, GLKVector3Multiply(self.scaledSize, GLKVector3Make(0.5 , -0.5 , 0 )));
}

-(GLKVector3)bl
{
    return GLKVector3Add(self.centroid, GLKVector3Multiply(self.scaledSize, GLKVector3Make(-0.5 , 0.5 , 0 )));
}

-(GLKVector3)br
{
    return GLKVector3Add(self.centroid, GLKVector3Multiply(self.scaledSize, GLKVector3Make(0.5 , 0.5 , 0 )));
}

-(GLKMatrix4) transformForIndex:(GLKVector3) theIndex
{
//    VerboseLog(@"%@", GLKVector3String(theIndex));
    
    int currentZoom = (int)self.tileIndex.x;
    int currentI = (int)self.tileIndex.y;
    int currentJ = (int)self.tileIndex.z;
    
    GLKVector3 maxBounds = [self.parentImage maximumBoundsForZoom:0];
    
    GLKVector3 nativeTranslate = GLKVector3Make(currentI * maxBounds.x, currentJ* maxBounds.y, 0*(currentZoom));

    GLKVector3 newScale = GLKVector3MultiplyScalar(GLKVector3Make(1, 1, 1), 1 / pow(2, currentZoom));
    
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(newScale.x, newScale.y, 1);
    
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(nativeTranslate.x, nativeTranslate.y, nativeTranslate.z);
    
    return GLKMatrix4Multiply(scaleMatrix, translateMatrix );
}


-(void) textureCoordsForIndex
{
    int currentZoom = (int)self.tileIndex.x;
    int currentI = (int)self.tileIndex.y;
    int currentJ = (int)self.tileIndex.z;
    
    int currentLevelRows = ceil( self.parentImage.nativeSize.height / self.currentTileSize);
    int currentLevelCols = ceil( self.parentImage.nativeSize.width / self.currentTileSize);
    
    float offsetX = 1;
    float offsetY = 1;
    
    if (currentI == currentLevelCols -1) {
        
        NSLog(@"at perimeter col");
        offsetX = ((int)self.parentImage.nativeSize.width % self.currentTileSize) / (float)self.currentTileSize;
    }
    
    if (currentJ == currentLevelRows -1) {
        NSLog(@"at perimeter rows");
        offsetY = ((int)self.parentImage.nativeSize.height % self.currentTileSize) / (float)self.currentTileSize;
    }
    
    CGPoint pt = CGPointMake(1/offsetX, 1/offsetY);
    
//    NSLog(@"%@", [NSValue valueWithCGPoint:test]);
    
    
    self.textureCoords[0] = GLKVector2Make(pt.x, pt.y);
    self.textureCoords[1] = GLKVector2Make(pt.x, 0);
    self.textureCoords[2] = GLKVector2Make(0, 0);
    self.textureCoords[3] = GLKVector2Make(0, pt.y);
    
    
}


-(void) updateIndex:(GLKVector3) newIndex
{
    self.tileIndex = newIndex;

    // we know our native size, since the parent image is linked
    
    int nextZoom = (int)self.tileIndex.x + 1;
    
    int currentZoom = (int)self.tileIndex.x;
    int currentI = (int)self.tileIndex.y;
    int currentJ = (int)self.tileIndex.z;
    
    self.LocalOffsetMatrix = [self transformForIndex:self.tileIndex];
    
    int currentTileWidth = (int)self.parentImage.tileSize.width * pow(2.0, self.parentImage.maximumZoom - currentZoom);
    int currentTileHeight = (int)self.parentImage.tileSize.height * pow(2.0, self.parentImage.maximumZoom - currentZoom);

    self.currentTileSize = MAX(currentTileHeight, currentTileWidth);
    
//    NSLog(@"Width: %d <- %d x %d", self.currentTileSize, currentTileWidth, currentTileHeight);
    

    
    if (nextZoom <= MIN(self.parentImage.maximumZoom, 10)) {
        
        
        int nextTileWidth = (int)self.parentImage.tileSize.width * pow(2.0, self.parentImage.maximumZoom - nextZoom);
        int nextTileHeight = (int)self.parentImage.tileSize.height * pow(2.0, self.parentImage.maximumZoom - nextZoom);
        int nextTileSize = MAX(nextTileWidth, nextTileHeight);
        
        
        
        
        int nextLevelCols = ceil( self.parentImage.nativeSize.width / nextTileSize);
        int nextLevelRows = ceil( self.parentImage.nativeSize.height / nextTileSize);
//        
//        NSLog(@"Level: %d -> %d x %d", nextZoom, nextLevelCols, nextLevelRows);
        
        for(int row_index = 0; row_index< 2; row_index++)
        {
            for (int col_index = 0; col_index < 2; col_index++)
            {
                int childind_i = ((2*currentI)+col_index); // child row index
                
                int childind_j = ((2*currentJ)+row_index);
                
                if ((childind_i >= nextLevelCols) || (childind_j >= nextLevelRows))
                {
//                    printf("Child shouldn't exist (tile not present) %d %d %d\n", nextZoom, childind_i, childind_j);
                }
                else {
                    
//                    printf("made kid at zoom %d with col %d and row %d\n", nextZoom, childind_i, childind_j);
                    
                    wsTileObject* newTile = [[wsTileObject alloc] initWithParentImage:self.parentImage];
                    
                    [newTile updateIndex:GLKVector3Make(nextZoom, childind_i, childind_j)];
                    
                    [self.subtiles addObject:newTile];
                }
            }
        }
    }
}


-(void) renderWithEffect:(GLKBaseEffect*) theEffect
{

    if (self.shouldDraw ) {
        
        if (self.tileIndex.x <= self.parentImage.maximumZoom) {
            
            
            theEffect.useConstantColor = NO;
            theEffect.texture2d0.name = self.texture.name;
            theEffect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
            theEffect.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
            theEffect.transform.modelviewMatrix = self.MVMatrix;
            
            if (self.texture != nil) {
                
                glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
                glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.textureCoords);
                
                [theEffect prepareToDraw];
                
                glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
                
                glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
                
            }
            else{

                // texture isn't loaded, check to see if parent image has cache
                
                
                if ([self.parentImage hasCachedTileForIndex:self.tileIndex]) {
                    
                    // load
                    
                    [self updateTextureWithPath:[self.parentImage localPathForTileWithIndex:self.tileIndex]];
                    
                    
                }
                else{
                    
                    if (self.hasDownloadRequest) {
                        
                        
                        
                    }
                    else
                    {
                        [self.parentImage downloadTileForIndex:self.tileIndex];
                        self.hasDownloadRequest = YES;
                    }
                }
            
                

                
            }
            
//            theEffect.material.diffuseColor = GLKVector4Make(1, 0, 0, 1);
//            theEffect.material.ambientColor = GLKVector4Make(1, 0, 0, 1);
//            theEffect.transform.modelviewMatrix = self.MVMatrix;
//            [theEffect prepareToDraw];
//            
//            glLineWidth(3);
//            glDrawArrays(GL_LINE_LOOP, 0, 4);
//            glLineWidth(1);
        }
        else
        {
            
            
            theEffect.material.diffuseColor = GLKVector4Make(1, 0, 0, 1);
            theEffect.material.ambientColor = GLKVector4Make(1, 0, 0, 1);
            theEffect.transform.modelviewMatrix = self.MVMatrix;
            [theEffect prepareToDraw];
            
            glLineWidth(3);
            glDrawArrays(GL_LINE_LOOP, 0, 4);
            glLineWidth(1);
            
        }
        
    }
    else
    {
        for (wsTileObject* tile in self.subtiles) {
            [tile renderWithEffect:theEffect];
        }
    }
    
}

-(BOOL) canDraw
{
    return (self.texture != nil);
}

-(BOOL) updateMVmatrix:(GLKMatrix4) theMatrix
{
    BOOL drawWhileLoading = NO;
    
    self.MVMatrix = GLKMatrix4Multiply(theMatrix, self.LocalOffsetMatrix);
    
    self.minimumTexelSize = [self.parentImage smallestTexelInTile:self];
    
    
    
    
    if (self.minimumTexelSize <= 0.95) {
        
//        NSLog(@"Drawing %@ - %f", GLKVector3String(self.tileIndex), self.minimumTexelSize);

        self.shouldDraw = YES;
        
    }
    else
    {
        
        
        // this will return TRUE if it or it's children are capable of handling this
        
        // so if i have kids that are drawing, but i'm not, I should still return true so that parent tile knows not to draw
        
        
        
        for (wsTileObject* tile in self.subtiles) {
            
            if (![tile updateMVmatrix:theMatrix]) {
                
                // one of the tiles isn't ready, draw this tile instead
                drawWhileLoading = YES;
            }
            
        }
        
        
        
        
        self.shouldDraw = NO;
        
        if (self.subtiles.count == 0)
        {
            self.shouldDraw = YES;
        }
        

        
    }
    
    
    return self.shouldDraw;

}



// example GCD CI code


///start HUD code here, on main thread
//// Assuming you already have a CIFilter* variable, created on the main thread, called `myFilter`
//CIFilter* filterForThread = [myFilter copy];
//// Get a concurrent queue form the system
//dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//dispatch_async(concurrentQueue, ^{
//    CIFilter filter = filterForThread;
//    
//    // Effect image using Core Image filter chain on a background thread
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        //dismiss HUD and add fitered image to imageView in main thread
//        
//    });
//    
//});
//[filterForThread release];
//

-(void) updateTextureWithPath:(NSString*) path
{
    
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@YES};
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    void (^tbcomplete)(GLKTextureInfo*, NSError*) = ^(GLKTextureInfo *texture,
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
        });
    };
    
    // load texture in queue and pass in completion block
    [self.parentImage.asyncTextureLoader textureWithContentsOfFile:path options:options queue:queue completionHandler:tbcomplete];
    
//    [self.parentImage.asyncTextureLoader textureWithCGImage:image.CGImage options:options queue:queue completionHandler:tbcomplete];

}

-(void) updateTextureWithImage:(UIImage*) image
{

    
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@YES};
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    void (^tbcomplete)(GLKTextureInfo*, NSError*) = ^(GLKTextureInfo *texture,
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
        });
    };
    // load texture in queue and pass in completion block
    
    
    
    [self.parentImage.asyncTextureLoader textureWithCGImage:image.CGImage options:options queue:queue completionHandler:tbcomplete];
    
}

- (GLKVector2 *) textureCoords {
    if (self.textureCoordsData == nil)
        self.textureCoordsData = [NSMutableData dataWithLength:sizeof(GLKVector2)*4];
    return [self.textureCoordsData mutableBytes];
}




@end
