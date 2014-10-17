//
//  WSMetaDataStore.m
//  Open
//
//  Created by Rich Stoner on 12/26/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSMetaDataStore.h"
#import "wsCollectionObject.h"
#import "wsActionObject.h"
#import "wsRemoteImageObject.h"

#import "wsBiolucidaServerObject.h"

#import "wsBounds.h"

#import "wsBiolucidaRootCollectionObject.h"
#import "wsBiolucidaManagedCollection.h"

#import <FMDatabase.h>

#import "wsWebPageObject.h"



@interface WSMetaDataStore ()
{
    
}


@property(nonatomic, strong) FMDatabaseQueue* queue;
@property(nonatomic, strong) NSMutableArray* dataHistoryStack;
@property(nonatomic, strong) NSMutableArray* dataStarStack;

@property(nonatomic, strong) NSDictionary* helpForObject;

@end

@implementation WSMetaDataStore

@synthesize dataHistoryStack;
@synthesize dataStarStack;
@synthesize queue;
@synthesize helpForObject;


#pragma mark - Singleton Methods -

+ (id)sharedDataStore {
    static WSMetaDataStore *sharedDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataStore = [[self alloc] init];
    });
    return sharedDataStore;
}


// only used internally
+ (NSDateFormatter *)dateFormatter {
    
    static NSDateFormatter *kDateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kDateFormatter = [[NSDateFormatter alloc] init];
        kDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        //        kDateFormatter.dateFormat = @"yyyy-MM-dd";
        kDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        // you configure this based on the strings that your webservice uses!!
    });
    
    return kDateFormatter;
}


+ (NSArray*) supportedFileExtensions {
    
    return @[@"ws", @"jpc", @"ocz"];
    
}


#pragma mark - init -

- (id)init {
    if (self = [super init]) {
        
        // perform the initial copy if the local json isn't there
        
        [self performInitialLoad];

        self.dataHistoryStack = [NSMutableArray new];
        self.dataStarStack =[NSMutableArray new];
        
        

        [self defineHelp];
        
        
        
    }
    return self;
}

-(void) defineHelp
{
    self.helpForObject = @{
                           @"wsObject":@"The base object on which all things are based.",
                           @"wsCollectionObject" : @"A collection of things",
                           @"wsKnossosCubeObject2" : @"An EM cube (8-bit)",
                           @"wsBiolucidaManagedCollection": @"Provides a persistent store for biolucida server objects.",
                           @"wsBiolucidaRootCollectionObject": @"This is the base view for the Biolucida app.",
                           @"wsBiolucidaServerObject" : @"A Biolucida server. The base url and optional user credentials",
                           @"wsBiolucidaCollectionObject" : @"Folders on a Biolucida server",
                           @"wsBiolucidaRemoteImageObject" : @"An image hosted on a Biolucida server"
                           };

}

-(NSString*) helpForObject:(wsObject*) theObject
{
    NSString* classKey = NSStringFromClass([theObject class]);
    
    if (self.helpForObject) {
        if ([[self.helpForObject allKeys] containsObject:classKey])
        {
            return self.helpForObject[classKey];
        
        }
    }
    
    return nil;
}

-(void) performInitialLoad
{
    
//    if([[NSFileManager defaultManager] fileExistsAtPath: [self pathForMBFjson]])
//    {
//        NSLog(@"Existing defaults found, not copying.");
//    }
//    else
//    {
//        // Copy the database from the package to the users filesystem
//        
//        NSLog(@"No defaults.json found, copying from bundle");
//        
//        [[NSFileManager defaultManager] copyItemAtPath:[self pathForMBFBundlejson]
//                                                toPath:[self pathForMBFjson] error:nil];
//    }
    
    
    // sqlite copy
    
    if([[NSFileManager defaultManager] fileExistsAtPath: [self pathForLiveSqlite]])
    {
        VerboseLog(@"Existing sqlite found, using %@", [self pathForLiveSqlite]);
    }
    else
    {
        // Copy the database from the package to the users filesystem
        
        VerboseLog(@"No dura.sqlite found, copying from bundle");
        
        [[NSFileManager defaultManager] copyItemAtPath:[self pathForInitialSqlite]
                                                toPath:[self pathForLiveSqlite] error:nil];
    }
    
    
    self.queue = [[FMDatabaseQueue alloc] initWithPath:[self pathForLiveSqlite]];
    
    
    
    
}



