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

#import "UIImageView+AFNetworking.h"
#import "wsRemoteImageObject.h"
#import "wsBiolucidaRemoteImageObject.h"
#import "WSImageScrollView.h"
#import "WSTilingView.h"
#import "wsImageObject.h"

#define kControlWidth 200.0

@interface WSImageScrollView ()  <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    
}

@property(nonatomic, strong) wsImageObject* imageObject;

@property(nonatomic, strong) UIView* containerView;
@property(nonatomic, strong) WSTilingView* tiledLayerView;
@property(nonatomic, strong) UIImageView* backgroundImageView;

@property(nonatomic, readwrite) CGRect lastFrame;
@property(nonatomic, readwrite) BOOL isZoomed;

@end

@implementation WSImageScrollView

- (id)init
{
    self = [super init];
    if (self) {
        
        VerboseLog();

        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        self.isZoomed = NO;
        self.lastFrame = CGRectZero;
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        [doubleTap setNumberOfTapsRequired:2];
        [self addGestureRecognizer:doubleTap];

        
    }
    return self;
}

-(void) registerNotifications {
    VerboseLog(@"%@", self.imageObject.localizedName);
    
    [self.imageObject registerNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveTo:) name:kNotificationAdjustTileView object:nil];
}

-(void) unregisterNotifications {

    VerboseLog(@"%@", self.imageObject.localizedName);
    
    [self.imageObject unregisterNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    zoomRect.size.height = [self frame].size.height / scale;
    zoomRect.size.width  = [self frame].size.width / scale;
    zoomRect.origin.x    = center.x / self.zoomScale - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y / self.zoomScale  - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {

    CGPoint localPoint = [gestureRecognizer locationInView:self.containerView];
    CGPoint adjustedLocal = CGPointApplyAffineTransform(localPoint, CGAffineTransformMakeScale(self.zoomScale, self.zoomScale));
    
    if (self.isZoomed) {
        [self zoomToRect:self.lastFrame animated:YES];
        self.isZoomed = NO;
    }
    else
    {
        self.isZoomed = YES;
        self.lastFrame = [self zoomRectForScale:[self zoomScale] withCenter:adjustedLocal];
        CGRect zoomRect = [self zoomRectForScale:self.maximumZoomScale withCenter:adjustedLocal];
        [self zoomToRect:zoomRect animated:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer*) gestureRecognizer{
    
    switch ([gestureRecognizer state]) {
        case UIGestureRecognizerStateBegan:
//            NSLog(@"%@", [NSValue valueWithCGPoint:[gestureRecognizer locationInView:_tiledLayerView]]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"longPressGest" object:nil];

            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateEnded:
            
            break;
        case UIGestureRecognizerStateFailed:
            
            break;
        case UIGestureRecognizerStateChanged:
            
            break;
        case UIGestureRecognizerStatePossible:
            
            break;
        default:
            break;
    }
}

- (void)zoomFit:(NSNotification*) notification
{    
    self.isZoomed = NO;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.zoomScale = self.minimumZoomScale;                            
                     }
                     completion:^(BOOL finished){
                     }]; 
}

- (void)zoomX:(NSNotification*) notification
{
    self.isZoomed = NO;
    NSNumber* zoomXScale = [notification object];
    float newScale = [zoomXScale floatValue];
    self.zoomScale = newScale;    
}

- (void) moveTo:(NSNotification *) notification
{
//    VerboseLog(@"%@", self.imageObject.localizedName);
    
    CGPoint pointFromThumbnail = [(NSValue*)[notification object] CGPointValue];
    float updated_x = self.contentSize.width*pointFromThumbnail.x/ kThumbnailWidth;
    float updated_y =  self.contentSize.height*pointFromThumbnail.y/ kThumbnailHeight;
    CGPoint newCenter = CGPointMake(updated_x, updated_y);
    float newScale = [self zoomScale];
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:newCenter];
    [self zoomToRect:zoomRect animated:YES];
}

- (void) zoomTo:(NSNotification *) notification
{    
    if ([[notification name] isEqualToString:@"zoomTo"])
    {
        CGRect zoomRect = [(NSValue*) [notification object] CGRectValue];
        [self zoomToRect:zoomRect animated:YES];
    }
}

#pragma mark -
#pragma mark Override layoutSubviews to center content

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.containerView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.containerView.frame = frameToCenter;
    
    if ([self.containerView isKindOfClass:[WSTilingView class]]) {
        self.containerView.contentScaleFactor = 1.0;
    }
}

#pragma mark -
#pragma mark UIScrollView delegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.containerView;
}


