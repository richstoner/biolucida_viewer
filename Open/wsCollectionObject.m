//
//  wsCollectionObject.m
//  Open
//
//  Created by Rich Stoner on 12/27/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "wsCollectionObject.h"
#import "wsCollectionPath.h"

@implementation wsCollectionObject

@synthesize originalIndexList;
@synthesize delegate;


@synthesize description;
@synthesize title;
@synthesize children;

- (id)init
{
    self = [super init];
    if (self) {
        
        // it's going to be a collection... probably want to initialize the nsmutablearray
        self.children = [NSMutableArray new];
        
    }
    return self;
}

- (NSString*)localizedName
{
    return self.title;
}

- (NSString*) localizedDescription
{
    return self.description;
}


#pragma - child accessors

-(void) addChild:(wsObject *)theObject
{
    [self.children addObject:theObject];
    [self triggerUpdate];
    
}

-(void) addChildren:(NSArray *)objects
{
    for (wsObject* obj in objects) {
        [self.children addObject:obj];
    }
    [self triggerUpdate];
}

-(void) insertChild:(wsObject *)theObject atIndex:(NSUInteger)theIndex
{
    [self.children insertObject:theObject atIndex:theIndex];
    [self triggerUpdate];

}

-(void) removeChildren
{
    [self.children removeAllObjects];
    [self triggerUpdate];
}


-(void) removeChildAtIndex:(NSUInteger)theIndex
{
    [self.children removeObjectAtIndex:theIndex];
    [self triggerUpdate];
}

-(void) removeChild:(wsObject*) theObject
{
    int image_index = [self isObjectInChildren:theObject];
    
    if (image_index != -1) {
        
        // object exists in starlist
        [self.children removeObjectAtIndex:image_index];
    }
    
}

-(void) initializeCollection
{
    VerboseLog();
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
}

-(void) refreshAsCurrentCollection
{
    self.originalIndexList = [self validIndexPaths];
    
    VerboseLog();
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewItems:)]) {
        [self.delegate collectionObjectHasNewItems:self];
    }
}

-(void) refreshAsNewCollection
{
    self.originalIndexList = [self validIndexPaths];    
    
    VerboseLog();    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
}


-(NSArray*) collections {
    return @[self];
}

-(BOOL) supportsAddObject
{
    return NO;
}

-(NSSet*) validIndexPathsForCollection:(NSArray*) theCollection
{
    // I'd use a set, but the objects themselves are different, so the minus set doesn't work without some extras
    NSMutableSet* indexPathSet = [NSMutableSet new];
    
    for (int i=0; i< theCollection.count; i++) {
        
        wsCollectionObject* childObject = theCollection[i];
        
        for(int j=0; j< childObject.children.count; j++){
            
            wsCollectionPath* newPath = (wsCollectionPath*)[wsCollectionPath indexPathForItem:j inSection:i];
            [indexPathSet addObject:newPath];
            
        }
    }
    return indexPathSet;
}


-(NSSet*) validIndexPaths
{
    return [self validIndexPathsForCollection:self.collections];
}


//private

-(void) triggerUpdate {
    self.modifyDate = [NSDate date];
    
}


-(int) isObjectInChildren:(wsObject*) theObject {
    
#warning Using simple title compare to evaluate if object is equal, need to use UUIDs or similar
    
    //    NSEnumerationConcurrent
    int return_val = -1;
    int count = 0;
    for (wsObject* obj in self.children) {
        
        if([obj.localizedName isEqualToString:theObject.localizedName])
        {
            return_val = count;
        }
        
        count++;
    }
    
    return return_val;
}





@end