- (wsCollectionObject*) initialObjectCollection
{
    // hack the hard code
    
#if ISMBF

    wsBiolucidaRootCollectionObject* rootObject = [wsBiolucidaRootCollectionObject new];
    rootObject.title = @"Biolucida Viewer";
    
//    wsBiolucidaManagedCollection* rootObject = [wsBiolucidaManagedCollection new];
//    rootObject.title = @"Biolucida Servers";
//    rootObject.localIconString = @"MBFlogo.png";
//    rootObject.description = @"MBF Bioscience";
//    rootObject.fontAwesomeIconString = fa_folder;
//    
    return rootObject;
    
#else
    
    wsRootCollectionObject* rootCollection = [wsRootCollectionObject new];
    rootCollection.title = kApplicationName;
    rootCollection.description = @"Neuroscience collections";
    rootCollection.fontAwesomeIconString = fa_home;
    
    return rootCollection;

    
#endif
    
    
    
}


#pragma mark - Generic Objects -

-(wsActionObject*) addNewObjectObject
{
    wsActionObject* addNewAction = [wsActionObject new];
    // set icon for action item
    addNewAction.notificationString = kNotificationAddObject;
    addNewAction.title = @"Add new";
    addNewAction.description = @"Tap this to add a new object";
    addNewAction.fontAwesomeIconString = fa_plus;
    return addNewAction;
}

-(wsActionObject*) addGoBackObject
{
    wsActionObject* addGoBackObject = [wsActionObject new];
    // set icon for action item
    addGoBackObject.notificationString = kNotificationGoBack;
    addGoBackObject.title = @"Go back";
    addGoBackObject.description = @"Tap this to go back";
    addGoBackObject.fontAwesomeIconString = fa_backward;
    return addGoBackObject;
}

+ (wsActionObject*) addSettingsObject
{
    wsActionObject* addSettingsObject = [wsActionObject new];
    // set icon for action item
    addSettingsObject.notificationString = kNotificationOpenSettings;
    addSettingsObject.title = @"Settings";
    addSettingsObject.description = @"Application settings";
    addSettingsObject.fontAwesomeIconString = fa_cog;
    return addSettingsObject;
}

+ (wsActionObject*) openSelectionObject
{
    wsActionObject* addSettingsObject = [wsActionObject new];
    // set icon for action item
    addSettingsObject.notificationString = kNotificationOpenSelection;
    addSettingsObject.title = @"Open selection";
    addSettingsObject.description = @"Tap this to update app settings";
    addSettingsObject.fontAwesomeIconString = fa_arrow_up;
    return addSettingsObject;
}


+ (wsWebPageObject*) addHelpObject
{

    wsWebPageObject* helpPage = [wsWebPageObject new];
    
    
    
//    wsActionObject* addSettingsObject = [wsActionObject new];
//    // set icon for action item
//    addSettingsObject.notificationString = kNotificationOpenHelp;
    helpPage.title = @"Help";
    helpPage.description = @"How to use this app";
    helpPage.basePath = @"biolucidatutorial";
    helpPage.fontAwesomeIconString = fa_question_circle;
    
    
    return helpPage;
}


#pragma mark - Recent List -

-(void) pushDataObjectToHistory:(wsObject*) theObject
{
    
    if (self.dataHistoryStack.count > 10) {
        [self.dataHistoryStack removeObjectAtIndex:0];
    }

    [self.dataHistoryStack addObject:theObject];
}

