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
//  WSGLTiledViewController.m
//  Open
//
//  Created by Rich Stoner on 11/14/13.
//


// Design of the 3D tiled renderer
// Assume: 1:100 scaling, therefore a 50k x 30k image would take up 500 x 300 in opengl coords
// Single image origin (0,0,z) ? ... or should that be centroid?



#import "WSGLTiledViewController.h"
#import "WSGLTile.h"
#import <XMLDictionary.h>
#import "OWNavigate.h"

//#import "EERectangle.h"

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



//GLfloat gHLineVertexData[2*6] =
//{
//    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
//    0.0f, -0.0f, -0.0f,       0.0f, +1.0f, 1.0f,
//    1.0f, -0.0f, -0.0f,        0.0f, +1.0f, 1.0f,
//};
//
//GLfloat gVLineVertexData[2*6] =
//{
//    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
//    0.0f, 0.0f, 0.0f,       0.0f, +1.0f, 0.0f,
//    0.0f, 0.0f, 1.0f,        0.0f, +1.0f, 0.0f,
//};


GLfloat gBasePlaneData[8*6] =
{
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,      uv, ux
    0.0f, 0.0f, 0.0f,                       0.0f, +1.0f, 0.0f,              0.0, 0.0,
    1.0f, 0.0f, 0.0f,                       0.0f, +1.0f, 0.0f,              1.0, 0.0,
    0.0f, 0.0f, 1.0f,                       0.0f, +1.0f, 0.0f,              0.0, 1.0,
    0.0f, 0.0f, 1.0f,                       0.0f, +1.0f, 0.0f,              0.0, 1.0,
    1.0f, 0.0f, 0.0f,                       0.0f, +1.0f, 0.0f,              1.0, 0.0,
    1.0f, 0.0f, 1.0f,                       0.0f, +1.0f, 0.0f,              1.0, 1.0,
};


GLfloat tileBaseData[8*6] =
{
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,      uv, ux
    0.0f, 0.0f, 0.0f,                       0.0f, 0.0f, +1.0f,              0.0, 0.0,
    1.0f, 0.0f, 0.0f,                       0.0f, 0.0f, +1.0f,              1.0, 0.0,
    0.0f, 1.0f, 0.0f,                       0.0f, 0.0f, +1.0f,              0.0, 1.0,
    0.0f, 1.0f, 0.0f,                       0.0f, 0.0f, +1.0f,              0.0, 1.0,
    1.0f, 1.0f, 0.0f,                       0.0f, 0.0f, +1.0f,              1.0, 1.0,
    1.0f, 0.0f, 0.0f,                       0.0f, 0.0f, +1.0f,              1.0, 0.0,
};

//GLfloat gLeftLegendPlaneData[6*8] =
//{
//    // positionX, positionY, positionZ,     normalX, normalY, normalZ,  texture X, texture Y
//    0.0f, 0.0f, 0.0f,       0.0f, +0.0f, 0.0f,      0.0f, 0.0f,
//    3.0f, 0.0f, 0.0f,        0.0f, +0.0f, 0.0f,     1.0f, 0.0f,
//    0.0f, 0.0f, 1.0f,        0.0f, +0.0f, 0.0f,     0.0f, 1.0f,
//    0.0f, 0.0f, 1.0f,        0.0f, +0.0f, 0.0f,     0.0f, 1.0f,
//    3.0f, 0.0f, 0.0f,        0.0f, +0.0f, 0.0f,     1.0f, 0.0f,
//    3.0f, 0.0f, 1.0f,         0.0f, +0.0f, 0.0f,    1.0f, 1.0f,
//};
//
//GLfloat gTopTextData[6*8] =
//{
//    // positionX, positionY, positionZ,     normalX, normalY, normalZ,  texture X, texture Y
//    0.0f, 0.0f, 0.0f,       0.0f, +0.0f, 0.0f,      0.0f, 0.0f,
//    1.0f, 0.0f, 0.0f,        0.0f, +0.0f, 0.0f,     1.0f, 0.0f,
//    0.0f, 0.0f, 1.0f,        0.0f, +0.0f, 0.0f,     0.0f, 1.0f,
//    0.0f, 0.0f, 1.0f,        0.0f, +0.0f, 0.0f,     0.0f, 1.0f,
//    1.0f, 0.0f, 0.0f,        0.0f, +0.0f, 0.0f,     1.0f, 0.0f,
//    1.0f, 0.0f, 1.0f,         0.0f, +0.0f, 0.0f,    1.0f, 1.0f,
//    
//    
//};

