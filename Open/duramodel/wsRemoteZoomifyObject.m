//
//  wsRemoteZoomifyObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsRemoteZoomifyObject.h"

@interface wsRemoteZoomifyObject ()
{
    
}

@end

@implementation wsRemoteZoomifyObject


- (id)init
{
    self = [super init];
    if (self) {
        self.tileSize = CGSizeMake(256, 256);
        self.nativeSize = CGSizeMake(0, 0);
    }
    return self;
}


-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
    NSDictionary* local_keymap = @{
                                   @"thumbnail_base" :        @[@"thumbnail_base", @"url"],
                                   };
    
    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}





-(NSURL*) thumbnailURL
{
    return self.thumbnail_base;
}


-(NSURL*) backgroundURL
{
    return self.thumbnail_base;
}


-(void) enableNotifications {

}

-(void) disableNotifications {
    VerboseLog();
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(UIImage*) getImageForScale:(CGFloat)scale row:(int)row col:(int)col
{
    int z = self.maximumZoom - logf(scale)/logf(0.5);
    
    int tilegroup = [self tileGroupForZoom:z row:row col:col];
    
    UIImage* image = [self getImageForTileGroup:tilegroup zoom:z row:row col:col];
    
    return image;
    
    
}

-(void) drawImageAsyncForScale:(CGFloat)scale row:(int)row col:(int)col inRect:(CGRect)theRect
{
    
    int z = self.maximumZoom - logf(scale)/logf(0.5);
    
    int tilegroup = [self tileGroupForZoom:z row:row col:col];

    NSURL* imageURL = [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"TileGroup%d/%d-%d-%d.jpg", tilegroup, z, col, row]];

    AFHTTPRequestOperation *getImageOperation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:imageURL]];
    getImageOperation.responseSerializer = [AFImageResponseSerializer serializer];

    [getImageOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[UIImage class]]) {
            
            UIImage* img = (UIImage*)responseObject;
            [img drawInRect:theRect];
            
        }
        
//        [tile drawInRect:theRect];
        
//        NSLog(@"Response: %@", responseObject);
        //        _imageView.image = responseObject;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
  
    [getImageOperation start];

}

-(NSURL*) getTileURLforIndex:(GLKVector3) theIndex
{
    return [self getImageURLForZoom:(int)theIndex.x row:(int)theIndex.z col:(int)theIndex.y];
}


-(UIImage*) getImageForZoom:(int)z row:(int)row col:(int)col
{
    int tileGroup = [self tileGroupForZoom:z row:row col:col];
    
    NSURL* imageURL = [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"TileGroup%d/%d-%d-%d.jpg", tileGroup, z, col, row]];
    
    NSLog(@"%@", imageURL);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    

    
    return image;
}


-(NSURL*) getImageURLForZoom:(int)z row:(int)row col:(int)col
{
    int tileGroup = [self tileGroupForZoom:z row:row col:col];
    
    NSURL* imageURL = [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"TileGroup%d/%d-%d-%d.jpg", tileGroup, z, col, row]];
    
    return imageURL;
}


-(UIImage*) getImageForTileGroup:(int)tilegroup zoom:(int)z row:(int)row col:(int)col
{
    NSURL* imageURL = [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"TileGroup%d/%d-%d-%d.jpg", tilegroup, z, col, row]];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    
    return image;
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

-(NSURL*) getThumbnailURL {
    
    NSURL* imageURL = [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"TileGroup0/0-0-0.jpg"]];
    
    return imageURL;
    
}


-(void) drawInRect:(CGRect) tileRect forScale:(CGFloat) scale row:(int)row col:(int) col
{

//    [self drawImageAsyncForScale:scale row:row col:col inRect:tileRect];
    
    
    
//    
//    // load photo images in the background
//    __weak wsRemoteZoomifyObject *weakSelf = self;
//    
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // then set them via the main queue if the cell is still visible.
//            
////            if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
//            
////                WSCollectionViewItemCell* cell =
////                (WSCollectionViewItemCell*)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
////                
////                wsImageObject* io = (wsImageObject*) obj;
////                [cell.imageView setImageWithURL:io.thumbnailURL];
//            
//            }
//        });
//    }];
//    
//    operation.queuePriority = (indexPath.item == 0) ?
//    NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
//    
//    [self.thumbnailQueue addOperation:operation];
//
    
    
    UIImage* tile = [self getImageForScale:scale row:row col:col];
    
    if (tile) {
        [tile drawInRect:tileRect];
    }
    else{
        //        NSLog(@"correct map, nil");
    }
    
}


@end