-(NSArray*) recentsList {

    if (self.dataHistoryStack.count > 0) {
        return self.dataHistoryStack;
    }
    return nil;
}




#pragma mark - Star list -

-(void) addObjectToStarList:(wsObject*) theObject {
    
    VerboseLog();
    
    int image_index =[self isObjectInStarList:theObject];
    
    if (image_index == -1) {
        
        NSDictionary* soDict = [WSMetaDataStore dictionaryForObject:theObject];
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:soDict
                                                           options:0 // Pass 0 if you don't care about the readability of the generated string
                                                             error:&error];
        if (! jsonData) {
            NSLog(@"Got an error: %@", error);
        }
        else
        {
            
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [queue inDatabase:^(FMDatabase *db) {
                
                [db executeUpdate:@"INSERT INTO star_list (class_name, json_string) VALUES (?, ?)", NSStringFromClass(theObject.class), jsonString];
                
            }];
        }
    }
}

-(int) isObjectInStarList:(wsObject*) theObject {

#warning Using simple title compare to evaluate if object is equal, need to use UUIDs or similar

    //    NSEnumerationConcurrent
    int return_val = -1;
    int count = 0;
    for (wsObject* obj in self.dataStarStack) {
        
        if([obj.localizedName isEqualToString:theObject.localizedName])
        {
            return_val = count;
        }
        
        count++;
    }
    
    return return_val;
}


-(void) removeObjectFromStarList:(wsObject*) theObject {
    
    VerboseLog();
    
    int image_index =[self isObjectInStarList:theObject];
    
    if (image_index != -1) {
        
        // object exists in starlist
        
        [queue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:@"DELETE FROM star_list WHERE id = (?)", theObject.databaseID];
            
        }];
    }
    
    [self starList];
}

-(NSArray*) starList {
    VerboseLog();
    
    NSMutableArray* _list = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *s = [db executeQuery:@"SELECT * FROM star_list"];
        while ([s next]) {
            
            //retrieve values for each record
            
            NSString* jsonString = [[s objectForColumnName:@"json_string"] stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            
            wsObject* newObject = [WSMetaDataStore objectFromDictionary:jsonDict];
            newObject.databaseID = [s objectForColumnIndex:0];
            
//            NSLog(@"%@", newObject.databaseID);
            
            [_list addObject:newObject];
            
        }
    }];
    
    
    self.dataStarStack = _list;
    
    return _list;
}

//
//- (NSString*) pathForStarListArchive
//{
//    NSString* filename = @"starlist.json";
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
////    NSLog(@"%@", filePath);
//    return filePath;
//}
//
//- (BOOL) writeStarList
//{
//    
//    NSError *err = nil;
//    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self.starList
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&err];
//    [jsonData writeToFile:[self pathForStarListArchive] atomically:YES];
//    if (err) {
//        NSLog(@"error converting");
//        return NO;
//    }
//    return YES;
//}
//






-(void) saveObjectToDocumentsDirectory:(wsObject*) theObject
{
    VerboseLog();

    NSString* objectName = [NSString stringWithFormat:@"%@.ws", theObject.localizedName];
    
    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *rootUrl = [dirs lastObject];
    NSString* savePath = [rootUrl.path stringByAppendingPathComponent:objectName];
    
    NSDictionary* objectDict = [WSMetaDataStore dictionaryForObject:theObject];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:objectDict
                                                       options:kNilOptions
                                                         error:nil];
    
    [jsonData writeToFile:savePath atomically:YES];

}






//
//
//#pragma mark - localfiles
//
//-(NSArray*) objectsInDirectoryFolderWithPath:(NSURL*) url
//{
//    return [self rowsForDirectory:url];
//}
//
//-(NSArray*) objectsInDocumentsDirectory
//{
//    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    NSURL *url = [dirs lastObject];
//    
//    return [self objectsInDirectoryFolderWithPath:url];
//}
//
//+(NSURL*) documentsDirectory
//{
//    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    return [dirs lastObject];
//}

