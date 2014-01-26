//
//  WSMetaDataStore.h
//  Open
//
//  Created by Rich Stoner on 12/26/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabaseQueue.h>

@interface WSMetaDataStore : NSObject

#pragma mark - Singleton Methods -

/**
 Singleton representation ... only need one data resource
 */
+ (id) sharedDataStore;

+ (NSDateFormatter *)dateFormatter;

+ (NSArray*) supportedFileExtensions;

+ (NSURL*) documentsDirectory;

+ (NSURL*) tmpDirectory;

#pragma mark - Object Factory -

+ (NSDictionary*) dictionaryForObject:(wsObject*) theObject;

+ (wsObject*) objectFromDictionary:(NSDictionary*) theDictionary;

+ (NSString*) metadataStringForObject:(wsObject*) theObject;

#pragma mark - Default options

/**
 An array of dictionaries, with section headers defined by collection names
 */
- (wsCollectionObject*) initialObjectCollection;

/**
 Sends a 'go back' notification to the current view (usually a collectionview)
 */
-(wsActionObject*) addGoBackObject;

/**
 Adds a 'add object' button
 */
-(wsActionObject*) addNewObjectObject;

/**
 Add a settings object button
 */
+ (wsActionObject*) addSettingsObject;


/**
 Add a 'open selection' button
 */
+ (wsActionObject*) openSelectionObject;

/**
 
 */
+ (wsActionObject*) addHelpObject;

#pragma mark - Lists for Root

-(NSString*) helpForObject:(wsObject*) theObject;

-(NSArray*) recentsList;
-(void) pushDataObjectToHistory:(wsObject*) theObject;

-(NSArray*) starList;
-(void) addObjectToStarList:(wsObject*) theObject;
-(int) isObjectInStarList:(wsObject*) theObject;
-(void) removeObjectFromStarList:(wsObject*) theObject;

#pragma mark - MBF Specific methods -

-(void) addNewMBFServer:(wsBiolucidaServerObject*) serverObject;
-(void) updateMBFServer:(wsBiolucidaServerObject*) serverObject;
- (void) deleteMBFServer:(wsBiolucidaServerObject*) serverObject;
- (NSArray*) mbfList;



@end