@interface WSGLTiledViewController ()
{
    GLKVector2 lastPoint;
    GLKVector2 lastPointDrag;
    
    GLuint axesVertexBuffer;
    GLuint tileVertexBuffer;
    
    WSGLTile* tile;
//    WSIndexedTile* tile2;

    GLuint vertexBuffer;
}

@property (strong, nonatomic)   EAGLContext *context;
@property (strong, nonatomic)   GLKBaseEffect *effect;

@property (strong, nonatomic)   OWNavigate* mNavigate;
@property(nonatomic, strong)    WSGenericTiledImage* img;



- (void)setupGL;
- (void)tearDownGL;


@end

@implementation WSGLTiledViewController

@synthesize context = _context;
@synthesize effect  = _effect;
@synthesize mNavigate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    VerboseLog(@"in wsgltiled");
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.preferredFramesPerSecond = 60;
    
    if(!self.context)
    {
        NSLog(@"Failed to create ES context");
        return;
    }

    self.mNavigate = [[OWNavigate alloc] init];

    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            
            NSLog(@"Rotating to Landscape %f", fabsf(self.view.bounds.size.height / self.view.bounds.size.width));
            
            [self.mNavigate setAspectRatio:fabsf(self.view.bounds.size.height / self.view.bounds.size.width)];
            //            [self.mNavigate recalculate];
            
            
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            
            NSLog(@"Rotating to Portrait %f", fabsf(self.view.bounds.size.width / self.view.bounds.size.height));
            
            [self.mNavigate setAspectRatio:fabsf(self.view.bounds.size.width / self.view.bounds.size.height)];
            //            [self.mNavigate recalculate];
            
        default:
            break;
    }
    
    [self.mNavigate toggleCameraMode];
    
    //    [mNavigate setAspectRatio:aspect];
    
    // v1 contained an array of layers here
//    self.mLayers = [[NSMutableArray alloc] init];
//    self.mLayerOpacityInterpolants = [[NSMutableArray alloc] init];
//    self.selectedObjects = [[NSMutableArray alloc] init];
//    
//    for (int i=0; i<NUMBER_OF_LAYERS; i++)
//    {
//        OWInterpolant* interp = [[OWInterpolant alloc] initWithValue:1.0f];
//        [self.mLayerOpacityInterpolants addObject:interp];
//    }
//    
//    [self loadLayersWithContext:self.context];
    
    
    
    GLKView *view   = (GLKView *)self.view;
    view.context    = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    
    
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updatePan:)];
    [panRecognizer setDelegate:self];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPanGestureRecognizer* twofingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
    [twofingerPanRecognizer setDelegate:self];
    [twofingerPanRecognizer setMinimumNumberOfTouches:2];
    [self.view addGestureRecognizer:twofingerPanRecognizer];
    
    UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomFromGestureRecognizer:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    // RMS: changed this to 3 taps since we're using a lot of 2-finger gestures to navigate
    
    [doubleTapRecognizer setNumberOfTapsRequired:3];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer* singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [singleTapRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTapRecognizer];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLayerOpacity:) name:kUpdateHorizontalSlider object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLayerOpacity:) name:kUpdateVerticalSlider object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSliderMode:) name:kToggleSliderMode object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectSingleObject:) name:kNotificationSelectSingleObject object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMetaDataForItem:) name:kNotificationShowMetaDataForItem object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearSelection:) name:kNotificationClearSelection object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetView:) name:kResetAllNotification object:nil];
    
    [self setupGL];
    
//    [self performSelector:@selector(animateToBaseEntity:) withObject:nil afterDelay:0.1];
}





