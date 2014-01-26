//
//  WSEMVolumeBrowserViewController.m
//  Open
//
//  Created by Rich Stoner on 12/2/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSGLBrowserViewController.h"
#import "OWNavigate.h"

#import "WSGLAxesObject.h"


#import "WSGLLabelViewController.h"
#import "wsDefaultViewsAccessoryViewController.h"

@interface WSGLBrowserViewController () <wsRenderObjectDelegate, wsAccessoryDelegate>
{
    GLKVector2  lastPoint;
    GLKVector2  lastPointDrag;
    GLKVector3  lastTouchObject;
    BOOL        hasTouch;
    int         selectedObjectIndex;

}

@property (strong, nonatomic)   EAGLContext *context;
@property (strong, nonatomic)   GLKBaseEffect *effect;
@property (strong, nonatomic)   OWNavigate* mNavigate;

@property (strong, nonatomic)   NSMutableArray* renderObjects;

@property (strong, nonatomic)   WSGLAxesObject* referenceAxes;

@property (strong, nonatomic)   NSMutableArray* accessoryViews;
@property (strong, nonatomic)   NSMutableArray* entryHistory;

- (void)setupGL;
- (void)tearDownGL;


@end

@implementation WSGLBrowserViewController

@synthesize context = _context;
@synthesize effect  = _effect;

@synthesize mNavigate;


#pragma mark - Init -

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
        self.accessoryViews = [NSMutableArray new];
        self.entryHistory = [NSMutableArray new];
        
        // the axes rendered in the control view
        self.referenceAxes  = [WSGLAxesObject new];
        [self.referenceAxes setLayerID:reserveredLayerIDAxes];
        
        self.renderObjects = [NSMutableArray new];
        [self addAxes];

        self.view.backgroundColor = [UIColor blackColor];
        
        
    }
    return self;
}

#pragma mark - Notifications

-(void) registerNotifications
{
    VerboseLog();
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpenSelection:) name:kNotificationOpenSelection object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectNext:) name:kNotificationSelectNext object:nil];
}

