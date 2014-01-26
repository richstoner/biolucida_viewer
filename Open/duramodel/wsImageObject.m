//
//  wsImageObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsImageObject.h"

@interface wsImageObject ()
{
    NSMutableData *cubeVertexData;
    
    NSMutableData *vertexNormals;
    
    NSMutableData *wireFrameData;
    
    NSMutableData *planeVerexData;
    
    NSMutableData *debugLineData;
    
    BOOL useConstantColor;
    
    GLint viewport[4];
}


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


/**
 Readonly vertex list
 */
@property(readonly) GLKVector3 *vertices;

/**
 Readonly normals list
 */
@property(readonly) GLKVector3 *normals;

/**
 
 */
@property(readonly) GLKVector3* wireFrameCubeVertices;

/**
 
 */
@property(readonly) GLKVector3* planeVertices;

/**
 
 */
@property(readonly) GLKVector3* debugLineVertices;



@property(nonatomic, strong) wsTileObject* tile;

@property (nonatomic, assign) GLKMatrix4 topMVPMatrix;

@property (nonatomic, assign) GLKMatrix4 rightMVPMatrix;
//
@property (nonatomic, assign) GLKMatrix4 frontMVPMatrix;


@property(nonatomic, strong) NSString* cacheDirectory;
@property(nonatomic, strong) NSOperationQueue* tileQueue;


@end

@implementation wsImageObject


// FROM: http://stackoverflow.com/questions/364985/algorithm-for-finding-the-smallest-power-of-two-thats-greater-or-equal-to-a-giv
/// Round up to next higher power of 2 (return x if it's already a power
/// of 2).
int
pow2roundup (int x)
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


@synthesize context = _context;
@synthesize effect  = _effect;
@synthesize cacheDirectory;

#pragma mark - Before -

- (id)init
{
    self = [super init];
    if (self) {

        self.notificationString = kNotificationPresentObject;
        
        self.baseRotation = GLKVector3Make(180, 180, 0);
        self.baseScale = GLKVector3Make(0.05f, 0.05f, 0.05f);
        self.basePosition = GLKVector3Make(0, 0, 0);
        
        self.tileQueue = [[NSOperationQueue alloc] init];
        self.tileQueue.maxConcurrentOperationCount = 3;
        
    }
    return self;
}


#pragma mark - Property accessors -


-(NSURL*) serverURL {
    return nil;
}


-(void) registerNotifications
{
    VerboseLog();
}


-(void) unregisterNotifications
{
    VerboseLog();
}


- (GLKVector3 *)vertices {
    if (cubeVertexData == nil)
        cubeVertexData = [NSMutableData dataWithLength:sizeof(GLKVector3)*36];
    return [cubeVertexData mutableBytes];
}

- (GLKVector3 *)normals {
    if (vertexNormals == nil)
        vertexNormals = [NSMutableData dataWithLength:sizeof(GLKVector3)*36];
    return [vertexNormals mutableBytes];
}

- (GLKVector3*)wireFrameCubeVertices {
    if (wireFrameData == nil)
        wireFrameData = [NSMutableData dataWithLength:sizeof(GLKVector3)*24];
    return [wireFrameData mutableBytes];
}

- (GLKVector3*)planeVertices {
    if (planeVerexData == nil)
        planeVerexData = [NSMutableData dataWithLength:sizeof(GLKVector3)*4];
    return [planeVerexData mutableBytes];
}

- (GLKVector3*)debugLineVertices {
    if (debugLineData == nil)
        debugLineData = [NSMutableData dataWithLength:sizeof(GLKVector3)*4];
    return [debugLineData mutableBytes];
}


-(NSString*) localizedName
{
    return self.title;
}

-(NSString*) localizedDescription
{
    if (self.description) {
        return self.description;
    }

    return [NSString stringWithFormat:@"%d x %d (%d x %d)",
                                        (int)self.nativeSize.width,
                                        (int)self.nativeSize.height,
                                        (int)self.tileSize.width,
                                        (int)self.tileSize.height];
}

-(int) maximumZoom {
    
    return ceil(log(ceil((double)(MAX(self.nativeSize.width, self.nativeSize.height)/ self.tileSize.width)))/log(2.0));
    
}




#pragma mark - internals -




-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
    NSDictionary* local_keymap = @{
                                   @"title" :       @[ @"title", @"object"],
                                   @"description" : @[ @"description", @"object"],
                                   @"nativeSize" :  @[@"native_size", @"CGSize"],
                                   @"tileSize" :    @[@"tile_size", @"CGSize"]
                                   };
    
    
    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}