- (void) updateWithEntry:(WSDataEntry*) theEntry
{
    VerboseLog();
    
    if ([theEntry.data isKindOfClass:[WSMBFImageObject class]]) {
        
#pragma todo move to async
        
        WSMBFImageObject* remoteObject = (WSMBFImageObject*)theEntry.data;
        
        WSMBFRemoteImage* imageFromEntry = [[WSMBFRemoteImage alloc] init];
        
        NSDictionary* metadataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:remoteObject.metadataURL] options:NSJSONReadingAllowFragments error:nil];
        
        imageFromEntry.baseURL = remoteObject.serverBaseURL;
        imageFromEntry.nativeSize = remoteObject.imageSize;
        imageFromEntry.tileSize = CGSizeMake(512, 512);
        imageFromEntry.url_id = remoteObject.url_id;
        

        NSData *jsonData = [metadataDict[@"zoom_map"] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSArray* json = [NSJSONSerialization
                         JSONObjectWithData:jsonData
                         options:kNilOptions
                         error:nil];
        
        imageFromEntry.zoomMap = json;
        
        NSURL* correctThumbURL = [imageFromEntry.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/tile/%@", imageFromEntry.url_id]];
        
        NSDictionary* correctThumb = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:correctThumbURL] options:NSJSONReadingAllowFragments error:nil];
        
        NSURL* newURL = [NSURL URLWithString:[[correctThumb[@"image"][@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]  stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]];
        
        imageFromEntry.thumbnailURL = newURL;
        
        imageFromEntry.z_index = 0;
        imageFromEntry.z_max = [metadataDict[@"focal_planes"] integerValue];
        
        
        imageFromEntry.maximumZoom = ceil(log(ceil((double)(MAX(imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)
                                                            / imageFromEntry.tileSize.width)))/log(2.0));
        
        
        [self loadImage:imageFromEntry];
        
    } else if ([theEntry.data isKindOfClass:[WSFileSystemObject class]])
    {
        
        WSFileSystemObject* localImageFileObject = (WSFileSystemObject*)theEntry.data;
        
        NSLog(@"Reading local image properties url at %@", localImageFileObject.url);
        
        NSDictionary* _ipx = [NSDictionary dictionaryWithXMLData:[NSData dataWithContentsOfURL:localImageFileObject.url]];
        
        WSLocalZoomifyImage* imageFromEntry = [[WSLocalZoomifyImage alloc] init];
        imageFromEntry.baseURL = [localImageFileObject.url URLByDeletingLastPathComponent];
        imageFromEntry.nativeSize = CGSizeMake([_ipx[@"_WIDTH"] integerValue], [_ipx[@"_HEIGHT"] integerValue]);
        imageFromEntry.tileSize = CGSizeMake([_ipx[@"_TILESIZE"] integerValue], [_ipx[@"_TILESIZE"] integerValue]);
        imageFromEntry.maximumZoom = ceil(log(ceil((double)(MAX(imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)
                                                            / imageFromEntry.tileSize.width)))/log(2.0));
        
        [self loadImage:imageFromEntry];

        
//        [self.imageScrollView loadImage:imageFromEntry];
        
        //        self.accessoryVC = [[WSMBFControlsViewController alloc] init];
        //        [self.view addSubview:self.accessoryVC.view];
        
        //        [self.accessoryVC configureForImage:imageFromEntry];
        
        
    }
    else if ([theEntry.data isKindOfClass:[WSRemoteHDImageObject class]])
    {
        
        NSLog(@"getting here...");
        
        WSRemoteHDImageObject* localImageFileObject = (WSRemoteHDImageObject*)theEntry.data;
        
//        NSLog(@"Reading remote image properties url at %@", localImageFileObject.url);
        
        //        NSDictionary* _ipx = [NSDictionary dictionaryWithXMLData:[NSData dataWithContentsOfURL:localImageFileObject.url]];
        
        WSLocalZoomifyImage* imageFromEntry = [[WSLocalZoomifyImage alloc] init];
        
        imageFromEntry.baseURL = localImageFileObject.url;
        
        imageFromEntry.nativeSize = localImageFileObject.imageSize;
        imageFromEntry.tileSize = CGSizeMake(256,256);
        
        //        CGSizeMake([_ipx[@"_WIDTH"] integerValue], [_ipx[@"_HEIGHT"] integerValue]);
        //        imageFromEntry.tileSize = CGSizeMake([_ipx[@"_TILESIZE"] integerValue], [_ipx[@"_TILESIZE"] integerValue]);
        
        imageFromEntry.maximumZoom = ceil(log(ceil((double)(MAX(imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)
                                                            / imageFromEntry.tileSize.width)))/log(2.0));
        
        
        [self loadImage:imageFromEntry];
        

        
    }
    else{
        NSLog(@"unmatched: %@", [theEntry.data class]);
    }
    
    
}



