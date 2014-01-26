//
//  wsBiolucidaCollectionObject.h
//  Open
//
//  Created by Rich Stoner on 12/30/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

// consider, for this to be portable, it has to contain the server object as well

#import "wsCollectionObject.h"
#import "wsBiolucidaServerObject.h"

@interface wsBiolucidaCollectionObject : wsCollectionObject

/**
 The server configuration needed to access this collection (folder)
 */
@property(nonatomic, strong) wsBiolucidaServerObject* server;

/**
 The relative path where this collection exists
 */
@property(nonatomic, strong) NSString* relativePath;

@end
