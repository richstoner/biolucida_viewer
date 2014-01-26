//
//  wsBiolucidaRemoteImageObject.h
//  Open
//
//  Created by Rich Stoner on 12/31/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsRemoteImageObject.h"

@interface wsBiolucidaRemoteImageObject : wsRemoteImageObject

//@property (strong, nonatomic) NSString* title; -> declared in wsImageObject

//@property (strong, nonatomic) NSString* description; -> declared in wsImageObject

@property (strong, nonatomic) NSNumber* collection_id;

@property (strong, nonatomic) NSNumber* url_id;

@property (strong, nonatomic) NSString* thumbnail_base;

@property (strong, nonatomic) NSString* background_base;

@property (strong, nonatomic) NSURL* metadataURL;

@property (strong, nonatomic) NSURL* serverBaseURL;

//@property (strong, nonatomic) UIColor* backgroundColor;

// extra metadata

@property(nonatomic, strong) NSArray* zoomMap;

@property(nonatomic, strong) NSDictionary* metaData;

@property(nonatomic, strong) NSNumber* mpp;

@property(nonatomic, strong) NSArray* notes;

@property(nonatomic, strong) NSNumber* focal_spacing;


// state variables

@property(nonatomic, strong) NSNumber* z_index;

@property(nonatomic, strong) NSNumber* z_max;



-(void) setLayerBackground:(NSURL*) pathForBaseBackground;

@end