- (void) loadImage:(WSGenericTiledImage*) theImage
{
    tile = [WSGLTile new];

    tile.nativeSize = theImage.nativeSize;
    tile.tileSize = theImage.tileSize;
    tile.baseURL = theImage.baseURL;
    tile.level = 0;
    tile.baseView = self.view;
//
// 

    
    [tile prepareTileWithContext:self.context];
    
    
//    
//    tile2 = [[WSIndexedTile alloc] initWithZ:2
//                                                    withRow:1
//                                                    withCol:2
//                                                    fromURL:theImage.baseURL
//                                     andSize:theImage.nativeSize];
    
//    tile2 = [WSIndexedTile new];
//    tile2.baseURL = theImage.baseURL;
//    tile2.tileSize = theImage.tileSize;
//    tile2.level = 2;
//    tile2.row = 1;
//    tile2.col = 2;
    
//    [tile2 loadTextureFromURLWithContext:self.context];
    
//    tile2 = [[WSIndexedTile alloc] initWithZ:0 withRow:0 withCol:0 fromURL:Nil andSize:CGSizeMake(2000, 2000)];
    
    
    
    
    //    [self clearViews];
    //
    //    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,theImage.nativeSize.width, theImage.nativeSize.height)];
    //
    //    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
    //                                                                             theImage.nativeSize.width * self.zoomScale,
    //                                                                             theImage.nativeSize.height * self.zoomScale)];
    //
    //    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    //    [self.backgroundImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[theImage getThumbnailURL]]]];
    //
    //    [self.containerView addSubview:self.backgroundImageView];
    //
    //    self.tiledLayerView = [[WSTilingView alloc] initWithTiledImageDescription:theImage];
    //
    //    [self.containerView addSubview:self.tiledLayerView];
    //
    //    [self addSubview:self.containerView];
    //
    //    self.contentSize = self.tiledLayerView.bounds.size;
    //
    //    [self setMaxMinZoomScalesForCurrentBounds];
    //
    //    CGRect zoomRect;
    //    zoomRect.size.height = [self frame].size.height / self.minimumZoomScale;
    //    zoomRect.size.width  = [self frame].size.width / self.minimumZoomScale;
    //    zoomRect.origin.x = 0;
    //    zoomRect.origin.y = 0;
    //
    //    if (zoomRect.origin.x < 0) {
    //        zoomRect.origin.x = 0;
    //    }
    //    if (zoomRect.origin.y < 0) {
    //        zoomRect.origin.y = 0;
    //    }
    //    
    //    self.isZoomed = NO;
    //    
    //    [self zoomToRect:zoomRect animated:NO];
    //    
    
}



-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark - touch and gesture handlers

-(void) handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer*) sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            
            [mNavigate setZoomStart];
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateChanged:
            [mNavigate handleZoomScale:[sender scale]];
            break;
            
            
            
        default:
            break;
    }
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return NO;
    
    // RMS 4/2/13 -> multiple gestures leads to unusual feedforward rotations (bug)
    
    //    // starting with pan then pinch
    //    if([gestureRecognizer class] == [UIPanGestureRecognizer class] && [otherGestureRecognizer class] == [UIPinchGestureRecognizer class])
    //    {
    //        UIPanGestureRecognizer* panGR = (UIPanGestureRecognizer*)gestureRecognizer;
    //        if (panGR.minimumNumberOfTouches == 2) {
    //            // only cancel on the drag,
    //            return NO;
    //        }
    //    }
    //
    //    // evaluate opposite scenario as well
    //    if([gestureRecognizer class] == [UIPinchGestureRecognizer class] && [otherGestureRecognizer class] == [UIPanGestureRecognizer class])
    //    {
    //        UIPanGestureRecognizer* panGR = (UIPanGestureRecognizer*)otherGestureRecognizer;
    //        if (panGR.minimumNumberOfTouches == 2) {
    //            // only cancel on the drag,
    //            return NO;
    //        }
    //    }
    //
    //    // otherwise return YES for all other combinations
    //    return YES;
}

