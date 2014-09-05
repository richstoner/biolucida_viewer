//
//  wsBiolucidaRemoteImageObject.m
//  Open
//
//  Created by Rich Stoner on 12/31/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsBiolucidaRemoteImageObject.h"

@implementation wsBiolucidaRemoteImageObject


-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
    NSDictionary* local_keymap = @{
                                   @"collection_id" :        @[@"collection_id", @"object"],
                                   @"url_id" :               @[@"url_id", @"object"],
                                   @"thumbnail_base" :       @[@"thumbnail_base", @"object"],
                                   @"background_base" :        @[@"background_base", @"object"],
                                   @"metadataURL" :        @[@"metadata_url", @"url"],
                                   @"serverBaseURL" :        @[@"server_base_url", @"url"],
                                   @"mpp" :                 @[@"mpp", @"object"],
                                   @"notes" :                 @[@"notes", @"array"],
                                   @"focal_spacing" :           @[@"focal_spacing", @"object"],
                                   @"z_index" :                 @[@"z_index", @"object"],
                                   @"z_max" :                 @[@"z_max", @"object"],
                                   };
    
    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}


-(NSString*) localizedName
{
    return self.title;
}


-(NSString*) localizedDescription {
    
    if ([self.z_max intValue] > 1) {
        
        float spacing_max = [self.z_max floatValue] * [self.focal_spacing floatValue];
        NSLog(@"z height: %f", spacing_max);
        
        return [NSString stringWithFormat:@"%d px x %d px, Z: 0 - %.0f µm", (int)self.nativeSize.width, (int)self.nativeSize.height, spacing_max];


    }
    
    return [NSString stringWithFormat:@"%d px x %d px", (int)self.nativeSize.width, (int)self.nativeSize.height];
}

-(NSURL*) thumbnailURL
{
//    NSLog(@"%@", self.thumbnail_base);
    return [NSURL URLWithString:self.thumbnail_base];
    
}

-(NSURL*) backgroundURL
{
//    NSLog(@"%@", self.background_base);
    return [NSURL URLWithString:self.background_base];
}

-(void) setLayerBackground:(NSURL*) pathForBaseBackground
{
    
    self.background_base = pathForBaseBackground.absoluteString;
//    
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFImageResponseSerializer serializer];
//    
//    __weak wsBiolucidaRemoteImageObject* weakSelf = self;
//    
//    [manager GET:pathForBaseBackground.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        weakSelf.background_base = [[responseObject[@"image"][@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]  stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        NSLog(@"Error: %@", error);
//        
//    }];

}

-(void) registerNotifications
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(increaseZ:) name:kNotificationIncreaseZ object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decreaseZ:) name:kNotificationDecreaseZ object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setZ:) name:kNotificationSetZ object:nil];
    
}

-(void) unregisterNotifications {
    VerboseLog();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIImage*) getImageForScale:(CGFloat)scale row:(int)row col:(int)col
{
    int z = self.maximumZoom - logf(scale)/logf(0.5);
    
    //    int tilegroup = [self tileGroupForZoom:z row:row col:col];
    
    UIImage* image = [self getImageForTileGroup:-1 zoom:z row:row col:col];
    
    return image;
}

-(UIImage*) getImageForTileGroup:(int)tilegroup zoom:(int)z row:(int)row col:(int)col
{
    NSURL* imageURL = [self.url URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/tile/%@/%d-%d-%d-%d", self.url_id, z, col, row, [self.z_index intValue]]];
    
    NSLog(@"%@", imageURL);
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    
    return image;
    
}

-(void) drawInRect:(CGRect) tileRect forScale:(CGFloat) scale row:(int)row col:(int) col
{
    
    int z = self.maximumZoom - logf(scale)/logf(0.5);
    
    UIImage* tile = [self getImageForTileGroup:-1 zoom:z row:row col:col];
    
    if (tile) {
        [tile drawInRect:tileRect];
    }
    else{
        //        NSLog(@"correct map, nil");
    }
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
    
#define USE_SMALL_THUMBNAIL 1
    
#if USE_SMALL_THUMBNAIL
    
    return self.thumbnailURL;
    
#else
    
    NSURL* imageURL = [self.baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/tile/%@/0-0-0", self.url_id]];
    
    return imageURL;
    
#endif
    
    
}

-(void) increaseZ:(NSNotification*) notification {
    
    if ([self.z_index intValue] == ([self.z_max intValue] -1)) {
        
        //        self.z_index = 0;
    }
    else{
        self.z_index = @([self.z_index intValue] + 1);
    }

    if ([self.delegate respondsToSelector:@selector(renderObjectHasData:)]) {
        [self.delegate renderObjectHasData:self];
    }
}

-(void) decreaseZ:(NSNotification*) notification {
    
    if (self.z_index == 0) {

    }
    else{
        self.z_index = @([self.z_index intValue] - 1);
    }

    if ([self.delegate respondsToSelector:@selector(renderObjectHasData:)]) {
        [self.delegate renderObjectHasData:self];
    }

}


-(void) setZ:(NSNotification*) notification {
    
    NSNumber* numZ = [notification object];
    
    if ([numZ intValue] < [self.z_max intValue]) {
        self.z_index = numZ;
    }
    
    if ([self.delegate respondsToSelector:@selector(renderObjectHasData:)]) {
        

        [self.delegate renderObjectHasData:self];
    }
    
    
    NSLog(@"update z %@", self.z_index);
    
}


@end