-(void) unregisterNotifications
{
    VerboseLog();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(wsObject*) getCurrentObject
{
    if (lastTouchObject.x >= reserveredLayerIDOffset)
    {
        wsRenderObject* selected = [self.renderObjects objectAtIndex:((int)lastTouchObject.x - reserveredLayerIDOffset - 1)];
        return selected;
    }
    return nil;
}



-(void) handleOpenSelection:(id)sender
{
    
    
    if (lastTouchObject.x >= reserveredLayerIDOffset)
    {
        wsRenderObject* selected = [self.renderObjects objectAtIndex:((int)lastTouchObject.x - reserveredLayerIDOffset - 1)];

        if ([selected respondsToSelector:@selector(newObjectFromSelection)]) {
            
            wsRenderObject* newObject = [selected performSelector:@selector(newObjectFromSelection)];
            
            if (newObject)
            {
                selected.shouldHide = YES;
            }
            
            [self.renderObjects addObject:newObject];
            
            [self renderObjectSelectionChanged:newObject];
        }
        
    }
    
}


-(void) handleSelectNext:(id) sender
{
    VerboseLog();
    
    selectedObjectIndex++;
    
    if (selectedObjectIndex == self.renderObjects.count) {
        selectedObjectIndex =0;
    }
    
    for (wsRenderObject* ro in self.renderObjects) {
        ro.shouldHide = YES;
    }
    
    wsRenderObject* ro = self.renderObjects[selectedObjectIndex];
    ro.shouldHide = NO;

    if (ro) {
        lastTouchObject = GLKVector3Make(ro.layerID, 0, 0);
    
        for (WSGLAccessoryViewController* view  in self.accessoryViews) {
            
            
            [view updateWithObject:ro];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) updateWithObject:(wsRenderObject*) theObject
{
    VerboseLog(@"Adding object to viewer");
    
    [self.renderObjects addObject:theObject];
    
}

-(void)renderObjectHasData:(wsRenderObject *)renderObject
{
    [self.mNavigate goToBounds:renderObject.boundingBox withUrgency:0.05];
}

-(void) renderObjectSelectionChanged:(wsRenderObject *)renderObject
{
    for (WSGLAccessoryViewController* view  in self.accessoryViews) {
        if ([renderObject respondsToSelector:@selector(positionString)]) {
            
            [view updatePositionString:[renderObject performSelector:@selector(positionString)]];
            
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    VerboseLog();
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    self.pauseOnWillResignActive = YES;
    self.preferredFramesPerSecond = 30;
    
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
            
            break;
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            
            NSLog(@"Rotating to Portrait %f", fabsf(self.view.bounds.size.width / self.view.bounds.size.height));
            [self.mNavigate setAspectRatio:fabsf(self.view.bounds.size.width / self.view.bounds.size.height)];
            
            break;
        default:
            break;
    }
    
    [self.mNavigate toggleCameraMode];
    
    GLKView *view   = (GLKView *)self.view;
    view.context    = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    
    
    WSGLLabelViewController* accessoryView = [[WSGLLabelViewController alloc] init];
    accessoryView.delegate = self;
    [self.accessoryViews addObject:accessoryView];
    [self.view addSubview:accessoryView.view];
    [self addChildViewController:accessoryView];
    
    wsDefaultViewsAccessoryViewController* defaultViewsViewController = [wsDefaultViewsAccessoryViewController new];
    defaultViewsViewController.delegate = self;
    [self.accessoryViews addObject:defaultViewsViewController];
    [self.view addSubview:defaultViewsViewController.view];
    [self addChildViewController:defaultViewsViewController];
    



//    UIDynamicAnimator *dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
//    
//    // Create a gravity behavior
//    UIGravityBehavior *gravity1 = [[UIGravityBehavior alloc] initWithItems:@[accessoryView.view]];
//    [gravity1 setAngle:0.0 magnitude:0.5];
//    [dynamicAnimator addBehavior:gravity1];

    
//    WSGLEMAccessoryViewController* emControlView = [[WSGLEMAccessoryViewController alloc] init];
//    [emControlView setDelegate:self];
//    [self.view addSubview:emControlView.view];
//    [self.accessoryViews addObject:emControlView];

    
    
    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(updatePan:)];
    [panRecognizer setDelegate:self];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];
    
//    UIPanGestureRecognizer* twofingerPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDragGesture:)];
//    [twofingerPanRecognizer setDelegate:self];
//    [twofingerPanRecognizer setMinimumNumberOfTouches:2];
//    [self.view addGestureRecognizer:twofingerPanRecognizer];
    
    UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleZoomFromGestureRecognizer:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
//    
//    UITapGestureRecognizer* doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
//    
//    [doubleTapRecognizer setNumberOfTapsRequired:2];
//    [self.view addGestureRecognizer:doubleTapRecognizer];
    
    
    [self setupGL];

}


-(void) viewDidAppear:(BOOL)animated
{
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        NSLog(@"rotating to portrait");
    }
    else
    {
        NSLog(@"rotating to landscape");
    }
    
    for (WSGLAccessoryViewController* vc in self.accessoryViews) {
        [vc updateLayoutForOrientation:self.interfaceOrientation];
    }
    
}


#pragma mark - GL setup and teardown -

- (void)setupGL
{
    
    
    [EAGLContext setCurrentContext:self.context];
    
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
    self.effect.material.ambientColor = GLKVector4Make(0.2, 0.2, 0.2, alpha);
    
    
    [self.mNavigate animateToPolarCoords:-M_PI_2 andPhi:0];

    
    [self update];
}


- (void) addAxes
{
    WSGLAxesObject* axes = [WSGLAxesObject new];
    [axes setLayerID:reserveredLayerIDAxes];
    [self.renderObjects addObject:axes];

}


- (void) refreshDataSource
{
    VerboseLog();
    
    // trigger update
    [self update];
    
}

- (void)tearDownGL
{
    VerboseLog();
    
    for (wsRenderObject* ro in self.renderObjects) {
        [ro tearDownGL];
    }
    
    [self.renderObjects removeAllObjects];
    
    self.effect = nil;
    
    self.context = nil;
    
    [EAGLContext setCurrentContext:nil];
}







#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect;
    CGRect vpRect = [self getRectForViewport];
    aspect = fabsf(vpRect.size.width / vpRect.size.height);
    
    [self.mNavigate setAspectRatio:aspect];
    [self.mNavigate  recalculate];
    
    
    GLKMatrix4 pm = [self getProjectionMatrix];
    GLKMatrix4 vm = [self getViewMatrix];
    
    GLKMatrix4 refM = [self getReferenceMatrix];
    GLKMatrix4 refPM = [self getReferenceProjectionMatrix];
    
    self.effect.transform.projectionMatrix = pm;
    self.effect.transform.modelviewMatrix = vm;
    
    for (wsRenderObject* renderObject in self.renderObjects){
    
        if (renderObject.delegate == nil) {

            NSLog(@"initializing %@", renderObject.class);
            
            if ([renderObject isKindOfClass:[WSGLAxesObject class]]) {
                [renderObject setLayerID:reserveredLayerIDAxes];
            }
            else{
                [renderObject setLayerID:self.renderObjects.count + reserveredLayerIDOffset];
            }
            
            [renderObject prepareWithContext:self.context];
            
        
            
            if([renderObject respondsToSelector:@selector(setRenderDelegateAndLoad:)])
            {
                [renderObject performSelector:@selector(setRenderDelegateAndLoad:) withObject:self];
            }
            else
            {
                [renderObject setDelegate:self];
            }
            
            [renderObject setParentProjectionMatrix:pm];
            [renderObject updateMVPMatrix:vm];
        }
        else
        {
            
            [renderObject setParentProjectionMatrix:pm];
            [renderObject updateMVPMatrix:vm];
            

        }
    }
    
    if (self.referenceAxes) {
        
        if (self.referenceAxes.delegate == nil) {
            
            [self.referenceAxes prepareWithContext:self.context];
            [self.referenceAxes setDelegate:self];
            [self.referenceAxes setParentProjectionMatrix:refPM];
            [self.referenceAxes updateMVPMatrix:refM];
            
        }
        else
        {
         
            [self.referenceAxes setParentProjectionMatrix:refPM];
            [self.referenceAxes updateMVPMatrix:refM];
        }
    }

}



- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self renderNormal];
    
    
}


-(void) renderNormal
{

    CGRect ref_vp = [self getRectForReference];
        CGRect vp = [self getRectForViewport];
    glViewport(vp.origin.x, vp.origin.y, vp.size.width, vp.size.height);

//    glClearColor(39.0/255.0, 40.0/255.0, 34.0/255.0, 1.0f);
//    glClearColor(k3DBackgroundColor.red, k3DBackgroundColor.green, k3DBackgroundColor.blue, 1.0f);
    
    
    glClearColor(15.0/255.0, 15.0/255.0, 15.0/255.0, 1.0f);

    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if (hasTouch) {

        for (wsRenderObject* ro in self.renderObjects) {
            [ro renderWithTouch:lastTouchObject];
        }
        
    }
    else if (lastTouchObject.x >= reserveredLayerIDOffset)
    {
        wsRenderObject* selected = [self.renderObjects objectAtIndex:((int)lastTouchObject.x - reserveredLayerIDOffset - 1)];
        
        for (wsRenderObject* ro in self.renderObjects) {
            
            if([ro isEqual:selected])
            {
                [ro renderWithHighlight];
            }
            else
            {
                [ro render];
            }
        }

        
    }
    else{

        for (wsRenderObject* ro in self.renderObjects) {
            [ro render];
        }

        
    }
    
    
    glViewport(ref_vp.origin.x, ref_vp.origin.y, ref_vp.size.width, ref_vp.size.height);
    glScissor(ref_vp.origin.x, ref_vp.origin.y, ref_vp.size.width, ref_vp.size.height);
    glEnable(GL_SCISSOR_TEST);
    
    glClearColor(5.0/255.0, 5.0/255.0, 5.0/255.0, 1.0f);

    glClear(GL_COLOR_BUFFER_BIT);

    if (self.referenceAxes){
        
        [self.referenceAxes renderWithTouch:lastTouchObject];
    }
    
    glDisable(GL_SCISSOR_TEST);

}

-(void) renderSelect
{
    CGRect vp = [self getRectForViewport];
    
//    CGRect ref_vp = [self getRectForReference];
    
    glViewport(vp.origin.x, vp.origin.y, vp.size.width, vp.size.height);

    glClearColor(0.0, 0.0, 0.0, 1.0f);

    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    for (wsRenderObject* ro in self.renderObjects) {
        [ro renderSelect];
    }
}


#pragma mark - Properties -