#pragma mark -
#pragma mark Configure scrollView to display new image (tiled or not)

- (void) loadImageObject:(wsImageObject*) theObject
{
    self.imageObject = theObject;
    
//    VerboseLog(@"Loading image with type: %@", [self.imageObject class]);
    
    // first clear view if already present
    [self clearViews];
    
    // init the outer container view
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.imageObject.nativeSize.width, self.imageObject.nativeSize.height)];
    
//    NSLog(@"Container Frame: %@", [NSValue valueWithCGRect:self.containerView.frame]);
    
    self.containerView.backgroundColor = kTabActiveBackgroundColor;
    
    // setup the background thumbnail view
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
                                                                             self.imageObject.nativeSize.width * self.zoomScale,
                                                                             self.imageObject.nativeSize.height * self.zoomScale)];
    
    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    if ([self.imageObject respondsToSelector:@selector(backgroundURL)]) {
        
        NSURL* backGroundURL = [self.imageObject performSelector:@selector(backgroundURL)];
        
        // added async thumbnail request with block-based background update
        NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:backGroundURL];
        
        [thumbnailRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
        __weak WSImageScrollView *weakSelf = self;
        
        [self.backgroundImageView setImageWithURLRequest:thumbnailRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            //        NSLog(@"landing here... %@", [NSValue valueWithCGSize:image.size]  );
            
            // setting the background color based on image content
//            weakSelf.backgroundImageView.backgroundColor =
            weakSelf.backgroundColor = [weakSelf getBackgroundColorForImage:image];
//            weakSelf.superview.backgroundColor = weakSelf.backgroundImageView.backgroundColor;
            weakSelf.backgroundImageView.image = image;
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
            
            
        }];
    }
    

    
    [self.containerView addSubview:self.backgroundImageView];
    
    self.tiledLayerView = [[WSTilingView alloc] initWithImageObject:self.imageObject];

    [self.containerView addSubview:self.tiledLayerView];
    
    [self addSubview:self.containerView];
    
    self.contentSize = self.tiledLayerView.bounds.size;
    

    VerboseLog(@"%@", [NSValue valueWithCGSize:self.contentSize]);
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    CGRect zoomRect;
    zoomRect.size.height = round(self.frame.size.height / self.minimumZoomScale);
    zoomRect.size.width  = round(self.frame.size.width / self.minimumZoomScale);
    zoomRect.origin.x = 0;
    zoomRect.origin.y = 0;
    
    if (zoomRect.origin.x < 0) {
        zoomRect.origin.x = 0;
    }
    if (zoomRect.origin.y < 0) {
        zoomRect.origin.y = 0;
    }
    
    
    self.isZoomed = NO;
    
    [self zoomToRect:zoomRect animated:NO];

}





- (UIColor*) getBackgroundColorForImageAtURL:(NSURL*) theURL
{
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:theURL]];
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const u_int8_t* data = CFDataGetBytePtr(pixelData);
    
    int pixOO = 0;
    int pix11 = ((image.size.width  * image.size.height) * 4) - 4;
    
    u_int8_t red_0 = data[pixOO];
    u_int8_t green_0 = data[pixOO+1];
    u_int8_t blue_0 = data[pixOO+2];
    u_int8_t alpha_0 = data[pixOO+3];
    
    u_int8_t red_1 = data[pix11];
    u_int8_t green_1 = data[pix11+1];
    u_int8_t blue_1 = data[pix11+2];
    u_int8_t alpha_1 = data[pix11+3];
    CFRelease(pixelData);
    
    float red = (float)(red_0 + red_1) / 2.0;
    float green = (float)(green_0 + green_1) / 2.0;
    float blue = (float)(blue_0 + blue_1) / 2.0;
    float alpha = (float)(alpha_0 + alpha_1) / 2.0;
    
//    NSLog(@"Background average: %f %f %f", red, green, blue);
    
    UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    
    return color;
}

- (UIColor*) getBackgroundColorForImage:(UIImage*) theImage
{
//    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:theURL]];
    VerboseLog(@"%@", theImage);
    
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(theImage.CGImage));
    const u_int8_t* data = CFDataGetBytePtr(pixelData);
    
    int pixOO = 0;
    int pix11 = ((theImage.size.width  * theImage.size.height) * 4) - 4;
    
    u_int8_t red_0 = data[pixOO];
    u_int8_t green_0 = data[pixOO+1];
    u_int8_t blue_0 = data[pixOO+2];
    u_int8_t alpha_0 = data[pixOO+3];
    
    u_int8_t red_1 = data[pix11];
    u_int8_t green_1 = data[pix11+1];
    u_int8_t blue_1 = data[pix11+2];
    u_int8_t alpha_1 = data[pix11+3];
    CFRelease(pixelData);
    
    float red = (float)(red_0 + red_1) / 2.0;
    float green = (float)(green_0 + green_1) / 2.0;
    float blue = (float)(blue_0 + blue_1) / 2.0;
    float alpha = (float)(alpha_0 + alpha_1) / 2.0;
    