-(void) updatePan:(UIPanGestureRecognizer*)r
{
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)r translationInView:self.view];
    
    GLKVector2 translatedVec = GLKVector2Make(translatedPoint.x, translatedPoint.y);
    GLKVector2 deltaPoint = GLKVector2Subtract(translatedVec, lastPoint);
    
//    CGPoint deltaPoint = CGPointSub(translatedPoint, lastPoint);

    
    switch (r.state) {
        case UIGestureRecognizerStateBegan:
            
            lastPoint = translatedVec;
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            
            // do nothing
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            
            if( sqrtf((powf(deltaPoint.x,2) + powf(deltaPoint.y, 2))) > 3.0)
            {
                lastPoint = translatedVec;
                
                //                NSLog(@"%@ - %@", [NSValue valueWithCGPoint:translatedPoint], [NSValue valueWithCGPoint:deltaPoint]);
                
                [mNavigate handlePrimaryTouchDelta:deltaPoint withAbsolute:translatedVec];
                
                //                [mNavigate expLook:translatedPoint];
                //                if (abs(deltaPoint.x) > abs(deltaPoint.y)) {
                //
                //
                //
                //                }
                //                else
                //                {
                //
                //                }
            }
            break;
        default:
            break;
    }
    
}

-(void) handleTap:(UITapGestureRecognizer*) recognizer
{
    CGPoint tapLocation = [recognizer locationInView:[recognizer view]];
    
    NSLog(@"Tap at %@", [NSValue valueWithCGPoint:tapLocation]);
    
//    [self findObjectByPoint:tapLocation];
}

-(void) handleDoubleTap:(UITapGestureRecognizer*) recognizer
{
    
    
//    [self animateToBaseEntity:nil];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCameraSetting object:nil];
    
}

-(void) updatePosition:(id)_camera
{
}

-(void)handleShowMetaData:(id)sender
{
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowMetaDataForItem object:self.mSelectedLabel.text];
    
}


-(void) handleDragGesture:(UIPanGestureRecognizer*) r
{
    
//    CGPoint translatedPoint = [(UIPanGestureRecognizer*)r translationInView:self.view];
//    CGPoint deltaPoint = CGPointSub(translatedPoint, lastPoint);
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)r translationInView:self.view];
    
    GLKVector2 translatedVec = GLKVector2Make(translatedPoint.x, translatedPoint.y);
    GLKVector2 deltaPoint = GLKVector2Subtract(translatedVec, lastPoint);
    
    switch (r.state) {
            
        case UIGestureRecognizerStateBegan:
            
            lastPoint = translatedVec;
            
            break;
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            
            // do nothing
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            
            if( sqrtf((powf(deltaPoint.x,2) + powf(deltaPoint.y, 2))) > 3.0)
            {
                lastPoint = translatedVec;
                
                [mNavigate handleSecondaryTouchDelta:deltaPoint withAbsolute:translatedVec];
                
            }
            break;
        default:
            break;
    }}




-(void) toggleCameraMode
{
    
    [mNavigate toggleCameraMode];
    
}

-(BOOL) isCameraPill
{
    return [mNavigate isCameraPill];
}




#pragma mark - GL setup and teardown

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glEnable(GL_DEPTH_TEST);
    
    // Lighting
    self.effect = [[GLKBaseEffect alloc] init];
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
    
    self.effect.lightingType = GLKLightingTypePerPixel;
    
#warning consider performance tradeoff here
    //    self.effect.lightModelTwoSided      = YES;
    
    self.effect.material.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, alpha);
    
    
    glEnable(GL_DEPTH_TEST);
    
    
    [self allocateTileBuffer];
    [self allocateAxesBuffers];
    
    
    [self update];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &axesVertexBuffer);
    glDeleteBuffers(1, &tileVertexBuffer);
//    glDeleteBuffers(1, &vertexBuffer);
    
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    [mNavigate recalculate];
    
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(70.0f), aspect, 0.1f, 250.0f);
//    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-50, 50, -50, 50, 50, -50);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    self.effect.transform.modelviewMatrix = [self getViewMatrix];

    [tile updateMVMatrixWithViewMatrix:[self getViewMatrix]];
    
//    [tile2 updateMVMatrixWithViewMatrix:[self getViewMatrix]];
    
//    [OWInterpolant tweenAll:self.mLayerOpacityInterpolants];
    
}