-(CGRect) getRectForViewport
{
    int scale = (int)[UIScreen mainScreen].scale;
    
    
    
    if (IS_IPAD) {
        
        if (self.view.frame.size.height > 800) {
            
            // portrait
            return CGRectMake(0, k3DToolBarHeight*scale, 768*scale, (self.view.frame.size.height - k3DToolBarHeight)*scale);
            
        }
        else{
            return CGRectMake(0, 0, scale*(self.view.frame.size.width - k3DToolBarWidth), scale*self.view.frame.size.height);
        }
        
        
    }
    
    return CGRectZero;
}

-(CGRect) getRectForReference
{
    
    int scale = (int)[UIScreen mainScreen].scale;

    
    if (IS_IPAD) {
        
        if (self.view.frame.size.height > 800) {
            
            // portrait
            return CGRectMake(scale*(self.view.frame.size.width - k3DToolBarWidth), 0, scale*k3DToolBarWidth, scale*k3DToolBarHeight);
            
        }
        else{
            
            return CGRectMake(scale*(self.view.frame.size.width - k3DToolBarWidth), 0, scale*k3DToolBarWidth, scale*k3DToolBarHeight);
        }
        
        
    }
    
    return CGRectZero;
}

-(GLKMatrix4) getViewMatrix {
    
    OWCamera* camera = [mNavigate getCamera];
    
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(camera.eye.x, camera.eye.y, camera.eye.z, camera.target.x, camera.target.y, camera.target.z, camera.up.x, camera.up.y, camera.up.z);
    
    return viewMatrix;
}

-(GLKMatrix4) getReferenceMatrix {
    
    OWCamera* camera = [mNavigate getCamera];
    
    GLKVector3 normEyeTimesScalar =  GLKVector3MultiplyScalar(GLKVector3Normalize(camera.eye), 5);
    
    GLKVector3 newtarget = GLKVector3Make(0, 0, 0);
    
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(normEyeTimesScalar.x, normEyeTimesScalar.y, normEyeTimesScalar.z, newtarget.x, newtarget.y, newtarget.z, camera.up.x, camera.up.y, camera.up.z);
    
    
//    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(camera.eye.x, camera.eye.y, camera.eye.z, camera.target.x, camera.target.y, camera.target.z, camera.up.x, camera.up.y, camera.up.z);
//    
    return viewMatrix;
}

-(GLKMatrix4) getProjectionMatrix {
    
    CGRect vpRect = [self getRectForViewport];
    
    float aspect = fabsf(vpRect.size.width / vpRect.size.height);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f), aspect, 1.0f, 200);
    
    return projectionMatrix;
}

-(GLKMatrix4) getReferenceProjectionMatrix {
    
    CGRect vpRect = [self getRectForReference];
    
    float aspect = fabsf(vpRect.size.width / vpRect.size.height);
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(35.0f), aspect, 1.0f, 200);
    
    return projectionMatrix;
}

#pragma mark - ViewController methods -

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        NSLog(@"rotating to portrait");
    }
    else
    {
        NSLog(@"rotating to landscape");
    }
    
    for (WSGLAccessoryViewController* vc in self.accessoryViews) {
        [vc updateLayoutForOrientation:self.interfaceOrientation];
    }
    
}

#pragma mark - Touch and gesture handlers -

//-(void) segmentedControlSelect:(UISegmentedControl*) control
//{
//    NSLog(@"%ld", (long)control.selectedSegmentIndex);
//}

-(void) handleZoomFromGestureRecognizer:(UIPinchGestureRecognizer*) sender
{
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            
            [mNavigate setZoomStart];
            
            break;
            
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateEnded:
            
            hasTouch = NO;
            break;
            
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


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // to prevent issues with toolbar items in accessory classes
    if ([touch.view.superview isKindOfClass:[UIToolbar class]]) {
        return NO;
    }
    return YES;
}


//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
//    // Disallow recognition of tap gestures in the TabbarItem control.
//    if ([touch.view isKindOfClass:[UIBarButtonItem class]]) {//change it to your condition
//        NSLog(@"tag %d", touch.view.tag);
////        if ([touch.view.tag != 50])
////             return NO;
//        }
//    return YES;
//
//}
//             

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }

    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return YES;
    }
    
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