-(void) drawInRect:(CGRect) tileRect forScale:(CGFloat) scale row:(int)row col:(int) col
{
    
    UIImage* tile = [FontAwesome imageWithIcon:fa_xing iconColor:UIColorFromRGB(0xfffff) iconSize:50 imageSize:CGSizeMake(self.tileSize.width, self.tileSize.height)];
    
    [tile drawInRect:tileRect];
    
}




#pragma mark - 3D methods




- (void) prepareWithContext:(EAGLContext*) theContext
{
    VerboseLog();
    
    [self setContext:theContext];
    
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [GLKBaseEffect new];
    
    self.effect.light0.enabled  = GL_TRUE;
    
    GLfloat ambientColor        = 1.0f;
    GLfloat alpha               = 1.0f;
    
    self.effect.light0.ambientColor = GLKVector4Make(ambientColor, ambientColor, ambientColor, alpha);
    
    GLfloat diffuseColor        = 1.0f;
    
    self.effect.light0.diffuseColor = GLKVector4Make(diffuseColor, diffuseColor, diffuseColor, alpha);
    
    // Spotlight
    GLfloat specularColor       = 0.3f;
    
    self.effect.light0.specularColor    = GLKVector4Make(0.0, 0.0f, specularColor, alpha);
    self.effect.light0.position         = GLKVector4Make(5.0f, 10.0f, 10.0f, 0.0);
    self.effect.light0.spotDirection    = GLKVector3Make(0.0f, 0.0f, -1.0f);
    self.effect.light0.spotCutoff       = 20.0; // 40° spread total.
    
    self.effect.lightingType = GLKLightingTypePerVertex;
    self.effect.material.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, alpha);
    
    self.asyncTextureLoader = [[GLKTextureLoader alloc] initWithSharegroup:self.context.sharegroup];

    
}


-(void) setRenderDelegateAndLoad:(id<wsRenderObjectDelegate>)delegate
{
    VerboseLog();
    
    self.delegate = delegate;
    
    // calculate effective scale, where the 1000 pixels - 10points in
    
    self.baseScale = GLKVector3Make(0.001f, 0.001f, 0.001f);
    
    GLKVector3 relposition = GLKVector3Make(self.nativeSize.width, self.nativeSize.height, 1);
    self.basePosition = GLKVector3MultiplyScalar(GLKVector3Multiply(relposition, self.baseScale), 0.5);
    
//    self.basePosition = GLKVector3Make(0, 0, 0);
    

    // create a cache directory
    self.cacheDirectory = [[WSMetaDataStore documentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"cache/cache-%@", self.localizedName]].path;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSLog(@"test %@", self.cacheDirectory);
    
    // create a bounding box with these dimensions
    self.boundingBox = [wsBounds new];
    self.boundingBox.bbl = GLKVector3Make(0, 0, 0);
    self.boundingBox.bbh = [self maximumBoundsForZoom:0];

    [self initializeCubeVertices];
    [self initializePlaneVertices];

    [self calculateBoundingBox];
    [self allocateTilesForImage];
    
    
    

//    if ([self.delegate respondsToSelector:@selector(renderObjectHasData:)])
//    {
//        [self.delegate performSelector:@selector(renderObjectHasData:) withObject:self];
//    }
    
}

- (UIImage *)image:(UIImage*) theImage croppedToRect:(CGRect)rect
{
    //create drawing context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context, 50.0f/255.0f, 50.0f/255.0f, 50.0f/255.0f, 1.0f);
    CGContextFillRect(context, rect );
    
    //draw
    [theImage drawAtPoint:CGPointMake(-rect.origin.x, -rect.origin.y)];
    
    //capture resultant image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return image
    return image;
}


-(BOOL) hasCachedTileForIndex:(GLKVector3)theIndex
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self localPathForTileWithIndex:theIndex]];
}

-(NSString*) localPathForTileWithIndex:(GLKVector3) theIndex
{
    return [self.cacheDirectory stringByAppendingFormat:@"/%d-%d-%d", (int)theIndex.x, (int)theIndex.z, (int)theIndex.y];
}

-(NSURL*) getTileURLforIndex:(GLKVector3) theIndex
{
    return nil;
}

