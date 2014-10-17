//
//  wsCollectionObject.h
//  Open
//
//  Created by Rich Stoner on 12/27/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsSystemObject.h"

@protocol wsCollectionDelegate;

@interface wsCollectionObject : wsSystemObject

/**
 A short description of the collection
 */
@property(nonatomic, strong) NSString* title;

/**
 A longer short description of collection object
 */
@property(nonatomic, strong) NSString* description;

/**
 A mutable array of wsobjects
 */
@property(nonatomic, strong) NSMutableArray* children;


/**
 
 */
@property(nonatomic, assign) BOOL showWhenEmpty;


#pragma mark - add object and update modify date

/**
 Adds an object to the child array and triggers any needed changes
 */
-(void) addChild:(wsObject*)theObject;

/**
 Just a bit more efficient
 */
-(void) addChildren:(NSArray*) objects;

/**
 Inserts an object to the child array and triggers any needed changes
 */
-(void) insertChild:(wsObject*)theObject atIndex:(NSUInteger) theIndex;

/**
 Clears the child array and triggers update
 */
-(void) removeChildren;

/**
 Removes a child that matches the included obj parameter
 */
-(void) removeChild:(wsObject*) theObject;

/**
 Removes an object at index and update
 */
-(void) removeChildAtIndex:(NSUInteger) theIndex;


#pragma mark - get contents for collectionView

/**
 Get contents as an array of wsobjects
 */
@property(nonatomic, strong, readonly) NSArray* collections;


/**
 
 */
@property(nonatomic, readonly) BOOL supportsAddObject;


/**
 Valid index paths for objects currently in collections
 */
-(NSSet*) validIndexPaths;

/**
 The initial index set to transition from
 */
@property(nonatomic, strong) NSSet* originalIndexList;




#pragma mark - any async methods

/**
 Perform any initial methods, return method if delegate exists 
 */
-(void) initializeCollection;

/**
 Called to refresh the current collection
 */
-(void) refreshAsCurrentCollection;

/**
 Called to refresh a new collection (similar to initialize, but doesn't empty cells unless it has to)
 */
-(void) refreshAsNewCollection;



/**
 Trigger any changes if the collection has updated information
 */
@property (nonatomic, weak) id<wsCollectionDelegate> delegate;

@end



@protocol wsCollectionDelegate <NSObject>

-(void) collectionObjectHasNewSections:(wsCollectionObject*) collectionObject;

-(void) collectionObjectHasNewItems:(wsCollectionObject*) collectionObject;

-(void) collectionObjectFailedToLoad:(wsCollectionObject*) collectionObject;

-(void) collectionShouldReloadData:(wsCollectionObject*) collectionObject;

@end
