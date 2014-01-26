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


#import "WSTilingView.h"
#import "wsImageObject.h"
#import "wsBiolucidaRemoteImageObject.h"

@interface WSTilingView ()
{

}

@property(nonatomic, strong) wsImageObject* img;

@end

@implementation WSTilingView

@synthesize img;

+ (Class)layerClass {
	return [FastCATiledLayer class];
}



-(id) initWithImageObject:(wsImageObject*) imageObject
{
        
    self = [super initWithFrame:CGRectMake(0, 0, imageObject.nativeSize.width, imageObject.nativeSize.height)];
    
    if (self) {
        // Custom initialization
        
        self.img = imageObject;
        self.img.delegate = self;

        FastCATiledLayer *tiledLayer = (FastCATiledLayer *)[self layer];
        tiledLayer.tileSize = self.img.tileSize;
        tiledLayer.levelsOfDetail = self.img.maximumZoom;
        
        
    }
    return self;
}



-(void)renderObjectHasData:(wsRenderObject *)collectionObject
{
//    VerboseLog();
    
    [self refreshTiles];
    
}

-(void) refreshTiles
{
    CATiledLayer *tiledLayer = (CATiledLayer *)[self layer];
    tiledLayer.tileSize = CGSizeMake(1,1);//Set a different tile size
    tiledLayer.tileSize = self.img.tileSize;//Restore original tile size
    
    [self setNeedsDisplayInRect:self.bounds];
}


- (void)didReceiveMemoryWarning
{
    VerboseLog();
}

- (void)drawRect:(CGRect)rect {
    
    VerboseLog();
    
 	CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationDefault);  
    double scale = CGContextGetCTM(context).a;
    
    if(context && self.img)
    {
        scale = (1.0 / round(1.0 / scale));
        
        FastCATiledLayer *tiledLayer = (FastCATiledLayer *)[self layer];
        CGSize tileSize = tiledLayer.tileSize;
        
        tileSize.width /= scale;
        tileSize.height /= scale;
        
        // calculate the rows and columns of tiles that intersect the rect we have been asked to draw

        int firstCol = floorf(CGRectGetMinX(rect) / tileSize.width);
        int lastCol = floorf((CGRectGetMaxX(rect)-1) / tileSize.width);
        
        int firstRow = floorf(CGRectGetMinY(rect) / tileSize.height);
        int lastRow = floorf((CGRectGetMaxY(rect)-1) / tileSize.height);
        
        for (int row = firstRow; row <= lastRow; row++) {
            for (int col = firstCol; col <= lastCol; col++) {
                
                CGRect tileRect = CGRectMake(tileSize.width * col, tileSize.height * row, tileSize.width, tileSize.height);
                                      
                if(scale <= 1)
                {                
                    tileRect.size.width += 1.0/scale;
                    tileRect.size.height += 1.0/scale;
                }
                else
                {
                    tileRect.size.width += 1.0;
                    tileRect.size.height += 1.0;
                    
                }
                        
                tileRect = CGRectIntersection(self.bounds, tileRect);
                
            
                [self.img drawInRect:tileRect forScale:scale row:row col:col];
                
//                [self.img drawLayer:<#(CALayer *)#> inContext:context];
                
            }
        }
        
    }
}


@end