-(void) downloadTileForIndex:(GLKVector3)theIndex
{
    NSURL* indexURL = [self getTileURLforIndex:theIndex];
    NSString* localURL = [self.cacheDirectory stringByAppendingFormat:@"/%d-%d-%d", (int)theIndex.x, (int)theIndex.z, (int)theIndex.y];
    NSURLSession *session = [NSURLSession sharedSession];
    session.configuration.HTTPMaximumConnectionsPerHost = 5.0;
    
    NSLog(@"%@", localURL);
    
    NSURLRequest* request = [NSURLRequest requestWithURL:indexURL];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       
        if (error) {
            
            NSLog(@"Error: %@", error.localizedDescription);
            
        }
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        UIImage* responseImage = [UIImage imageWithData:data];
        
        UIImage* paddedImage = [strongSelf image:responseImage croppedToRect:CGRectMake(0, 0, 256, 256)];
        
        [UIImagePNGRepresentation(paddedImage) writeToFile:localURL atomically:YES];
        
    }];
    
    [dataTask resume];
    
}

-(GLKVector3) maximumBoundsForZoom:(int)zoom
{
    int currentTileWidth = (int)self.tileSize.width * pow(2.0, self.maximumZoom - zoom);
    int currentTileHeight = (int)self.tileSize.height * pow(2.0, self.maximumZoom - zoom);
    int currentTileSize = MAX(currentTileHeight, currentTileWidth);
    int currentLevelRows = ceil( self.nativeSize.height / currentTileSize);
    int currentLevelCols = ceil( self.nativeSize.width / currentTileSize);
    
    return GLKVector3Make(currentLevelCols * currentTileSize, currentLevelRows * currentTileSize,1);
}

-(CGFloat) smallestTexelInTile:(wsTileObject*) theTile
{
    
    GLKVector3 cen = GLKMathProject(theTile.centroid,
                                   self.baseMVPMatrix,
                                   self.parentProjectionMatrix,
                                   viewport);

    GLKVector3 corners[4];
    corners[0] = GLKMathProject(theTile.tl,
                                       self.baseMVPMatrix,
                                       self.parentProjectionMatrix,
                                       viewport);

    corners[1] = GLKMathProject(theTile.tr,
                                   self.baseMVPMatrix,
                                   self.parentProjectionMatrix,
                                   viewport);
    

    corners[2] = GLKMathProject(theTile.bl,
                                   self.baseMVPMatrix,
                                   self.parentProjectionMatrix,
                                   viewport);
    
    corners[3] = GLKMathProject(theTile.br,
                                   self.baseMVPMatrix,
                                   self.parentProjectionMatrix,
                                   viewport);
    
    
    
    // this finds the shortest  distance in screen coordinates from centroid to the four corners of the tile
    //    CGFloat max_distance = MAXFLOAT;
    //    int distance_corner = 0;
    //    for (int i =0; i<4; i++) {
    //        CGFloat dist = fabsf(GLKVector3Distance(cen, corners[i]));
    //        if (dist < max_distance) {
    //            distance_corner = i;
    //            max_distance = dist;
    //        }
    //    }
    
    // this finds the longest distance from centroid, which is the neaest corner to the viewer
    CGFloat min_distance = 0;
    int distance_corner = 0;
    for (int i =0; i<4; i++) {
        CGFloat dist = fabsf(GLKVector3Distance(cen, corners[i]));
        if (dist > min_distance) {
            distance_corner = i;
            min_distance = dist;
        }
    }

    
//    NSLog(@"%f", min_distance / 128.0);
    
    return min_distance / 128.0;
    

//    CGFloat avg_distance =   (fabsf(GLKVector3Distance(cen, tl)) + fabsf(GLKVector3Distance(cen, br))) * 0.5;
    
//    NSLog(@"%f",avg_distance );


    
    
    
//    
//    NSLog(@"%@", GLKVector3String(cen));
//    NSLog(@"%@", GLKVector3String(tl));
//    NSLog(@"%@", GLKVector3String(br));
    
    
//    return 0.5;
    
    //
    //
    //float ofxWBCGenericTile::calcPTSP()
    //{
    //	GLfloat cx,cy,tw,th;
    //	//calc_tile_region_mm(res,row,col, &cx,&cy,&tw,&th);
    //
    //	cx = mCentroid[0];
    //	cy = mCentroid[1];
    //	tw = mScaledSize[0];
    //	th = mScaledSize[1];
    //
    //	GLfloat proj[16],model[16];
    //	GLint view[4];
    //	glGetFloatv(GL_PROJECTION_MATRIX, proj);
    //	glGetFloatv(GL_MODELVIEW_MATRIX, model);
    //
    //	glGetIntegerv(GL_VIEWPORT,view);
    //
    //	GLfloat winx1,winy1,winz1;
    //	GLfloat winx2,winy2,winz2;
    //	GLfloat winx3,winy3,winz3;
    //	GLfloat max_tsp = 0.0; // max (projected) texel size in pixels
    //	GLfloat tsp;
    //
    //	// How large is the projection of a texel in the center of the tile?
    //	{
    //
    //		wbcProject(cx        ,cy        ,0.0, model,proj,view, &winx1,&winy1,&winz1);
    //		wbcProject (cx+tw/256.,cy        ,0.0, model,proj,view, &winx2,&winy2,&winz2);
    //		wbcProject (cx        ,cy+th/256.,0.0, model,proj,view, &winx3,&winy3,&winz3);
    //		tsp = 0.5*(sqrt(pow((winx2-winx1),2)+pow((winy2-winy1),2))+
    //				   sqrt(pow((winx3-winx1),2)+pow((winy3-winy1),2)));
    //		max_tsp=tsp;
    //	}
    //
    //	// How large is are the projections of texels on the corners of the tile?
    //	{
    //		int i,j;
    //		for(i=0;i<2;i++) {
    //			GLfloat ox=cx+(i==0?1.0:-1.0)*tw/2;
    //			for(j=0;j<2;j++) {
    //				GLfloat oy=cy+(j==0?1.0:-1.0)*th/2;
    //				wbcProject (ox        ,oy        ,0.0, model,proj,view, &winx1,&winy1,&winz1);
    //				wbcProject (ox+tw/256.,oy        ,0.0, model,proj,view, &winx2,&winy2,&winz2);
    //				wbcProject (ox        ,oy+th/256.,0.0, model,proj,view, &winx3,&winy3,&winz3);
    //				tsp = 0.5*(sqrt(pow((winx2-winx1),2)+pow((winy2-winy1),2))+ sqrt(pow((winx3-winx1),2)+pow((winy3-winy1),2)));;
    //				if(winz1>0) { max_tsp=max(max_tsp,tsp); }
    //			}
    //		}
    //	}
    //	
    //	return max_tsp;
    //}
}