//
//- (NSArray *)rowsForDirectory:(NSURL *)rootUrl
//{
//    NSError *error = nil;
//    NSArray *properties = @[
//                            NSURLLocalizedNameKey,
//                            NSURLCreationDateKey,
//                            NSURLContentModificationDateKey,
//                            NSURLIsSymbolicLinkKey,
//                            NSURLIsDirectoryKey,
//                            NSURLIsHiddenKey,
//                            NSURLFileSizeKey
//                            ];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"HH:MM  dd-MMM-YYYY"];
//    
//    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:rootUrl
//                                                   includingPropertiesForKeys:properties
//                                                                      options:(NSDirectoryEnumerationSkipsHiddenFiles)
//                                                                        error:&error];
//    NSMutableArray *rows = [[NSMutableArray alloc] initWithCapacity:array.count];
//    
////    NSLog(@"Rows: %@",array);
//    
//    for(NSURL * url in array)
//    {
//        
//        NSString *localizedName = nil;
//        [url getResourceValue:&localizedName forKey:NSURLLocalizedNameKey error:NULL];
//        
//        NSNumber *isPackage = nil;
//        [url getResourceValue:&isPackage forKey:NSURLIsPackageKey error:NULL];
//        
//        NSNumber *isDirectory = nil;
//        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
//        
//        NSNumber *isHidden = nil;
//        [url getResourceValue:&isHidden forKey:NSURLIsHiddenKey error:NULL];
//        
//        NSNumber *isSymbolic = nil;
//        [url getResourceValue:&isSymbolic forKey:NSURLIsSymbolicLinkKey error:NULL];
//        
//        NSNumber *fileSize = nil;
//        [url getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
//        NSString *fileSizeStr = @"";
//        if(fileSize)
//        {
//            fileSizeStr = [NSString stringWithFormat:@"%.2f kb",[fileSize floatValue]/1024];
//        }
//        
//        if([isHidden boolValue])
//        {
//            //            cellFilename.textColor = [UIColor colorWithRed:0.5 green:0.1 blue:0.1 alpha:1];
//        }
//        
//        if([isPackage boolValue])
//        {
//            //            cellFilename.icon = [UIImage imageNamed:@"TableViewPackageIcon"];
//        }
//        
//        if([isDirectory boolValue])
//        {
//            wsLocalFolderCollection* localFolder = [wsLocalFolderCollection new];
//            localFolder.title = localizedName;
//            localFolder.description = @"A folder on this device";
//            localFolder.baseURL = url;
//            
//            [rows addObject:localFolder];
//            
//        }
//        else
//        {
//            
//            NSString* pathExtension = [localizedName pathExtension];
//            
//            if ([[WSMetaDataStore supportedFileExtensions] containsObject:pathExtension])
//            {
//                
//                if ([pathExtension isEqualToString:@"jpc"]) {
//                    
//                    wsKnossosCubeObject2* cube = [wsKnossosCubeObject2 new];
//                    cube.title = localizedName;
//                    cube.shouldUseJP2 = @1;
//                    cube.localURL = url;
//                    cube.metadataPath = url;
//                    [rows addObject:cube];
//                    
//                    
//                }
//                else if ([pathExtension isEqualToString:@"ocz"])
//                {
//                    wsOCPCubeObject2* cube = [wsOCPCubeObject2 new];
//                    cube.title = localizedName;
//                    cube.localURL = url;
//                    cube.metadataPath = url;
//                    [rows addObject:cube];
//                    
//                }
//                else
//                {
//                    
//                    NSDictionary* jsonDescription = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:url.path options:NSDataReadingUncached error:nil] options:NSJSONReadingAllowFragments error:nil];
//                    
//                    wsObject* obj = [WSMetaDataStore objectFromDictionary:jsonDescription];
//                    obj.metadataPath = url;
//                    [rows addObject:obj];
//                    
//                }
//                
//
//            }
//            else {
//
////                wsSystemObject* fileObject = [wsSystemObject new];
////                fileObject.title = localizedName;
////                fileObject.fontAwesomeIconString = fa_ban;
////                fileObject.description = @"an unsupported file type";
////                
////                [rows addObject:fileObject];
//                
//            }
//            
//            
//        }
//        
//    }
//    
//    [rows addObject:[[WSMetaDataStore sharedDataStore] addNewObjectObject]];
//
//    
//    return [NSArray arrayWithArray:rows];
//}
//