//    NSLog(@"%f %f %f", red, green, blue);
    
    UIColor* color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f]; // The pixel color info
    
    return color;
}


//- (void) loadImage:(WSGenericTiledImage*) theImage
//{
//    
//    VerboseLog();
//    
//    [self clearViews];
//    
//    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,theImage.nativeSize.width, theImage.nativeSize.height)];
//    
//    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
//                                                                             theImage.nativeSize.width * self.zoomScale,
//                                                                             theImage.nativeSize.height * self.zoomScale)];
//    
//    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
//    
////    [self.backgroundImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[theImage getThumbnailURL]]]];
//    
//    // added async thumbnail request with block-based background update
//    NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:[theImage getThumbnailURL]];
//    [thumbnailRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    __weak WSImageScrollView *weakSelf = self;
//    
//    [self.backgroundImageView setImageWithURLRequest:thumbnailRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//    
////        NSLog(@"Request finished");
//        weakSelf.backgroundImageView.backgroundColor = [weakSelf getBackgroundColorForImage:image];
//        weakSelf.superview.backgroundColor = weakSelf.backgroundImageView.backgroundColor;
//        weakSelf.backgroundImageView.image = image;
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//        
//        
//    }];
//
//    
//    [self.containerView addSubview:self.backgroundImageView];
//    
////    self.backgroundImageView.backgroundColor = [self getBackgroundColorForImage:self.backgroundImageView.image];
//  
//    self.backgroundColor = self.backgroundImageView.backgroundColor;
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
//    
//}



- (void) clearViews
{
    [self.tiledLayerView removeFromSuperview];
    self.tiledLayerView = nil;
    
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    
    [self.containerView removeFromSuperview];
    self.containerView = nil;
}


//- (void) loadImageFromMBFRemoteEntry:(WSDataObject*) theEntry
//{
//    
//    VerboseLog();
//    
//    WSMBFImageObject* remoteObject = (WSMBFImageObject*)theEntry;
//    
//    WSMBFRemoteImage* imageFromEntry = [[WSMBFRemoteImage alloc] init];
//    
//    NSDictionary* metadataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:remoteObject.metadataURL] options:NSJSONReadingAllowFragments error:nil];
//
//    imageFromEntry.baseURL = remoteObject.serverBaseURL;
//    imageFromEntry.nativeSize = remoteObject.imageSize;
//    imageFromEntry.tileSize = CGSizeMake(512, 512);
//    imageFromEntry.url_id = remoteObject.url_id;
//    
//    
//    NSURL* correctThumbURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@api/v1/tile/%@", imageFromEntry.baseURL, imageFromEntry.url_id]];
//    
//    NSDictionary* correctThumb = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:correctThumbURL] options:NSJSONReadingAllowFragments error:nil];
//
//    NSURL* newURL = [NSURL URLWithString:[[correctThumb[@"image"][@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]  stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]];
//    
//    imageFromEntry.thumbnailURL = newURL;
//    imageFromEntry.z_index = 0;
//    imageFromEntry.z_max = [metadataDict[@"focal_planes"] integerValue];
//    
//    imageFromEntry.maximumZoom = ceil(log(ceil((double)(MAX(imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)
//                                                        / imageFromEntry.tileSize.width)))/log(2.0));
//    
//    
//    
//    
//    
//    [self clearViews];
//    
//    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)];
//    
//    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
//                                                                             imageFromEntry.nativeSize.width * self.zoomScale,
//                                                                             imageFromEntry.nativeSize.height * self.zoomScale)];
//    
//    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
//    
//    // added async thumbnail request with block-based background update
//    NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:[imageFromEntry getThumbnailURL]];
//    [thumbnailRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    __weak WSImageScrollView *weakSelf = self;
//    [self.backgroundImageView setImageWithURLRequest:thumbnailRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        
//        weakSelf.backgroundImageView.backgroundColor = [weakSelf getBackgroundColorForImage:image];
//        weakSelf.superview.backgroundColor = weakSelf.backgroundImageView.backgroundColor;
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//        
//        
//    }];
//
//    
////    [self.backgroundImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[imageFromEntry getThumbnailURL]]]];
////    self.backgroundImageView.backgroundColor = [self getBackgroundColorForImage:self.backgroundImageView.image];
////    self.superview.backgroundColor =     self.backgroundImageView.backgroundColor;
//    
//    [self.containerView addSubview:self.backgroundImageView];
//    
//    self.tiledLayerView = [[WSTilingView alloc] initWithTiledImageDescription:imageFromEntry];
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
//}

