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



- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"Biolucida Servers";
        self.localIconString = @"MBFlogo.png";
        self.description = @"MBF Bioscience";
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
    
//    [self addChild:[[WSMetaDataStore sharedDataStore] addNewObjectObject]];

    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
    
}

-(void) refreshAsNewCollection
{
    VerboseLog();
    
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
    
//    [self addChild:[[WSMetaDataStore sharedDataStore] addNewObjectObject]];
    
    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewItems:)]) {
        [self.delegate collectionObjectHasNewItems:self];
    }

    
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