#pragma mark - Defaults and local storage

- (NSString*) pathForMBFjson {
    
    NSString* filename = @"defaults.json";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    return filePath;
}

- (NSString*) pathForMBFBundlejson {
    
    NSString* defaultsPath = [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"json"];
    return defaultsPath;
}


- (BOOL) writeToMBFjson:(NSDictionary*) objectToWrite
{
    
    NSError *err = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:objectToWrite
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
    [jsonData writeToFile:[self pathForMBFjson] atomically:YES];
    if (err) {
        NSLog(@"error converting");
        return NO;
    }
    return YES;
}


- (NSArray*) mbfList
{
    VerboseLog();
    
    NSMutableArray* mbfList = [NSMutableArray new];
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *s = [db executeQuery:@"SELECT * FROM mbf"];
        while ([s next]) {
            //retrieve values for each record
            
            NSString* jsonString = [[s objectForColumnName:@"json_string"] stringByReplacingOccurrencesOfString:@"\'" withString:@"\""];
            
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
            
//            NSLog(@"%@", jsonDict);
//            NSLog(@"%@", [s stringForColumn:@"id"]);
            
            wsObject* newObject = [WSMetaDataStore objectFromDictionary:jsonDict];
            newObject.databaseID = [s objectForColumnIndex:0];
    
//            NSLog(@"%@ - %@", newObject.localizedName, newObject.databaseID);
            
            [mbfList addObject:newObject];
            
        }
    }];
    
    
    
    return mbfList;
}


-(void) addNewMBFServer:(wsBiolucidaServerObject*) serverObject
{
    NSDictionary* soDict = [WSMetaDataStore dictionaryForObject:serverObject];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:soDict
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
    
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
       
        [queue inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:@"INSERT INTO mbf (class_name, json_string) VALUES (?, ?)", NSStringFromClass(serverObject.class), jsonString];
           
        }];
    }
}


-(void) updateMBFServer:(wsBiolucidaServerObject*) serverObject
{
    NSDictionary* soDict = [WSMetaDataStore dictionaryForObject:serverObject];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:soDict
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    }
    else
    {
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [queue inDatabase:^(FMDatabase *db) {
            
            BOOL success = [db executeUpdate:@"UPDATE mbf SET json_string = (?) WHERE id = (?)", jsonString , serverObject.databaseID];
            
            if (success) {
                
                NSLog(@"success!");
                
            }
            
        }];
    }
    
    
    
}

-(void) deleteMBFServer:(wsBiolucidaServerObject*) serverObject
{
    VerboseLog(@"delete");
    
    [queue inDatabase:^(FMDatabase *db) {
        
            [db executeUpdate:@"DELETE FROM mbf WHERE id = (?)", serverObject.databaseID];
        
        }];

    [self mbfList];
}


- (wsCollectionObject*) mbfServers
{
    wsBiolucidaManagedCollection* rootObject = [wsBiolucidaManagedCollection new];
    rootObject.title = @"Biolucida Servers";
    rootObject.localIconString = @"MBFlogo.png";
    rootObject.description = @"MBF Bioscience";
    rootObject.fontAwesomeIconString = fa_folder;
    
    return rootObject;
}



#pragma mark - OBJECT Factory -

#define kJSONKeyNameIndex 0
#define kJSONFormatType 1

