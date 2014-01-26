//
//  WSPlayground.m
//  Open
//
//  Created by Rich Stoner on 12/3/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

// A place to play

#import "WSPlayground.h"

@interface WSPlayground ()

@property(nonatomic, weak) NSData* sourceData;

@end

@implementation WSPlayground

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}



-(void) play {
    
//    [self testDatasource];
//    [self downloadImageFromOpenConnectome];
//    [self convertOBJtoUTF8];
//    [self testmantle];
//    [self testSerialize];
}

-(void) testSerialize
{
    
    wsBiolucidaServerObject* so = [wsBiolucidaServerObject new];
    so.title = @"Test mbf server";
    so.description = @"a test server";
    so.url = [NSURL URLWithString:@"http://google.com"];
    
    [WSMetaDataStore dictionaryForObject:so];
    

}



-(void) testDatasource {
    
    WSMetaDataStore* dataStore = [WSMetaDataStore sharedDataStore];
    wsCollectionObject* startingSet = [dataStore initialObjectCollection];
    NSLog(@"%@", startingSet);
    
}

-(void) downloadImageFromOpenConnectome
{
    
    
    GLKVector3 origin = GLKVector3Make(4000, 4000, 1000);
    GLKVector3 size = GLKVector3Make(128, 128,128);
    GLKVector3 extent = GLKVector3Add(origin, size);
    
    NSString* exampleURL = [NSString stringWithFormat:@"http://openconnecto.me/ocp/ocpca/kasthuri11/npz/1/%d,%d/%d,%d/%d,%d/", (int)origin.x, (int)extent.x, (int)origin.y, (int)extent.y, (int)origin.z, (int)extent.z];
    
    NSLog(@"%@", exampleURL);

    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    
    [manager GET:exampleURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        NSLog(@"Response size: %lu", (unsigned long)operation.responseData.length);
  
        NSData* unzippedData = [operation.responseData gunzippedData];
        self.sourceData = unzippedData;

        NSLog(@"unzipped data size: %lu", (unsigned long)self.sourceData.length);
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@", operation);
        NSLog(@"Error: %@", error);
    }];

    
}


@end