-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    VerboseLog();
    hasTouch = touches.count > 0;
    
    if (touches.count == 1) {
        
        UITouch* touch = (UITouch*)[touches anyObject];
//        NSLog(@"%@ - %@", touch.view.superview.class, touch.view.class);
        
        if ([touch.view.superview isKindOfClass:[UIToolbar class]]) {

            
        }
        else
        {
            CGPoint location = [touch locationInView:touch.view];
            lastTouchObject = [self findObjectByPoint:location];
        
            if (lastTouchObject.x >= reserveredLayerIDOffset) {

                wsRenderObject* ro = [self.renderObjects objectAtIndex:((int)lastTouchObject.x - reserveredLayerIDOffset - 1)];
                
                for (WSGLAccessoryViewController* view  in self.accessoryViews) {
                    
                    
                    [view updateWithObject:ro];
                }

                
            }
            else{
                
                for (WSGLAccessoryViewController* view  in self.accessoryViews) {
                    
                    [view updateWithObject:nil];
                }
            }
            
        }
    }
}

//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    if (touches.count == 1) {
//        
//        UITouch* touch = (UITouch*)[touches anyObject];
//        //        NSLog(@"%@ - %@", touch.view.superview.class, touch.view.class);
//        
//        if ([touch.view.superview isKindOfClass:[UIToolbar class]]) {
//        }
//        else
//        {
//            
////            CGPoint location = [touch locationInView:touch.view];
////            lastTouchObject = [self findObjectByPoint:location];
//        }
//    }
//    
//}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    hasTouch = touches.count == 0;
}




-(void) updatePan:(UIPanGestureRecognizer*)r
{
//    VerboseLog();
    CGPoint translatedPoint = [r translationInView:self.view];
    CGPoint tapLocation = [r locationInView:[r view]];
    
    // current point
    GLKVector2 currentLocation = GLKVector2Make(tapLocation.x, tapLocation.y);
    
    // change since start
    GLKVector2 translatedVec = GLKVector2Make(translatedPoint.x, translatedPoint.y);

    // original point
    GLKVector2 originalLocation = GLKVector2Subtract(currentLocation, translatedVec);
    
    // change since last update
    GLKVector2 deltaPoint = GLKVector2Subtract(translatedVec, lastPoint);
    
    switch (r.state) {
        case UIGestureRecognizerStateBegan:
            
            lastPoint = translatedVec;
            
            break;

        case UIGestureRecognizerStateEnded:
            
            hasTouch = NO;
            break;

        case UIGestureRecognizerStateCancelled:

        case UIGestureRecognizerStateFailed:
            break;
            
        case UIGestureRecognizerStatePossible:
            break;
            
        case UIGestureRecognizerStateChanged:
            
            if( sqrtf((powf(deltaPoint.x,2) + powf(deltaPoint.y, 2))) > 1.0)
            {
                lastPoint = translatedVec;
                

                if (lastTouchObject.x != reserveredLayerIDClear) {
                    
                    
                    wsRenderObject* ro = [self.renderObjects objectAtIndex:((int)lastTouchObject.x - reserveredLayerIDOffset - 1)];
                    
                    
                    
//                    NSLog(@"%@, %f", self.renderObjects, lastTouchObject.x);
//                    GLKVector3 cameraLookAtVec = GLKVector3Subtract([self.mNavigate getCamera].target, [self.mNavigate getCamera].eye);

                    [ro handleTouchForSelection:lastTouchObject
                                     withSource:GLKVector2Make(originalLocation.x, self.view.frame.size.height - originalLocation.y)
                                       andDelta:GLKVector2Make(translatedVec.x, -1* translatedVec.y)];
                }
                else
                {
                    [mNavigate handlePrimaryTouchDelta:deltaPoint withAbsolute:translatedVec];

                }
                
            }
            break;
        default:
            break;
    }
    
}

//-(BOOL) isNavigation
//{
//    return self.segmentedControl.selectedSegmentIndex == 0;
//}


-(void) handleTap:(UITapGestureRecognizer*) recognizer
{
    
    CGPoint tapLocation = [recognizer locationInView:[recognizer view]];
//    NSLog(@"Tap at %@", [NSValue valueWithCGPoint:tapLocation]);
    [self findObjectByPoint:tapLocation];
}

-(void) handleDoubleTap:(UITapGestureRecognizer*) recognizer
{
    
//    NSLog(@"dtap");
    VerboseLog();
//    
//    WSEMVolume* volume;
//    for (WSGeneric3DObject* obj in self.renderObjects) {
//        if ([obj isKindOfClass:[WSEMVolume class]]) {
//            volume = (WSEMVolume*)obj;
//            [volume randomizeSelection];
//        }
//    }
    
}