+ (NSDictionary*) dictionaryForObject:(wsObject*) theObject
{
    NSDictionary* keyMapForClass = [theObject keyMap];
    
    NSMutableDictionary* returnDict = [NSMutableDictionary new];
    
    returnDict[@"class_name"] = NSStringFromClass(theObject.class);
    
    for (NSString* key in keyMapForClass) {
    
        NSArray* mapping = keyMapForClass[key];
        
        // if we have an object, just do a straight conversion
        if ([mapping[kJSONFormatType] isEqualToString:@"object"]) {
            
            id valueToConvert = [theObject valueForKey:key];
            // only store values that are not nil
            if (valueToConvert) {
            
                returnDict[mapping[kJSONKeyNameIndex]] = valueToConvert;
                
            }
            
        }
        else if ([mapping[kJSONFormatType] isEqualToString:@"url"])
        {
            id valueToConvert = [theObject valueForKey:key];
            // only store values that are not nil
            if (valueToConvert) {
            
                returnDict[mapping[kJSONKeyNameIndex]] = ((NSURL*)valueToConvert).absoluteString;
                
            }
            
            
        }
        else if ([mapping[kJSONFormatType] isEqualToString:@"date"])
        {
            id valueToConvert = [theObject valueForKey:key];
            // only store values that are not nil
            if (valueToConvert) {

                NSString* dateString = [[WSMetaDataStore dateFormatter] stringFromDate:valueToConvert];
                returnDict[mapping[kJSONKeyNameIndex]] = dateString;
                
            }

        }
        else if ([mapping[kJSONFormatType] isEqualToString:@"CGSize"])
        {
            
            // this gives an NSSize object
            CGSize valueToConvert = [[theObject valueForKey:key] CGSizeValue];

            NSString* cgsizeString = [NSString stringWithFormat:@"%f,%f", valueToConvert.width, valueToConvert.height];
        
            // only store values that are not nil
            if (cgsizeString) {
                returnDict[mapping[kJSONKeyNameIndex]] = cgsizeString;
            }
        }
        
        else if ([mapping[kJSONFormatType] isEqualToString:@"wsObject"])
        {

            id valueToConvert = [theObject valueForKey:key];
            // only store values that are not nil
            if (valueToConvert) {

                NSDictionary* tempDict = [WSMetaDataStore dictionaryForObject:valueToConvert];
                
                if (tempDict) {
                    returnDict[mapping[kJSONKeyNameIndex]] = tempDict;
                }
                
            }

            
        }
        else if ([mapping[kJSONFormatType] isEqualToString:@"array"])
        {
            id valueToConvert = [theObject valueForKey:key];
            // only store values that are not nil
            if (valueToConvert) {
            
                NSMutableArray* tempArray = [NSMutableArray new];
                
                NSLog(@"%@", valueToConvert);
                
                for (id obj in valueToConvert) {
                    
                    NSDictionary* tempDict = [WSMetaDataStore dictionaryForObject:obj];
                    if (tempDict) {
                        [tempArray addObject:tempDict];
                    }
                }
                
                if (tempArray.count > 0) {
                    returnDict[mapping[kJSONKeyNameIndex]] = tempArray;
                }
            
            }
        }
    }
    

    
    return returnDict;
}