//- (void) loadImageFromImageProperties:(NSURL*) theURL
//- (void) loadImageFromFileEntry:(WSDataObject*) theEntry
//{
//    VerboseLog();
//
//    WSFileSystemObject* localImageFileObject = (WSFileSystemObject*)theEntry;
//    
//    NSLog(@"Reading local image properties url at %@", localImageFileObject.url);
//    NSDictionary* _ipx = [NSDictionary dictionaryWithXMLData:[NSData dataWithContentsOfURL:localImageFileObject.url]];
//    
//    [self clearViews];
//    
//    
//#pragma todo move this initialization into wslocalzoomify image class
//    
//    WSLocalZoomifyImage* imageFromEntry = [[WSLocalZoomifyImage alloc] init];
//    imageFromEntry.baseURL = [localImageFileObject.url URLByDeletingLastPathComponent];
//    imageFromEntry.nativeSize = CGSizeMake([_ipx[@"_WIDTH"] integerValue], [_ipx[@"_HEIGHT"] integerValue]);
//    imageFromEntry.tileSize = CGSizeMake([_ipx[@"_TILESIZE"] integerValue], [_ipx[@"_TILESIZE"] integerValue]);
//    imageFromEntry.maximumZoom = ceil(log(ceil((double)(MAX(imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)
//                                                                                           / imageFromEntry.tileSize.width)))/log(2.0));
//    
//    
//    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,imageFromEntry.nativeSize.width, imageFromEntry.nativeSize.height)];
//    
//    self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,
//                                                                        imageFromEntry.nativeSize.width * self.zoomScale,
//                                                                        imageFromEntry.nativeSize.height * self.zoomScale)];
//
//    [self.backgroundImageView setContentMode:UIViewContentModeScaleAspectFit];
//    
//    
//    // added async thumbnail request with block-based background update
//    NSMutableURLRequest *thumbnailRequest = [NSMutableURLRequest requestWithURL:[imageFromEntry getThumbnailURL]];
//    [thumbnailRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
//    __weak WSImageScrollView *weakSelf = self;
//    [self.backgroundImageView setImageWithURLRequest:thumbnailRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//        
//        weakSelf.backgroundImageView.backgroundColor = [weakSelf getBackgroundColorForImage:image];
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//        
//        
//    }];
//    
////    [self.backgroundImageView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[imageFromEntry getThumbnailURL]]]];
//    
//    
//    
//    
//    self.backgroundColor =     self.backgroundImageView.backgroundColor;
//
//    [self.containerView addSubview:self.backgroundImageView];
//
//    self.tiledLayerView = [[WSTilingView alloc] initWithTiledImageDescription:imageFromEntry];
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
//}


- (void) resetZoom
{
    self.zoomScale = self.minimumZoomScale;
    [self sendNewPosition];
}




- (void)setMaxMinZoomScalesForCurrentBounds
{
//    NSLog(@"tiledlayer frame: %@", [NSValue valueWithCGRect:self.tiledLayerView.frame]);
//    NSLog(@"tiledlayer bounds:  %@", [NSValue valueWithCGRect:self.tiledLayerView.bounds]);
    
    CGSize imageSize = self.imageObject.nativeSize;
    CGSize boundsSize = self.bounds.size;
    
//    NSLog(@"%@ %@", [NSValue valueWithCGSize:imageSize], [NSValue valueWithCGSize:boundsSize]);
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    
//    NSLog(@"%f %f", xScale, yScale);
    
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    CGFloat maxScale;

    maxScale = 1.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
//    NSLog(@"%f %f", minScale, maxScale);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    
}

- (void) setMaxMinZoomScalesForCurrentBoundsRotate
{
    CGSize imageSize = self.tiledLayerView.bounds.size;
    CGSize boundsSize = self.bounds.size;
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    CGFloat minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    CGFloat maxScale;
    
    maxScale  = 1.0;
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.) 
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;

}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

// returns the center point, in image coordinate space, to try to restore after rotation. 
- (CGPoint)pointToCenterAfterRotation
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

    return [self convertPoint:boundsCenter toView:self.containerView];
}


