//
//  wsBiolucidaRootCollectionObject.m
//  Open
//
//  Created by Rich Stoner on 1/20/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsBiolucidaRootCollectionObject.h"
#import "wsBiolucidaManagedCollection.h"
#import "wsWebPageObject.h"

@interface wsBiolucidaRootCollectionObject ()

@property(nonatomic, strong) wsBiolucidaManagedCollection* managedCollection;
@property(nonatomic, strong) wsCollectionObject* recentsList;
@property(nonatomic, strong) wsCollectionObject* starList;
@property(nonatomic, strong) wsCollectionObject* optionsList;

@end

@implementation wsBiolucidaRootCollectionObject

@synthesize starList;
@synthesize recentsList;
@synthesize optionsList;

- (id)init
{
    self = [super init];
    if (self) {
        self.helpPage = @"biolucidatutorial";
    }
    return self;
}

-(void) initializeCollection
{
    VerboseLog();
    
    self.originalIndexList = [self validIndexPaths];
    
    [self removeChildren];
    
    self.managedCollection = [wsBiolucidaManagedCollection new];
    self.managedCollection.fontAwesomeIconString = fa_folder;
    
    [self addChild:self.managedCollection];
    

    // saved items
    self.starList = [wsCollectionObject new];
    self.starList.fontAwesomeIconString = fa_bookmark;
    self.starList.title = @"Saved items";
    self.starList.description = @"To save items, tap and hold on their thumbnail or tab and tap 'Save'";
    self.starList.fontAwesomeIconString = fa_folder;
    
    NSArray* _starList = [[WSMetaDataStore sharedDataStore] starList];
    NSLog(@"Star list has %d objects", _starList.count);
    
    if (starList !=nil) {
        [self.starList  addChildren:_starList];
    }
    
    [self addChild:self.starList];
    
    
    // recents
    self.recentsList = [wsCollectionObject new];
    self.recentsList.title = @"Recent items";
    self.recentsList.fontAwesomeIconString = fa_clock_o;
    self.recentsList.description = @"Items last viewed on this device";
    
    NSArray* _recentsList = [[WSMetaDataStore sharedDataStore] recentsList];
    if (_recentsList !=nil) {
        [self.recentsList addChildren:_recentsList];
    }
    [self addChild:self.recentsList];
    

    
    // Settings
    self.optionsList = [wsCollectionObject new];
    self.optionsList.fontAwesomeIconString = fa_bookmark;
    self.optionsList.title = @"System";
    self.optionsList.description = @"Settings, Accounts, etc";
    self.optionsList.fontAwesomeIconString = fa_folder;
    
    
    wsWebPageObject* mainHelp = [wsWebPageObject new];
    mainHelp.title = @"Help";
    mainHelp.description = @"How to use this app";
    mainHelp.fullURL = [NSURL URLWithString:@"http://biolucida.net/viewer/help/Default.htm"];
    mainHelp.fontAwesomeIconString = fa_question_circle;
    
    wsWebPageObject* aboutMBF = [wsWebPageObject new];
    aboutMBF.title = @"About MBF";
    aboutMBF.description = @"Microbrightfield";
    aboutMBF.fullURL = [NSURL URLWithString:@"http://microbrightfield.com"];
    aboutMBF.fontAwesomeIconString = fa_globe;
    
    [self.optionsList addChild:mainHelp];
    [self.optionsList addChild:aboutMBF];
    
    [self addChild:self.optionsList];
    
    // could easily move this into a single array
    
    [self.starList initializeCollection];
    [self.managedCollection initializeCollection];
    [self.recentsList initializeCollection];
    [self.optionsList initializeCollection];
    
    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        [self.delegate collectionObjectHasNewSections:self];
    }
}


-(NSArray*) collections
{
    return self.children;
}


-(void) refreshAsNewCollection
{
    VerboseLog();
    
    self.originalIndexList = [self validIndexPaths];

    
    [self.managedCollection refreshAsNewCollection];
    
    [self.recentsList removeChildren];
    NSArray* recentsList_ = [[WSMetaDataStore sharedDataStore] recentsList];
    if (recentsList_ !=nil) {
        [self.recentsList addChildren:recentsList_];
    }
    
    [self.starList removeChildren];
    NSArray* starList_ = [[WSMetaDataStore sharedDataStore] starList];
    //    NSLog(@"Star list has %d objects", starList.count);
    
    if (starList_ !=nil) {
        [self.starList  addChildren:starList_];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        
        [self.delegate collectionObjectHasNewSections:self];
    }
}


-(void) refreshAsCurrentCollection
{
    VerboseLog();
    
    self.originalIndexList = [self validIndexPaths];
    
    [self.managedCollection refreshAsCurrentCollection];
    
    [self.recentsList removeChildren];
    NSArray* recentsList = [[WSMetaDataStore sharedDataStore] recentsList];
    if (recentsList !=nil) {
        [self.recentsList addChildren:recentsList];
    }
    
    
    [self.starList removeChildren];
    NSArray* starList = [[WSMetaDataStore sharedDataStore] starList];
    //    NSLog(@"Star list has %d objects", starList.count);
    
    if (starList !=nil) {
        [self.starList  addChildren:starList];
    }
    

    
    if ([self.delegate respondsToSelector:@selector(collectionObjectHasNewSections:)]) {
        
        [self.delegate collectionObjectHasNewSections:self];
    }
    else{
        //        NSLog(@"doesn't have delegate");
    }
    
    

}
@end