-(void) allocateTilesForImage
{
    VerboseLog();
    
    self.tile = [[wsTileObject alloc] initWithParentImage:self];
    [self.tile updateIndex:GLKVector3Make(0, 0, 0)];
    
}

-(void) updateTiles
{
//    if([self respondsToSelector:@selector(getImageForZoom:row:col:)])
//    {
//        wsRemoteZoomifyObject* zi = (wsRemoteZoomifyObject*)self;
//        
//        UIImage* igm = [zi getImageForZoom:self.tile.tileIndex.x row:self.tile.tileIndex.y col:self.tile.tileIndex.z];
//        [self.tile updateTextureWithImage:igm];
//        
//        
//    }
}

-(void) initializeCubeVertices
{
    
    
    
    //            1.0f, 0.0f, 0.0f,
    //            1.0f,  1.0f, 0.0f,
    //            1.0f, 0.0f,  1.0f,
    //            1.0f, 0.0f,  1.0f,
    //            1.0f,  1.0f,  1.0f,
    //            1.0f,  1.0f, 0.0f,
    
    self.vertices[0] = GLKVector3Make(1.0f, 0.0f, 0.0f);
    self.vertices[1] = GLKVector3Make(1.0f,  1.0f, 0.0f);
    self.vertices[2] = GLKVector3Make(1.0f, 0.0f,  1.0f);
    self.vertices[3] = GLKVector3Make(1.0f, 0.0f,  1.0f);
    self.vertices[4] = GLKVector3Make(1.0f,  1.0f,  1.0f);
    self.vertices[5] = GLKVector3Make(1.0f,  1.0f, 0.0f);
    /////////////////////////////////////////////////////////////////
    
    //            1.0f,  1.0f, 0.0f,
    //            0.0f,  1.0f, 0.0f,
    //            1.0f,  1.0f,  1.0f,
    //            1.0f,  1.0f,  1.0f,
    //            0.0f,  1.0f, 0.0f,
    //            0.0f,  1.0f,  1.0f,
    
    self.vertices[6] = GLKVector3Make(   1.0f,  1.0f, 0.0f);
    self.vertices[7] = GLKVector3Make(  0.0f,  1.0f, 0.0f);
    self.vertices[8] = GLKVector3Make(   1.0f,  1.0f,  1.0f);
    self.vertices[9] = GLKVector3Make(   1.0f,  1.0f,  1.0f);
    self.vertices[10] = GLKVector3Make( 0.0f,  1.0f, 0.0f);
    self.vertices[11] = GLKVector3Make( 0.0f,  1.0f,  1.0f);
    
    /////////////////////////////////////////
    
    //
    //            0.0f,  1.0f, 0.0f,
    //            0.0f, 0.0f, 0.0f,
    //            0.0f,  1.0f,  1.0f,
    //            0.0f,  1.0f,  1.0f,
    //            0.0f, 0.0f, 0.0f,
    //            0.0f, 0.0f,  1.0f,
    
    
    self.vertices[12] = GLKVector3Make(0.0f,   1.0f, 0.0f);
    self.vertices[13] = GLKVector3Make(0.0f,  0.0f, 0.0f);
    self.vertices[14] = GLKVector3Make(0.0f,   1.0f,  1.0f);
    self.vertices[15] = GLKVector3Make(0.0f,   1.0f,  1.0f);
    self.vertices[16] = GLKVector3Make(0.0f,  0.0f, 0.0f);
    self.vertices[17] = GLKVector3Make(0.0f,  0.0f,  1.0f);
    
    //////////////////////////
    
    //            0.0f, 0.0f, 0.0f,
    //            1.0f, 0.0f, 0.0f,
    //            0.0f, 0.0f,  1.0f,
    //            0.0f, 0.0f,  1.0f,
    //            1.0f, 0.0f, 0.0f,
    //            1.0f, 0.0f,  1.0f,
    
    
    self.vertices[18] = GLKVector3Make(0.0f, 0.0f, 0.0f);
    self.vertices[19] = GLKVector3Make(1.0f,  0.0f, 0.0f);
    self.vertices[20] = GLKVector3Make(0.0f, 0.0f,  1.0f);
    self.vertices[21] = GLKVector3Make(0.0f, 0.0f,  1.0f);
    self.vertices[22] = GLKVector3Make(1.0f,  0.0f,  0.0f);
    self.vertices[23] = GLKVector3Make(1.0f,  0.0f, 1.0f);
    
    //////////
    
    //            1.0f,  1.0f,  1.0f,
    //            0.0f,  1.0f,  1.0f,
    //            1.0f, 0.0f,  1.0f,
    //            1.0f, 0.0f,  1.0f,
    //            0.0f,  1.0f,  1.0f,
    //            0.0f, 0.0f,  1.0f,
    
    self.vertices[24] = GLKVector3Make(1.0f, 1.0f, 1.0f);
    self.vertices[25] = GLKVector3Make(0.0f,  1.0f, 1.0f);
    self.vertices[26] = GLKVector3Make(1.0f, 0.0f,  1.0f);
    self.vertices[27] = GLKVector3Make(1.0f, 0.0f,  1.0f);
    self.vertices[28] = GLKVector3Make(0.0f,  1.0f,  1.0f);
    self.vertices[29] = GLKVector3Make(0.0f,  0.0f, 1.0f);
    
    //////////////
    
    //            1.0f, 0.0f, 0.0f,         0.0f,  0.0f, 0.0f,
    //            0.0f, 0.0f, 0.0f,         0.0f,  0.0f, 0.0f,
    //            1.0f,  1.0f, 0.0f,         0.0f,  0.0f, 0.0f,
    //            1.0f,  1.0f, 0.0f,         0.0f,  0.0f, 0.0f,
    //            0.0f, 0.0f, 0.0f,         0.0f,  0.0f, 0.0f,
    //            0.0f,  1.0f, 0.0f,         0.0f,  0.0f, 0.0f
    
    self.vertices[30] = GLKVector3Make(1.0f, 0.0f, 0.0f);
    self.vertices[31] = GLKVector3Make(0.0f,  0.0f, 0.0f);
    self.vertices[32] = GLKVector3Make(1.0f, 1.0f,  0.0f);
    
    self.vertices[33] = GLKVector3Make(1.0f, 1.0f,  0.0f);
    self.vertices[34] = GLKVector3Make(0.0f,  0.0f,  0.0f);
    self.vertices[35] = GLKVector3Make(0.0f,  1.0f, 0.0f);
    
    
    for (int i =0; i<6; i++) {
        for (int j = 0; j<6; j++) {
            
            if (i==0) {
                self.normals[i*6 + j] = GLKVector3Make(1.0, 0, 0);
            }
            if (i==1) {
                self.normals[i*6 + j] = GLKVector3Make(0.0, 1.0, 0);
            }
            if (i==2) {
                self.normals[i*6 + j] = GLKVector3Make(-1.0, 0, 0);
            }
            if (i==3) {
                self.normals[i*6 + j] = GLKVector3Make(0.0, -1.0, 0);
            }
            if (i==4) {
                self.normals[i*6 + j] = GLKVector3Make(0.0, 0, 1.0);
            }
            if (i==5) {
                self.normals[i*6 + j] = GLKVector3Make(0, 0, -1.0);
            }
            
            
        }
    }
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




#pragma mark - Update object with new data -






-(void) initializePlaneVertices {
    // standard plane
    
    int width = self.boundingBox.bbh.x;
    int height = self.boundingBox.bbh.y;
    //
    //        self.planeVertices[0] = GLKVector3Make( width/2.0, -height/2.0, 0);
    //        self.planeVertices[1] = GLKVector3Make( width/2.0,  height/2.0, 0);
    //        self.planeVertices[2] = GLKVector3Make(-width/2.0,  height/2.0, 0);
    //        self.planeVertices[3] = GLKVector3Make(-width/2.0, -height/2.0, 0);
    
    self.planeVertices[0] = GLKVector3Make( width, 0, 0);
    self.planeVertices[1] = GLKVector3Make( width,  height, 0);
    self.planeVertices[2] = GLKVector3Make(0,  height, 0);
    self.planeVertices[3] = GLKVector3Make(0, 0, 0);
    
    
}




-(void) updateMVPMatrix:(GLKMatrix4)theViewMatrix
{
    self.effect.transform.projectionMatrix = self.parentProjectionMatrix;

    self.parentMVPMatrix = theViewMatrix;
    
    GLKVector3 rotation = self.baseRotation;
    GLKVector3 position = self.basePosition;
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(rotation.x));
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(GLKMathDegreesToRadians(rotation.y));
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(GLKMathDegreesToRadians(rotation.z));
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(self.baseScale.x, self.baseScale.y, self.baseScale.z);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                xRotationMatrix))));
    
    self.baseMVPMatrix = GLKMatrix4Multiply(theViewMatrix, modelMatrix);
    
    
    
    
    
    
    
    [self updateTileMatrices];
    
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


