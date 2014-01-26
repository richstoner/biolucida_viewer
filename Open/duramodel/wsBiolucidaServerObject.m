//
//  wsBiolucidaServerObject.m
//  Open
//
//  Created by Rich Stoner on 12/23/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsBiolucidaServerObject.h"
#import "wsBiolucidaCollectionObject.h"
#import "WSMetaDataStore.h"

@interface wsBiolucidaServerObject ()

@property(nonatomic, strong) NSString* serverAuthToken;

@end

@implementation wsBiolucidaServerObject

- (id)init
{
    self = [super init];
    if (self) {
        
        self.localIconString = @"MBFlogo.png";
        
    }
    return self;
}

- (NSString*) localizedName
{
    return self.title;
}


- (NSString*) localizedDescription
{
    return @"Biolucida Cloud Server";
}


-(NSDictionary*) keyMap {
    
    NSMutableDictionary* km = [NSMutableDictionary dictionaryWithDictionary:[super keyMap]];
    
    NSDictionary* local_keymap = @{
                                   @"serverAuthToken" :      @[ @"serverAuthToken", @"object"],
                                   };
    
    [km addEntriesFromDictionary:local_keymap];
    
    return km;
}


-(void) initializeCollection
{
    VerboseLog();
    [self loadRootPath];
}

-(void) refreshAsCurrentCollection
{
    self.originalIndexList = [self validIndexPaths];
    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewItems:)]) {
        [self.delegate collectionObjectHasNewItems:self];
    }
}

-(void) refreshAsNewCollection
{
    self.originalIndexList = [self validIndexPaths];

    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
    
}

#pragma mark - internals

-(NSArray*) collections {
    return self.children;
}

- (NSArray *) collectionForFolder:(NSArray*)theArray withBasePath:(NSString*)basePath
{
    NSMutableArray* folderArray = [[NSMutableArray alloc] init];

    for (NSDictionary* folderDescription in theArray) {
        
        wsBiolucidaCollectionObject* collection = [wsBiolucidaCollectionObject new];
        collection.server = self;
        collection.fontAwesomeIconString = fa_folder_o;
        collection.title = folderDescription[@"name"];
        collection.description = self.localizedDescription;
        collection.relativePath = [basePath stringByAppendingFormat:@"%@/", folderDescription[@"name"]];
        
//        NSLog(@"creating %@ collection (aka section)", collection.localizedName);
        
        id subfolders = folderDescription[@"folders"];

        [collection addChild:[[WSMetaDataStore sharedDataStore] addGoBackObject]];
        
        if([subfolders isKindOfClass:[NSArray class]]) {
            
            NSArray* contents = [self collectionForFolder:subfolders withBasePath:[basePath stringByAppendingFormat:@"%@/", folderDescription[@"name"]]];
            
            
            [collection addChildren:contents];
        }
        
        [folderArray addObject:collection];
    }
    
    return folderArray;
}

/**
 Passes / to Loadpath
 */
-(void) loadRootPath
{
    [self loadPath:@"/"];
}

+ (NSString *)uuid
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge NSString *)uuidStringRef;
}



-(void) loginWithCredentials:(NSDictionary*) credentials
{
    NSString* username = credentials[@"username"];
    NSString* password = credentials[@"password"];
    
    if (username.length > 0 && password.length > 0) {
        
        NSString* generatedAuthToken = [wsBiolucidaServerObject uuid];
        
        NSURL* authURL = [self.url URLByAppendingPathComponent:@"api/v1/authenticate"];
        
        NSDictionary* postData = @{@"username": username,
                                   @"password": password,
                                   @"token" : generatedAuthToken};
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:authURL.absoluteString parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary* responseMessage = responseObject;
            
            if ([responseMessage[@"status"] isEqualToString:@"success"]) {
                
                // login valid, save the credentials
                
                self.username = username;
                self.password = password;
                
                NSLog(@"%@", responseMessage);
                
                self.serverAuthToken = responseMessage[@"token"];
                
                [[WSMetaDataStore sharedDataStore] updateMBFServer:self];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginSuccess object:nil];
                
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginFailed object:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginFailed object:nil];
            
        }];
        
        
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginMissingValues object:nil];
    }
}


/**

 */
-(void) login
{
    VerboseLog(@"%@ - %@", self.username, self.password);
    
    if (self.username.length > 0 && self.password.length > 0) {
    
        
        
        NSString* generatedAuthToken = [wsBiolucidaServerObject uuid];
        
        NSURL* authURL = [self.url URLByAppendingPathComponent:@"api/v1/authenticate"];
        
        NSDictionary* postData = @{@"username": self.username,
                                   @"password": self.password,
                                   @"token" : generatedAuthToken};
        
        NSLog(@"%@", postData);
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        [manager POST:authURL.absoluteString parameters:postData success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSDictionary* responseMessage = responseObject;
            
            if ([responseMessage[@"status"] isEqualToString:@"success"]) {
                
                // login valid!
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginSuccess object:nil];

            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginFailed object:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginFailed object:nil];
            
        }];
        
        
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationServerLoginMissingValues object:nil];
    }
}

/**
 Accesses a collection at this location
 */
-(void) loadPath:(NSString*)thePath
{
    VerboseLog();
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURL* serverPath = [self.url URLByAppendingPathComponent:@"api/v1/folders"];
    
    if(self.serverAuthToken)
    {
        NSLog(@"setting auth token");
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager.requestSerializer setValue:self.serverAuthToken forHTTPHeaderField:@"token"];
    }

    
//    serverPath = [NSURL URLWithString:@"http://posttestserver.com/post.php"];
    
    [manager GET:serverPath.absoluteString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary* allFolderDict = (NSDictionary*)responseObject;

        NSLog(@"%@", operation.request.allHTTPHeaderFields);

        
//        NSLog(@"%@", allFolderDict);
        
        if ([allFolderDict[@"status"] isEqualToString:@"success"]) {
            
            wsBiolucidaCollectionObject* collection = [wsBiolucidaCollectionObject new];
            collection.server = self;
            collection.fontAwesomeIconString = fa_folder;
            collection.title = self.localizedName;
            collection.description = self.localizedDescription;
            collection.relativePath = @"/";
            
            [collection addChildren:[self collectionForFolder:allFolderDict[@"folders"] withBasePath:thePath]];
            
            [self removeChildren];
            [self addChild:collection];
            
            if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
                [self.delegate collectionObjectHasNewSections:self];
            }
        }
    }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
             NSLog(@"%@", operation.request.allHTTPHeaderFields);

             
             NSLog(@"Error: %@", error);
             
             NSLog(@"Response code: %d", operation.response.statusCode);
             NSLog(@"%@", operation.responseString);
             
             if ([self.delegate respondsToSelector:@selector(collectionObjectFailedToLoad:)]) {
                 [self.delegate collectionObjectFailedToLoad:self];
             }
    }];
}



@end
