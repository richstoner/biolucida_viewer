//
//  wsObject.h
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface wsObject : NSObject

#pragma mark - what does 'open' mean to this object

/**
 DB id
 */
@property(nonatomic, strong) NSNumber* databaseID;

/**
 The default UI action when you select this item.
 */
@property(nonatomic, strong) NSString* notificationString;


#pragma mark - any child objects that this object contains

/**
 An array of other WSDataobjects
 */
@property (nonatomic, strong) NSMutableArray* children;


#pragma mark - some details about this particular representation

/**
 A semantic (hopefully) versioned string representation
 */
@property (nonatomic, strong) NSString* versionString;

/**
 Created date
 */
@property (nonatomic, strong) NSDate *createDate;

/**
 Last Updated date
 */
@property (nonatomic, strong) NSDate *modifyDate;



#pragma mark - how its represented

/**
 The name used to identify this object in the UI, set by child class
 */
@property (nonatomic, readonly) NSString* localizedName;

/**
 A short description to occompany the localizedName, set by child class
 */
@property (nonatomic, readonly) NSString* localizedDescription;

/**
 helper method to determine if metadata exists locally
 */
- (BOOL) hasLocalMetadata;



#pragma mark - where this representation can be found on the local device

/**
 The file location for this representation
 */
@property (nonatomic, strong) NSURL* metadataPath;



/**
 The keymap to use when serializing/deserializing
 */
@property (nonatomic, readonly) NSDictionary* keyMap;


#pragma mark - a supporting help page (html)

/**
 
 */
@property(nonatomic, strong) NSString* helpPage;


@end































