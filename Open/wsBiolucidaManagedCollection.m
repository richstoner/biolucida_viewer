//
//  wsBiolucidaManagedCollection.m
//  Open
//
//  Created by Rich Stoner on 1/3/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsBiolucidaManagedCollection.h"
#import "wsBiolucidaServerObject.h"




@implementation wsBiolucidaManagedCollection

@synthesize title, description,localIconString;

- (id)init
{
    self = [super init];
    if (self) {
        

        self.title = @"Biolucida Servers";
        self.localIconString = @"MBFlogo.png";
        self.description = @"MBF Bioscience";
        self.showWhenEmpty = YES;
    }
    return self;
}


-(void)initializeCollection
{
    VerboseLog();
    
    self.originalIndexList = [self validIndexPaths];
    
    // we reload everything each time... I'm sure there's a better way
    [self removeChildren];

    [self addChildren:[[WSMetaDataStore sharedDataStore] mbfList]];
    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
    
    

    
    
}

-(void) refreshAsNewCollection
{

    
    self.originalIndexList = [self validIndexPaths];
    
    // we reload everything each time... I'm sure there's a better way
    [self removeChildren];
    
    [self addChildren:[[WSMetaDataStore sharedDataStore] mbfList]];

//    [self addChild:[[WSMetaDataStore sharedDataStore] addNewObjectObject]];
    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
    
    

}

-(NSArray*)collections
{
    return @[self];
}


-(BOOL) supportsAddObject
{
    return YES;
}

-(void) refreshAsCurrentCollection
{
    VerboseLog();
    
    self.originalIndexList = [self validIndexPaths];
    
    
    // we reload everything each time... I'm sure there's a better way
    [self removeChildren];
    
    [self addChildren:[[WSMetaDataStore sharedDataStore] mbfList]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURL* serverPath = [NSURL URLWithString:@"http://localhost:8000/current.json"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    __weak wsBiolucidaManagedCollection* weakself = self;
    
    [manager GET:serverPath.absoluteString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             NSDictionary* objDict = (NSDictionary*)responseObject;
             
             wsObject* serverObject = [WSMetaDataStore objectFromDictionary:objDict];
             
             VerboseLog(@"%@", serverObject);
             
             [weakself addChild:serverObject];

             NSLog(@"%@", self.children);
             
             if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewItems:)]) {
                 [self.delegate collectionObjectHasNewItems:self];
             }
             
             
         }
     
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             NSLog(@"%@", operation.request.allHTTPHeaderFields);
             NSLog(@"Error: %@", error);
             
             NSLog(@"Response code: %d", operation.response.statusCode);
             NSLog(@"%@", operation.responseString);
             
             if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewItems:)]) {
                 [self.delegate collectionObjectHasNewItems:self];
             }
             
         }];
    
    


    
}


-(void) addChildAndSave:(wsServerObject *)theObject
{
    VerboseLog();
    [[WSMetaDataStore sharedDataStore] addNewMBFServer:(wsBiolucidaServerObject*)theObject];
    
//    [super addChild:theObject];
}

-(void) updateChildAndSave:(wsServerObject*) theObject
{
    VerboseLog();
    [[WSMetaDataStore sharedDataStore] updateMBFServer:(wsBiolucidaServerObject*)theObject];

}


-(void) deleteChildAndSave:(wsServerObject*) theObject
{
    VerboseLog();
    
    [[WSMetaDataStore sharedDataStore] deleteMBFServer:(wsBiolucidaServerObject*)theObject];
}

@end