-(GLKMatrix4) getViewMatrix {

    OWCamera* camera = [mNavigate getCamera];
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(camera.eye.x, camera.eye.y, camera.eye.z, camera.target.x, camera.target.y, camera.target.z, camera.up.x, camera.up.y, camera.up.z);
    
    return viewMatrix;
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    glClearColor(0.94f, 0.94f, 0.94f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    self.effect.light0.enabled = YES;

    [self drawTile];
    
    [self drawAxes];
    
//    [self drawFrame];

}


#pragma mark - XYZ Axes



- (void) allocateAxesBuffers
{
    glGenBuffers(1, &axesVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    // Vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, vertex)); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexData), (void*)offsetof(vertexData, normal)); // for model,

}


-(void) drawAxes
{
    self.effect.texture2d0.enabled = GL_FALSE;

//    glEnable(GL_BLEND);
//    glBlendFunc( GL_ONE, GL_SRC_ALPHA );
//    glDepthMask(GL_FALSE); // required to make the texture bgnd transparent...

    [self drawX];
    [self drawY];
    [self drawZ];
    
//    glDisable(GL_BLEND);
}

-(void) drawX
{
    GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
    GLKVector3 position = GLKVector3Make(8.0, 0.0, 0.0);
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(10.0,0.1,0.1);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                xRotationMatrix))));
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply([self getViewMatrix], modelMatrix);
    self.effect.material.diffuseColor = GLKVector4Make(1, 0, 0, 0.1);
    [self.effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

-(void) drawY
{
    GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
    GLKVector3 position = GLKVector3Make(0.0, 8.0, 0.0);
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(0.1, 10.0, 0.1);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                xRotationMatrix))));
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply([self getViewMatrix], modelMatrix);
    self.effect.material.diffuseColor = GLKVector4Make(0.0, 1.0, 0.0, 0.1);
    [self.effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);
}


-(void) drawZ
{
    GLKVector3 rotation = GLKVector3Make(0.0, 0.0, 0.0);
    GLKVector3 position = GLKVector3Make(0.0, 0.0, 8.0);
    GLKMatrix4 xRotationMatrix = GLKMatrix4MakeXRotation(rotation.x);
    GLKMatrix4 yRotationMatrix = GLKMatrix4MakeYRotation(rotation.y);
    GLKMatrix4 zRotationMatrix = GLKMatrix4MakeZRotation(rotation.z);
    GLKMatrix4 scaleMatrix     = GLKMatrix4MakeScale(0.1,0.1,10.0);
    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(position.x, position.y, position.z);
    GLKMatrix4 modelMatrix =
    GLKMatrix4Multiply(translateMatrix,
                       GLKMatrix4Multiply(scaleMatrix,
                                          GLKMatrix4Multiply(zRotationMatrix,
                                                             GLKMatrix4Multiply(yRotationMatrix,
                                                                                xRotationMatrix))));
    
    self.effect.transform.modelviewMatrix = GLKMatrix4Multiply([self getViewMatrix], modelMatrix);
    self.effect.material.diffuseColor = GLKVector4Make(0, 0, 1, 0.1);
    [self.effect prepareToDraw];
    
    glBindBuffer(GL_ARRAY_BUFFER, axesVertexBuffer);
    glDrawArrays(GL_TRIANGLES, 0, 36);
}




#pragma mark - draw tiles

- (void) allocateTileBuffer
{
    glGenBuffers(1, &tileVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, tileVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(tileBaseData), tileBaseData, GL_STATIC_DRAW);
    
    // Vertices
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), (void*)offsetof(vertexDataTextured, vertex)); // for model, normals, and texture
    
    // Normals
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), (void*)offsetof(vertexDataTextured, normal)); // for model,
    
// Texture
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(vertexDataTextured), (void*)offsetof(vertexDataTextured, texCoord)); // for model,
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
}

-(void) drawTile
{
    glBindBuffer(GL_ARRAY_BUFFER, tileVertexBuffer);
    
    self.effect.texture2d0.enabled = GL_TRUE;
    self.effect.texture2d0.envMode = GLKTextureEnvModeReplace;
    self.effect.texture2d0.target = GLKTextureTarget2D;
    
//    [tile2 drawWithEffect:self.effect];
    [tile drawWithEffect:self.effect];
    
    self.effect.texture2d0.enabled = GL_FALSE;
 
}


@end


