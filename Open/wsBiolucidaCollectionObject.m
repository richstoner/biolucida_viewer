//
//  wsBiolucidaCollectionObject.m
//  Open
//
//  Created by Rich Stoner on 12/30/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsBiolucidaCollectionObject.h"
#import "wsBiolucidaRemoteImageObject.h"

@implementation wsBiolucidaCollectionObject

@synthesize server;


-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
//    NSDictionary* local_keymap = @{
//                                   @"relativePath" :  @[ @"relative_path", @"object"],
//                                   @"server" :        @[@"server", @"wsObject"]
//                                   };

//    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}



// we just need to return this object in an array
-(NSArray*) collections {
    return @[self];
}

-(void) initializeCollection
{
    VerboseLog();
    
    self.fontAwesomeIconString = fa_folder_o;
    
    if (self.server) {
        
        // server exists, tell interface to at least load
        if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
            [self.delegate collectionObjectHasNewSections:self];
        }
        
        [self getImagesForPath:self.relativePath];
    }
    
}

-(void) refreshAsCurrentCollection {
    VerboseLog();
    
    self.originalIndexList = [self validIndexPaths];
    
    [self getImagesForPath:self.relativePath];
}


-(void) refreshAsNewCollection {

    VerboseLog();

    self.originalIndexList = [self validIndexPaths];
    
    // server exists, tell interface to at least load

    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
    
    // then try to get an updated list of images
    
    [self getImagesForPath:self.relativePath];
    
}








-(void) removeImagesForCollection
{
    NSMutableArray *discardedItems = [NSMutableArray array];
    
    for (wsObject* obj in self.children) {
        
        if ([obj isKindOfClass:[wsBiolucidaRemoteImageObject class]]) {
            [discardedItems addObject:obj];
        }
    }
    
    [self.children removeObjectsInArray:discardedItems];
}




-(NSArray*) getImagesForPath:(NSString*) thePath
{
    VerboseLog();
    
    // set the original index set before we attempt to modify it
    self.originalIndexList = [self validIndexPaths];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURL* serverPath = [self.server.url URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/slides/0/30%@", thePath]];
    
    [manager GET:serverPath.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* allImagesDictionary = (NSDictionary*) responseObject;
        
        NSMutableArray* rows = [[NSMutableArray alloc] init];
        
        if ([allImagesDictionary[@"status"] isEqualToString:@"success"]) {
            
            for (NSDictionary* imageDictionary in allImagesDictionary[@"images"]) {

                wsBiolucidaRemoteImageObject* rio = [wsBiolucidaRemoteImageObject new];
                rio.url_id = imageDictionary[@"url"];
                
                NSURL* metadataURL = [self.server.url URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/image/%@", rio.url_id]];
                
                rio.metadataURL = metadataURL;
                
                NSDictionary *metadataDict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:metadataURL] options:0 error:nil];

                rio.title = imageDictionary[@"title"];
                rio.description = imageDictionary[@"description"];
                rio.nativeSize = CGSizeMake([imageDictionary[@"width"] integerValue],
                                           [imageDictionary[@"height"] integerValue]);
                rio.collection_id =imageDictionary[@"collection_id"];
                rio.tileSize = CGSizeMake([metadataDict[@"tile_x"] floatValue], [metadataDict[@"tile_y"] floatValue]);
                rio.mpp = metadataDict[@"mpp"];
                rio.focal_spacing = metadataDict[@"focal_spacing"];
                rio.z_max = metadataDict[@"focal_planes"];
                rio.z_index = @0;
                
                rio.url = self.server.url;
                
                rio.thumbnail_base = [[imageDictionary[@"thumbnail"] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]  stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                
                [rio setLayerBackground:[self.server.url URLByAppendingPathComponent:[NSString stringWithFormat:@"api/v1/tile/%@", rio.url_id]]];
                
                [rows addObject:rio];
            }
            
            [self removeImagesForCollection]; // smarter me would find a way to keep this, rather than cacheing
            
            [self addChildren:rows];
            
            if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewItems:)]) {
                [self.delegate collectionObjectHasNewItems:self];
            }
            
        }
        else{
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    return nil;
}



@end