-(void) updateTileMatrices
{

    [self.tile updateMVmatrix:self.baseMVPMatrix];

}



-(void)render {
    
    
    glGetIntegerv(GL_VIEWPORT,viewport);

    if (!self.shouldHide) {
        
        if(self.context){

            [EAGLContext setCurrentContext:self.context];

            [self renderBounds];
            
            [self renderTiles];

            
        }
    
    }
}

-(void) renderTiles
{
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
    
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, self.normals);

//
//    self.effect.material.diffuseColor = GLKVector4Make(0, 1, 0, 0.5);
//    self.effect.material.ambientColor = GLKVector4Make(0, 1, 0, 0.5);
//    
//    [self.effect prepareToDraw];
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    
    
    if (self.tile) {
        
        [self.tile renderWithEffect:self.effect];
        
    }
    
    self.effect.texture2d0.enabled = GL_FALSE;

    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribNormal);

    
//    self.effect.texture2d0.name = textureTopBottom.name;
//
//    self.effect.useConstantColor = NO;
//    self.effect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    self.effect.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);



//    self.effect.transform.modelviewMatrix = self.topMVPMatrix;

//    if (textureTopBottom != nil) {
//
//        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.texCoordsTB);
//    }

//    [self.effect prepareToDraw];
//
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//
//    if (textureTopBottom != nil)
//    {
//        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
//    }
    
    
    
}