-(void) handleDragGesture:(UIPanGestureRecognizer*) r
{
    VerboseLog();
    //    CGPoint translatedPoint = [(UIPanGestureRecognizer*)r translationInView:self.view];
    //    CGPoint deltaPoint = CGPointSub(translatedPoint, lastPoint);
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)r translationInView:self.view];
    
    GLKVector2 translatedVec = GLKVector2Make(translatedPoint.x, translatedPoint.y);
    GLKVector2 deltaPoint = GLKVector2Subtract(translatedVec, lastPoint);
    
    switch (r.state) {
            
        case UIGestureRecognizerStateBegan:
            
            lastPoint = translatedVec;
            
            break;

        case UIGestureRecognizerStateEnded:
            
            hasTouch = NO;
            break;

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            
            // do nothing
            
            break;
            
        case UIGestureRecognizerStateChanged:
            
            
            if( sqrtf((powf(deltaPoint.x,2) + powf(deltaPoint.y, 2))) > 1.0)
            {
                lastPoint = translatedVec;
                
                [mNavigate handleSecondaryTouchDelta:deltaPoint withAbsolute:translatedVec];
                
            }
            break;
        default:
            break;
    }}


#pragma mark - RO Delegates -


-(void) volumeLoadedWithBounds:(wsBounds *)boundingBox
{
    NSLog(@"volume loaded");
    
//    [self.mNavigate goToForEntity:boundingBox withUrgency:0.05];
}

#pragma mark - Control Delegates -

- (void) performAction:(defaultButtonAction) theAction
{
    VerboseLog(@"action: %d", theAction);
    
    
    switch (theAction) {
            
        case defaultButtonActionAnimateToViewLeft:
            
            [self.mNavigate animateToPolarCoords:-M_PI_2 andPhi:0];

            break;
            
        case defaultButtonActionOpenSelectedInCurrentTab:
            
//            [self openSelectedObjectHere];
            
            break;
            
        case defaultButtonActionAnimateToViewTop:
            
            [self.mNavigate animateToPolarCoords:M_PI andPhi:1];
            
            break;
            
        case defaultButtonActionAnimateToViewBottom:
            
            [self.mNavigate animateToPolarCoords:M_PI andPhi:-1];
            
            break;
        
        case defaultButtonActionAnimateToViewRight:
            
            [self.mNavigate animateToPolarCoords:M_PI_2 andPhi:0];
            
            break;
            
        case defaultButtonActionAnimateToViewFront:

            [self.mNavigate animateToPolarCoords:0 andPhi:0];
            
            break;
            
        case defaultButtonActionAnimateToViewBack:
            
            [self.mNavigate animateToPolarCoords:M_PI andPhi:0];

            
            break;
            
            
        case defaultButtonActionGoBackWithinTab:
            
//            [self goToPreviousEntry];
            
            break;
            
            
            
        default:
            break;
    }
    
    
    
}


