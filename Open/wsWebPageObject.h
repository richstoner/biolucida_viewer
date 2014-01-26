//
//  wsWebPageObject.h
//  Open
//
//  Created by Rich Stoner on 1/20/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsDataObject.h"
#import "wsWebServerObject.h"

@interface wsWebPageObject : wsDataObject

/**

 */
@property (strong, readonly) NSURL* url;

/**
 Self explanatory (user defined name).
 */
@property (strong, nonatomic) NSString* title;

@property (strong, nonatomic) NSString* description;

@property(nonatomic, strong) wsWebServerObject* server;

@property(nonatomic, strong) NSString* basePath;

@property(nonatomic, strong) NSURL* fullURL;

@end