-(void) renderWithTouch:(GLKVector3)selectedObject
{
    if (!self.shouldHide) {
        
        [EAGLContext setCurrentContext:self.context];

        
        [self renderBounds];
        
        [self renderTiles];
        
        
    }
}

-(void) renderWithHighlight {
    
    if (!self.shouldHide) {
        
        [EAGLContext setCurrentContext:self.context];
        
        
        [self renderBoundsHighlight];
    
        [self renderTiles];

    }
    
    
}


-(void) renderSelect
{
//    VerboseLog();
//    self.effect.light0.enabled = GL_FALSE;
    
//    if (!self.shouldHide) {
//        
//        [EAGLContext setCurrentContext:self.context];
//        
//        
//        // select either
//        //  cube (layer id, 0,0)
//        //  x (layer id, 0,1)
//        //  y (layer id, 0,2)
//        //  z (layer id, 0,3)
//        
////        [self renderActivePlanesSelect];
//        
//        
//        
////        glDisableVertexAttribArray(GLKVertexAttribPosition);
//        
//    }
    
//    self.effect.light0.enabled = GL_TRUE;
    
}







-(void) renderBounds
{
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.wireFrameCubeVertices);
    
    self.effect.transform.modelviewMatrix = self.baseMVPMatrix;
    
    self.effect.light0.enabled = GL_FALSE;
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(1, 1, 1, 1);
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_LINES, 0, 24);
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.useConstantColor = GL_FALSE;
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
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
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    
    
}