-(void) openSelectedObjectHere
{
    // figure out what we currently have (e.g. volume, cube, etc)
    
        // self.currentEntry -> what is the current class type
    
//    NSLog(@"Starting class: %@", self.currentEntry.class);
    
    // figure out if we have a selection
    
        // lastobject -> which RenderObject in stack,
    
//    NSLog(@"Last object index: %@", GLKVector3IntString(lastTouchObject));
    
//    NSLog(@"Corresponding render object: %@", self.renderObjects[(int)lastTouchObject.x]);
    
    // what should the selection open as (e.g volume -> cube)
    
        // currently undefined
    
    
    // what should happen to the existing object? should we keep a previous entry stack in case we want to go back?
    
    
//    
//    if ([self.currentEntry isKindOfClass:[WSOCPRemoteObject class]]) {
//
//        WSEMVolume* volume;
//        for (WSGeneric3DObject* obj in self.renderObjects) {
//            if ([obj isKindOfClass:[WSEMVolume class]]) {
//                volume = (WSEMVolume*)obj;
//            }
//        }
//        
//        //        WSDataEntry* container = [WSDataEntry new];
//        WSOCPRemoteObject* remoteObject = (WSOCPRemoteObject*)self.currentEntry;
//        WSOCPCubeObject* cubeObject = [WSOCPCubeObject new];
//
//        GLKVector3 origin = GLKVector3Make(remoteObject.cubeSize.x*volume.select_x, remoteObject.cubeSize.y*volume.select_y, remoteObject.cubeSize.z*volume.select_z);
//        GLKVector3 size = remoteObject.cubeSize;
//        GLKVector3 extent = GLKVector3Add(origin, size);
//        NSString* cubeURL = [NSString stringWithFormat:@"%@npz/1/%d,%d/%d,%d/%d,%d/", remoteObject.baseURL.absoluteString, (int)origin.x, (int)extent.x, (int)origin.y, (int)extent.y, (int)origin.z, (int)extent.z];
//
//        NSLog(@"%@", cubeURL );
//
//        cubeObject.baseURL = [NSURL URLWithString:cubeURL];
//        cubeObject.username = remoteObject.username;
//        cubeObject.password = remoteObject.password;
//        cubeObject.useJP2 = remoteObject.useJP2;
//        cubeObject.cubeSize = remoteObject.cubeSize;
//        cubeObject.title = [NSString stringWithFormat:@"%04d-y%04d-z%04d", volume.select_x,volume.select_y, volume.select_z];
//
//        //        container.data = cubeObject;
//        [self goToEntry:cubeObject];
////        [[NSNotificationCenter defaultCenter] postNotificationName:cubeObject.notificationString object:cubeObject];
//        
//    }
//
//    
//
//    
//    
//    
//    if ([self.currentEntry isKindOfClass:[WSKnossosRemoteObject class]]) {
//        
//        //        WSDataEntry* container = [WSDataEntry new];
//        WSKnossosRemoteObject* remoteObject = (WSKnossosRemoteObject*)self.currentEntry;
//        
//        WSKnossosCubeObject* cubeObject = [WSKnossosCubeObject new];
//        
//        //    NSString* filename_string = [remoteObject.baseURL lastPathComponent];
//        NSString* extensionStr;
//        if (remoteObject.useJP2) {
//            extensionStr = @"6.jp2";
//        }
//        else
//        {
//            extensionStr=@"raw";
//        }
//        
//        NSLog(@"%@", extensionStr);
//  
////        //    NSLog(@"%@", filename_string);
////
//        
//#warning NEED TO implement a better way to handle renderobject selection give that we'll have multiple.
//        
//        WSEMVolume* volume;
//        for (WSGeneric3DObject* obj in self.renderObjects) {
//            if ([obj isKindOfClass:[WSEMVolume class]]) {
//                volume = (WSEMVolume*)obj;
//            }
//        }
//        
//        NSString* filename_string = [NSString stringWithFormat:@"%@_x%04d_y%04d_z%04d.%@", volume.volumeDescription[@"name"], volume.select_x, volume.select_y, volume.select_z, extensionStr];
//        
//        NSURL* fullURL = [((WSKnossosRemoteObject*)self.currentEntry).baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"x%04d/y%04d/z%04d/%@", volume.select_x, volume.select_y, volume.select_z, filename_string]];
//        
//        
////        //    NSLog(@"%@", fullURL);
//
//        cubeObject.baseURL = fullURL;
//        cubeObject.username = remoteObject.username;
//        cubeObject.password = remoteObject.password;
//        cubeObject.useJP2 = remoteObject.useJP2;
//        cubeObject.cubeSize = remoteObject.cubeSize;
//        cubeObject.title = [NSString stringWithFormat:@"x%04d_y%04d_z%04d", volume.select_x, volume.select_y, volume.select_z];
//        
//        
//        
//        [self goToEntry:cubeObject];
//        
//        
////        self.currentEntry = cubeObject;
////        
////        [self refreshDataSource];
//
//        //        container.data = cubeObject;
//
////        [[NSNotificationCenter defaultCenter] postNotificationName:cubeObject.notificationString object:cubeObject];
//        
//    }
}

//-(void) goToPreviousEntry {

//    // make sure we have a history to go back to
//    if (self.entryHistory.count > 0) {
//        
//        if([[self.entryHistory lastObject] isEqual:self.currentEntry])
//        {
//            
//            NSLog(@"odd, shouldn't be identical... check add method");
//        }
//        else
//        {
//            self.currentEntry = [self.entryHistory lastObject];
//            [self.entryHistory removeLastObject];
//            
//            [self refreshDataSource];
//        }
//    }
//}