- (CGFloat)scaleToRestoreAfterRotation
{
    CGFloat contentScale = self.zoomScale;

    if (contentScale <= self.minimumZoomScale + FLT_EPSILON)
        contentScale = 0;
    
    return contentScale;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

// Adjusts content offset and scale to try to preserve the old zoomscale and center.
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale
{    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    self.zoomScale = MIN(self.maximumZoomScale, MAX(self.minimumZoomScale, oldScale));
    
    CGPoint boundsCenter = [self convertPoint:oldCenter fromView:self.containerView];
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0, 
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
    offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
    
    self.contentOffset = offset;
}


-(void) sendNewPosition
{
//    NSMutableArray * toSend = [[NSMutableArray alloc] initWithCapacity:5];
//    [toSend addObject:[NSNumber numberWithFloat:self.zoomScale]];
    
    CGPoint centerPoint = [self pointToCenterAfterRotation];
    float bounds_center_x = centerPoint.x;
    float bounds_center_y = centerPoint.y;
    
    float maximum_bound_width = self.bounds.size.width/self.zoomScale;
    float maximum_bound_height = self.bounds.size.height/self.zoomScale;
    
    float viewport_aspect_ratio = maximum_bound_width/maximum_bound_height;
    float image_aspect_ratio = self.containerView.frame.size.width / self.containerView.frame.size.height;
    
    float bounds_static_center_x = (self.bounds.size.width/self.minimumZoomScale)/2;
    float bounds_static_center_y = (self.bounds.size.height/self.minimumZoomScale)/2;
    
//    NSLog(@"vp: %f AR: %f", viewport_aspect_ratio, image_aspect_ratio);
    
    NSValue* toSend;
    
    if (image_aspect_ratio < 1) {
        
        float standard_length = self.containerView.bounds.size.height;
        
        float bounds_max_x = 2*bounds_static_center_x;
        float bounds_max_y = 2*bounds_static_center_y;
        
        float difference_x = (bounds_max_x - self.containerView.bounds.size.width)/2;
        float difference_y = (bounds_max_y - self.containerView.bounds.size.height)/2;
        
        float new_bounds_center_x = bounds_center_x + difference_x;
        float new_bounds_center_y = bounds_center_y + difference_y;
        
        float n_translate_x = (bounds_static_center_x - new_bounds_center_x)/standard_length;
        float n_translate_y = (bounds_static_center_y - new_bounds_center_y)/standard_length;
        
        float width_norm_distance = maximum_bound_width / standard_length;
        float height_norm_distance = maximum_bound_height / standard_length;
//        
//        [toSend addObject:[NSNumber numberWithFloat:n_translate_x]];
//        [toSend addObject:[NSNumber numberWithFloat:n_translate_y]];
//        [toSend addObject:[NSNumber numberWithFloat:width_norm_distance]];
//        [toSend addObject:[NSNumber numberWithFloat:height_norm_distance]];

        toSend = [NSValue valueWithCGRect:CGRectMake(n_translate_x, n_translate_y, width_norm_distance, height_norm_distance)];
    }
    else
    {
        // this is not.
        
        float standard_length = self.containerView.bounds.size.width;
        float bounds_max_x = 2*bounds_static_center_x;
        float bounds_max_y = 2*bounds_static_center_y;
        
        float difference_x = (bounds_max_x - self.containerView.bounds.size.width)/2;
        float difference_y = (bounds_max_y - self.containerView.bounds.size.height)/2;
        
        float new_bounds_center_x = bounds_center_x + difference_x;
        float new_bounds_center_y = bounds_center_y + difference_y;
        
        float n_translate_x = (bounds_static_center_x - new_bounds_center_x)/standard_length;
        float n_translate_y = (bounds_static_center_y - new_bounds_center_y)/standard_length;
        
        float width_norm_distance = maximum_bound_width / standard_length;
        float height_norm_distance = maximum_bound_height / standard_length;
        
//        [toSend addObject:[NSNumber numberWithFloat:n_translate_x]];
//        [toSend addObject:[NSNumber numberWithFloat:n_translate_y]];
//        [toSend addObject:[NSNumber numberWithFloat:width_norm_distance]];
//        [toSend addObject:[NSNumber numberWithFloat:height_norm_distance]];
//        
        toSend = [NSValue valueWithCGRect:CGRectMake(n_translate_x, n_translate_y, width_norm_distance, height_norm_distance)];
    }
    

    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdatePosition object:toSend];
}




-(void) scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self sendNewPosition];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self sendNewPosition];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self sendNewPosition];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self sendNewPosition];
}



@end