-(void) renderSelectedPlaneWithIndex:(int) planeIndex
{
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    self.effect.transform.projectionMatrix = self.parentProjectionMatrix;
    self.effect.transform.modelviewMatrix = self.baseMVPMatrix;
//
//    switch (planeIndex) {
//        case reserveredObjectIDXAxis:
//            
//            [self renderTop];
//            [self renderFrontWithOpacity:0.3];
//            [self renderRightWithOpacity:0.3];
//            
//            break;
//            
//        case reserveredObjectIDYAxis:
//            
//            [self renderRight];
//            [self renderTopWithOpacity:0.3];
//            [self renderFrontWithOpacity:0.3];
//            
//            break;
//            
//        case reserveredObjectIDZAxis:
//            
//            [self renderFront];
//            [self renderTopWithOpacity:0.3];
//            [self renderRightWithOpacity:0.3];
//            
//            
//            break;
//            
//        default:
//            
//            [self renderTop];
//            [self renderFront];
//            [self renderRight];
//            
//            
//            break;
//    }
//    
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisable(GL_BLEND);
    
}

-(void) renderDebug
{
    
    //    glEnable(GL_BLEND);
    //    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.debugLineVertices);
    
    //    glEnableVertexAttribArray(GLKVertexAttribNormal);
    //    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, self.normals);
    
    self.effect.transform.modelviewMatrix = self.rightMVPMatrix;
    
    self.effect.light0.enabled = GL_FALSE;
    self.effect.useConstantColor = GL_TRUE;
    self.effect.constantColor = GLKVector4Make(0, 0.7, 1, 1);
    
    //    self.effect.material.diffuseColor = kBlueFade;
    
    [self.effect prepareToDraw];
    
    glDrawArrays(GL_LINES, 0, 2);
    
    
    self.effect.light0.enabled = GL_TRUE;
    self.effect.useConstantColor = GL_FALSE;
    //    glDisable(GL_BLEND);
    
}
//
//
//
//-(void) renderTop
//{
//    [self renderTopWithOpacity:1.0];
//}
//
//-(void) renderTopWithOpacity:(GLfloat) opacity
//{
//    
//    //    VerboseLog();
//    self.effect.texture2d0.enabled = GL_TRUE;
//    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
//    
//    self.effect.texture2d0.target = GLKTextureTarget2D;
//    self.effect.texture2d0.name = textureTopBottom.name;
//    
//    self.effect.useConstantColor = NO;
//    self.effect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    self.effect.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
//    
//    glEnableVertexAttribArray(GLKVertexAttribNormal);
//    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, self.normals);
//    
//    
//    self.effect.transform.modelviewMatrix = self.topMVPMatrix;
//    
//    if (textureTopBottom != nil) {
//        
//        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.texCoordsTB);
//    }
//    
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    if (textureTopBottom != nil)
//    {
//        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
//    }
//    
//    self.effect.texture2d0.enabled = GL_FALSE;
//}
//
//
//-(void) renderRight{
//    [self renderRightWithOpacity:1.0];
//}
//
//-(void) renderRightWithOpacity:(GLfloat) opacity
//{
//    
//    self.effect.texture2d0.enabled = GL_TRUE;
//    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
//    self.effect.texture2d0.target = GLKTextureTarget2D;
//    self.effect.texture2d0.name = textureRightLeft.name;
//    self.effect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    self.effect.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    self.effect.useConstantColor = YES;
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
//    
//    self.effect.transform.modelviewMatrix = self.rightMVPMatrix;
//    
//    if (textureRightLeft != nil) {
//        
//        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.texCoordsRL);
//    }
//    
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    if (textureRightLeft != nil)
//    {
//        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
//    }
//    
//    self.effect.texture2d0.enabled = GL_FALSE;
//}
//
//-(void) renderFront {
//    [self renderFrontWithOpacity:1.0];
//}
//
//-(void) renderFrontWithOpacity:(GLfloat) opacity
//{
//    
//    self.effect.texture2d0.enabled = GL_TRUE;
//    self.effect.texture2d0.envMode = GLKTextureEnvModeModulate;
//    self.effect.texture2d0.target = GLKTextureTarget2D;
//    self.effect.texture2d0.name = textureFrontBack.name;
//    self.effect.material.diffuseColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    self.effect.material.ambientColor = GLKVector4Make(1.0, 1.0, 1.0, opacity);
//    self.effect.useConstantColor = YES;
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
//    
//    self.effect.transform.modelviewMatrix = self.frontMVPMatrix;
//    
//    if (textureFrontBack != nil) {
//        
//        glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
//        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, self.texCoordsFB);
//    }
//    
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    if (textureFrontBack != nil)
//    {
//        glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
//    }
//    
//    self.effect.texture2d0.enabled = GL_FALSE;
//}
//
//
//
//-(void) renderActivePlanes
//{
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
//    
//    glEnableVertexAttribArray(GLKVertexAttribNormal);
//    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, self.normals);
//    
//    
//    self.effect.transform.projectionMatrix = self.parentProjectionMatrix;
//    self.effect.transform.modelviewMatrix = self.topMVPMatrix;
//    
//    self.effect.material.diffuseColor = GLKVector4Make(0, 1, 0, 0.5);
//    self.effect.material.ambientColor = GLKVector4Make(0, 1, 0, 0.5);
//    
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    
//    self.effect.material.diffuseColor = GLKVector4Make(0, 0, 1, 0.5);
//    self.effect.material.ambientColor = GLKVector4Make(0, 0, 1, 0.5);
//    
//    
//    self.effect.transform.modelviewMatrix = self.rightMVPMatrix;
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    
//    self.effect.material.ambientColor = GLKVector4Make(1, 0, 0, 0.5);
//    self.effect.material.diffuseColor = GLKVector4Make(1, 0, 0, 0.5);
//    
//    self.effect.transform.modelviewMatrix = self.frontMVPMatrix;
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    // reset material ambient
//    
//    
//    glDisableVertexAttribArray(GLKVertexAttribPosition);
//    glDisable(GL_BLEND);
//    
//}

