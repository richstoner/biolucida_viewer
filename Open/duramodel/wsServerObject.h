//
//  wsServerObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsCollectionObject.h"

/**
 The base class for all server objects. The server produces collections of wsobjects. Making it a subclass of collectionobject makes sense...
 */
@interface wsServerObject : wsCollectionObject

/**
 A default URL for this server. The child class will determine how it is intepreted. It should however response to a get request.
 */
@property (strong, nonatomic) NSURL* url;

/**
 Self explanatory (user defined name).
 */
@property (strong, nonatomic) NSString* title;

/**
 A local png file used to represent this object
 */
@property(nonatomic, strong) NSString* localIconString;

/**
 A username used to access this resource, if necessary
 */
@property (strong, nonatomic) NSString* username;

/**
 A password needed to access this resource, if necessary
 */
@property (strong, nonatomic) NSString* password;


#pragma mark - async calls



@end