//-(void) goToEntry:(WSDataObject*) theEntry {
////    
////    [self.entryHistory addObject:self.currentEntry];
////    self.currentEntry = theEntry;
////    [self refreshDataSource];
//}



- (GLKVector3)findObjectByPoint:(CGPoint)point
{
    [self setPaused:YES];
    
    // working view port
    GLsizei height = (GLsizei)((GLKView *)self.view).drawableHeight;
    GLsizei width = (GLsizei)((GLKView *)self.view).drawableWidth;
    
    // open-3d only renders a small region to FBO ... smart, but requires additional matrix math to adjust 'effective zoom'
    
//    NSInteger actualHeight = 20;
//    NSInteger actualWidth = 20;
    
    // bytes to store data in ... may need to make larger
    
    Byte pixelColor[4] = {0,};
    GLuint colorRenderbuffer;
    GLuint depthRenderBuffer;
    GLuint framebuffer;
    
    
    glEnable(GL_DEPTH_TEST);

    // create framebruffer & render buffer
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);

    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER, colorRenderbuffer);

    // added depth buffer to resolve picking issues
    // ref: http://stackoverflow.com/questions/4378182/whats-wrong-with-using-depth-render-buffer-opengl-es-2-0
    
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        
        NSLog(@"Framebuffer status: %x", (int)status);
        return GLKVector3Make(0, 0, 0);
    }
    else
    {
//        NSLog(@"Offscreen FB created okay");
    }
    
// off screen buffer created, now perform render using updated matrices
    
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    
    [self renderSelect];
    
    CGFloat scale = self.view.contentScaleFactor;
    
    // get 1 pixel, modify for larger selection region to scan
    glReadPixels(point.x * scale, (height - (point.y * scale)), 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixelColor);
    
    int roValue = (int)(pixelColor[0]) ; // -> 64 / 256
    int layerValue = (pixelColor[1]);
    int objValue = (pixelColor[2]);

    GLKVector3 selection = GLKVector3Make(roValue, layerValue, objValue);
    
//    struct glSelection selection;
//    selection.ro = roValue;
//    selection.layer = layerValue;
//    selection.object = objValue;
    
//    NSLog(@"RenderObject %d, Layer %d, DrawGroup/Object %d", (int)selection.x, (int)selection.y, (int)selection.z);
    
//    if (layerValue != 255) {
//        
//#pragma mark TODO -> BUG HERE that crashes the simulator due to array sizing
////        OWLayer* selectedLayer = (OWLayer*)[self.mLayers objectAtIndex:layerValue];
////        OWDrawGroup* selectedDG = [selectedLayer.drawGroups objectAtIndex:dgValue];
////        OWDraw* selectedDraw = [selectedDG.draws objectAtIndex:dValue];
////        NSLog(@"Selected %@", selectedDraw.geometry);
////        
////        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSelectSingleObject object:selectedDraw.geometry];
//        
//    }
//    else
//    {
////        [[NSNotsificationCenter defaultCenter] postNotificationName:kNotificationClearSelection object:nil];
//    }
    
#define SAVE_IMAGES 1
    
#if SAVE_IMAGES
    
    NSInteger x = 0, y = 0;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, width, height), iref);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    
    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/lastTap.jpg"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];
    
    //    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Test.jpg"];
    
    // Write a UIImage to JPEG with minimum compression (best quality)
    // The value 'image' must be a UIImage object
    // The value '1.0' represents image compression quality as value from 0.0 to 1.0

    
    // Write image to PNG
//    [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    
    // Let's check to see if files were successfully written...
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    // Create file manager
    //    NSError *error;
    //    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //
    //    // Point to Document directory
    //    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //
    //    // Write out the contents of home directory to console
    //    NSLog(@"Documents directory: %@", [fileMgr contentsOfDirectoryAtPath:documentsDirectory error:&error]);
    
#endif
    
    glDeleteRenderbuffers(1, &colorRenderbuffer);
    glDeleteFramebuffers(1, &framebuffer);
    glDeleteRenderbuffers(1, &depthRenderBuffer);
    
    [self setPaused:NO];
    
    return selection;
    
}



-(void) toggleCameraMode
{
    [mNavigate toggleCameraMode];
}

-(BOOL) isCameraPill
{
    return [mNavigate isCameraPill];
}





@end