//-(void) renderSelectedPlaneWithIndex:(int) planeIndex
//{
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
//
//    switch (planeIndex) {
//        case reserveredObjectIDXAxis:
//
//            self.effect.material.ambientColor = GLKVector4Make(0, 1, 0, 0.7);
//            self.effect.material.diffuseColor = GLKVector4Make(0, 1, 0, 0.7);
//
//
//            self.effect.transform.projectionMatrix = self.parentProjectionMatrix;
//            self.effect.transform.modelviewMatrix = self.topMVPMatrix;
//
//            [self.effect prepareToDraw];
//
//            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);            break;
//
//        case reserveredObjectIDYAxis:
//
//            self.effect.material.ambientColor = GLKVector4Make(0, 0, 1, 0.7);
//            self.effect.material.diffuseColor = GLKVector4Make(0, 0, 1, 0.7);
//
//
//            self.effect.transform.modelviewMatrix = self.rightMVPMatrix;
//            [self.effect prepareToDraw];
//
//            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//
//            break;
//
//        case reserveredObjectIDZAxis:
//
//            self.effect.material.ambientColor = GLKVector4Make(1, 0, 0, 0.7);
//            self.effect.material.diffuseColor = GLKVector4Make(1, 0, 0, 0.7);
//
//
//
//            self.effect.transform.modelviewMatrix = self.frontMVPMatrix;
//            [self.effect prepareToDraw];
//
//            glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//
//            break;
//
//        default:
//            break;
//    }
//
//    glDisableVertexAttribArray(GLKVertexAttribPosition);
//    glDisable(GL_BLEND);
//
//}



//
//-(void) renderActivePlanesSelect
//{
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//    
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, self.planeVertices);
//    
//    glEnableVertexAttribArray(GLKVertexAttribNormal);
//    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, self.normals);
//    
//    self.effect.useConstantColor = YES;
//    
//    self.effect.transform.projectionMatrix = self.parentProjectionMatrix;
//    self.effect.transform.modelviewMatrix = self.topMVPMatrix;
//    
//    self.effect.constantColor = GLKVector4Make(self.layerID/255.0, 0, reserveredObjectIDXAxis/255.0, 1.0);
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    self.effect.transform.modelviewMatrix = self.rightMVPMatrix;
//    self.effect.constantColor = GLKVector4Make(self.layerID/255.0, 0, reserveredObjectIDYAxis/255.0, 1);
//    
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    self.effect.transform.modelviewMatrix = self.frontMVPMatrix;
//    self.effect.constantColor = GLKVector4Make(self.layerID/255.0, 0, reserveredObjectIDZAxis/255.0, 1.0);
//    
//    [self.effect prepareToDraw];
//    
//    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
//    
//    glDisableVertexAttribArray(GLKVertexAttribPosition);
//    //    glDisable(GL_BLEND);
//    
//}



















@end