+(wsObject*) objectFromDictionary:(NSDictionary*) theDictionary
{
//    NSLog(@"%@", theDictionary);
    
    wsObject* newObject = [NSClassFromString(theDictionary[@"class_name"]) new];

    if (newObject == nil) {
        return nil;
    }
    
    NSDictionary* keyMapForClass = [newObject keyMap];
    
    for (NSString* key in keyMapForClass) {
        
        NSArray* mapping = keyMapForClass[key];

        // check if the mapping has a json_key match, if so add to object
        if([[theDictionary allKeys] containsObject:mapping[kJSONKeyNameIndex]] )
        {
            id valueToConvertBack = theDictionary[mapping[kJSONKeyNameIndex]];
            
            // verify
            if (valueToConvertBack) {
                
                // if we have an object, just do a straight conversion
                if ([mapping[kJSONFormatType] isEqualToString:@"object"]) {
                    
                    [newObject setValue:valueToConvertBack forKey:key];
                    
                }
                else if ([mapping[kJSONFormatType] isEqualToString:@"url"])
                {
                    [newObject setValue:[NSURL URLWithString:(NSString*)valueToConvertBack] forKey:key];
                    
                }
                else if ([mapping[kJSONFormatType] isEqualToString:@"date"])
                {
                    NSDate* newDate = [[WSMetaDataStore dateFormatter] dateFromString:(NSString*)valueToConvertBack];
                    [newObject setValue:newDate forKey:key];
                }
                else if ([mapping[kJSONFormatType] isEqualToString:@"wsObject"])
                {
                    wsObject* tempObject = [WSMetaDataStore objectFromDictionary:valueToConvertBack];
                    
                    if (tempObject) {
                        [newObject setValue:tempObject forKey:key];
                    }
                    
                }
                else if ([mapping[kJSONFormatType] isEqualToString:@"CGSize"])
                {
                    
                    NSString* stringVal = (NSString*)valueToConvertBack;
                    NSArray* vals = [stringVal componentsSeparatedByString:@","];
                    
                    if (vals.count == 2) {
                        
                        CGFloat width = [(NSString*)vals[0] floatValue];
                        CGFloat height = [(NSString*)vals[1] floatValue];
                        
                        if ([key isEqualToString:@"nativeSize"]) {
                            [((wsImageObject*)newObject) setNativeSize:CGSizeMake(width, height)];
                        }
                        else if ([key isEqualToString:@"tileSize"])
                        {
                            [((wsImageObject*)newObject) setTileSize:CGSizeMake(width, height)];
                        }
                
                    }
                
                }
                
                else if ([mapping[kJSONFormatType] isEqualToString:@"array"])
                {
                    NSMutableArray* tempArray = [NSMutableArray new];
                    
                    for (id _dict in valueToConvertBack) {
                        
                        wsObject* tempObject = [WSMetaDataStore objectFromDictionary:_dict];
                        if (tempObject) {
                            [tempArray addObject:tempObject];
                        }
                    }
                    
                    if (tempArray.count > 0) {
                        [newObject setValue:tempArray forKey:key];
                    }
                }
            }
        }
    }
    
    
    
    return newObject;
}

+ (NSString*) metadataStringForObject:(wsObject*) theObject
{
    NSMutableString* htmlString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bsheader" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
//    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSDictionary* dictForObject = [WSMetaDataStore dictionaryForObject:theObject];
    
    NSString* helpString = [[WSMetaDataStore sharedDataStore] helpForObject:theObject];
    
    if (helpString) {
        
        [htmlString appendFormat:@"<div><b>%@</b></div>", helpString];
        
    }
    
    for (NSString* key in [dictForObject allKeys]) {
        
        id toAdd = dictForObject[key];
        
        if ([toAdd isKindOfClass:[NSString class]]) {

            toAdd =  [(NSString*)toAdd stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
            
        }
        
        NSLog(@"%@", toAdd);

        
        [htmlString appendFormat:@"<div><b>%@</b></div><p>%@</p>", key, toAdd];
        
    }
    
    [htmlString appendString:@"</div></body>"];
    
//    NSLog(@"%@", htmlString);
    
    return htmlString;
    
    //    NSURL *baseURL = [NSURL fileURLWithPath:path];
    
    //    [contentView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://wholeslide.com/dura/"]]];
    
    //    [contentView setOpaque:NO];
    //    [contentView setBackgroundColor:[UIColor clearColor]];
    //
    //    [contentView loadHTMLString:htmlString baseURL:baseURL];
}



#pragma mark - SQLite methods -

- (NSString*) pathForLiveSqlite {
    
    NSString* filename = @"dura.sqlite";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
    return filePath;
}

- (NSString*) pathForInitialSqlite {
    
    NSString* defaultsPath = [[NSBundle mainBundle] pathForResource:@"dura" ofType:@"sqlite"];
    return defaultsPath;
}












@end
