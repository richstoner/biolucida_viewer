//
//  WSSetPreviewViewController.m
//  Open
//
//  Created by Rich Stoner on 10/29/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

// this will present an array of collections



#import "wsCollectionViewController.h"
#import "wsCollectionObject.h"

#import "WSCollectionHeaderCell.h"
#import "wsImagePreviewCell.h"

#import "wsDefaultCollectionCell.h"
#import "wsDetailedCollectionCell.h"


#import "WSCollectionViewItemCell.h"
#import "LessBoringFlowLayout.h"
#import "wsBiolucidaServerObject.h"
#import "wsBiolucidaCollectionObject.h"

#import "WSAddNewLocationViewController.h"
#import "wsPreviewFrameViewController.h"

#import "RNBlurModalView.h"

#import <NHAlignmentFlowLayout.h>
#import <NHBalancedFlowLayout.h>
#import <RFQuiltLayout.h>
#import <DMDynamicWaterfall.h>

#import "wsLargeImageCollectionCell.h"

#import "wsCollectionLayout.h"

#import "wsCollectionPath.h"

typedef enum {
    thumbnailSmall,
    thumbnailMedium,
    thumbnailLarge
} thumbnailSizeOption;

static NSString * const CollectionCellIdentifier = @"CollectionCell";
static NSString * const CollectionImagePreviewIdentifier = @"CollectionPreviewCell";
static NSString * const CollectionHeaderIdentifier = @"HeaderCell";

static NSString * const CollectionDefaultCellidentifier = @"DefaultCell";
static NSString * const CollectionDetailCellidentifier = @"DetailCell";
static NSString * const CollectionRenderObjectCellIdentifier = @"RenderCell";

@interface wsCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, wsCollectionDelegate>
{
    BOOL canGoBack;
    BOOL goingForward;
    
    
}

@property(nonatomic, assign) thumbnailSizeOption thumbnailSize;


@property (weak, nonatomic) UICollectionView* collectionView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

/**
 The data source used to populate the collection
 */
@property (nonatomic, strong) wsCollectionObject* collectionSource;

/**
 Temporary object, used while attempting to load async data source
 */
@property (nonatomic, strong) wsCollectionObject* temporaryObj;

/**
 The  collection object
 */
@property (nonatomic, strong) NSArray* collections;

/**
 A processing queue
 */
@property (nonatomic, strong) NSOperationQueue *thumbnailQueue;

/**
 A short navigation stack, used for history
 */
@property (nonatomic, strong) NSMutableArray* historyStack;


/**
 A visual representation of the history
 */
@property (nonatomic, strong) UIToolbar* historyView;





@end


@implementation wsCollectionViewController

@synthesize collections;
@synthesize collectionSource;
@synthesize historyStack;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.thumbnailQueue = [[NSOperationQueue alloc] init];
        self.thumbnailQueue.maxConcurrentOperationCount = 3;


        self.collectionSource = [[WSMetaDataStore sharedDataStore] initialObjectCollection];;
        self.collectionSource.delegate = self;
        self.collections = self.collectionSource.collections;
        [self.collectionSource initializeCollection];
        
        self.thumbnailSize = thumbnailMedium;
        
        self.historyStack = [NSMutableArray new];
        
    }
    return self;
}


-(wsObject*) getCurrentObject
{
    return self.collectionSource;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect contentsFrame = self.view.frame;
    contentsFrame.size.height -= 44.0;
    self.view.frame = contentsFrame;
    self.view.backgroundColor = kTabActiveBackgroundColor;
    
//    wsCollectionLayout *layout= [[wsCollectionLayout alloc] init];
    LessBoringFlowLayout* layout = [[LessBoringFlowLayout alloc] init];
    
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10.f;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 40, 10);
    
    
    CGRect collectionFrame = self.view.frame;
    
#if ToolBarOnTop
    
    collectionFrame.size.height -= CollectionToolBarHeight;
    collectionFrame.origin.y += CollectionToolBarHeight;
    
#else
    
    collectionFrame.size.height -= CollectionToolBarHeight;

#endif

    
    
    UICollectionView * collectionView= [[UICollectionView alloc] initWithFrame:collectionFrame collectionViewLayout:layout];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    collectionView.contentInset = UIEdgeInsetsMake(20, 10, 20, 10);
//    if (IS_IPAD) {
    
//    }
//    else{
//
//         collectionView.contentInset = UIEdgeInsetsMake(2, 4, 4, 2);
//    }

    [collectionView setDataSource:self];
    [collectionView setDelegate:self];
    [collectionView setBackgroundColor:kCollectionViewBackgroundColor];
    
    self.collectionView = collectionView;
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.bounces = YES;
    self.collectionView.scrollsToTop = YES;

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = UIColorFromRGB(0x00ccff);
    [self.refreshControl addTarget:self action:@selector(refreshControlAction:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    [self.collectionView registerClass:[wsDefaultCollectionCell class] forCellWithReuseIdentifier:CollectionDefaultCellidentifier];
    
    [self.collectionView registerClass:[wsDetailedCollectionCell class] forCellWithReuseIdentifier:CollectionDetailCellidentifier];
    
    [self.collectionView registerClass:[wsLargeImageCollectionCell class] forCellWithReuseIdentifier:CollectionRenderObjectCellIdentifier];
    
    
    [self.collectionView registerClass:[WSCollectionHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:CollectionHeaderIdentifier];
    
    self.thumbnailQueue = [[NSOperationQueue alloc] init];
    self.thumbnailQueue.maxConcurrentOperationCount = 3;
    
    [self.view addSubview:self.collectionView];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.collectionView addGestureRecognizer:pinch];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.collectionView addGestureRecognizer:swipe];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showMoreInformationAboutItem:)];
    longPress.minimumPressDuration = 0.25;
    longPress.delegate = self;
    [self.collectionView addGestureRecognizer:longPress];
    

    
    [self createHistoryViewContainer];
    
}


-(void) showMoreInformationAboutItem:(UILongPressGestureRecognizer*) gr
{
    if (gr.state == UIGestureRecognizerStateBegan)
    {
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[gr locationInView:self.collectionView]];
        
        
        wsObject* obj = [self objectForIndexPath:indexPath];
        
        if (obj) {
            
            NSDictionary* msg = @{@"source": self.collections[indexPath.section],
                                  @"object": obj};

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPresentMoreInformation object:msg];
            
            
        }
        

    }
}



- (void) handleSwipe:(UISwipeGestureRecognizer*)gestureRecognizer
{

    [self goToPreviousObject];

}

- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{

    // only go up or down in size if possible (aka mini state machine)
//    
//    if (gestureRecognizer.scale < 0.5 ) {
//    
//        if (canGoBack) {
//
//            switch (self.thumbnailSize) {
//                case thumbnailLarge:
//                case thumbnailMedium:
//                    
//                    self.thumbnailSize--;
//                    
//                    [self.collectionSource refreshAsNewCollection];
//
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//        }
//
//        canGoBack = NO;
//    }
//    else if (gestureRecognizer.scale > 1.5){
//        
//        if (canGoBack) {
//            
//            switch (self.thumbnailSize) {
//                case thumbnailSmall:
//                case thumbnailMedium:
//                    
//                    self.thumbnailSize++;
//                    
//                    [self.collectionSource refreshAsNewCollection];
//
//                    
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//            
//        }
//        
//        canGoBack = NO;
//        
//    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        canGoBack = YES;
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        canGoBack = NO;
    }

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{

    if (kind == UICollectionElementKindSectionHeader) {

        WSCollectionHeaderCell* view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:CollectionHeaderIdentifier forIndexPath:indexPath];
        
        wsCollectionObject* obj = self.collections[indexPath.section];
        
        [view loadObject:obj];
        
        return view;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    // only show the header if the section contains items
    wsCollectionObject* obj = self.collections[section];
    
    if (obj.children.count > 0) {
        return CGSizeMake(0, 40);
    }
    
    return CGSizeMake(0, 40);
}




//
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // get the dictionary at section, then load the first object which is an array of children objects
    wsCollectionObject* obj = self.collections[section];
    
    return obj.children.count;
}




- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
#warning Rewrite to use class by class cell view type
    
    wsDataObject* obj = (wsDataObject*)[self objectForIndexPath:indexPath];
    
    WSCollectionViewItemCell* cell;
    
    // order of priority:
    // use remote thumbnail,
    // else use local image
    // else use fontawesome icon
    // else use default font awesome
    
    if([obj respondsToSelector:@selector(thumbnailURL)])
    {
        
        cell = (WSCollectionViewItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionRenderObjectCellIdentifier forIndexPath:indexPath];
        
        // load photo images in the background
        __weak wsCollectionViewController *weakSelf = self;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // then set them via the main queue if the cell is still visible.
                if ([weakSelf.collectionView.indexPathsForVisibleItems containsObject:indexPath]) {
                    
                    WSCollectionViewItemCell* cell =
                    (WSCollectionViewItemCell*)[weakSelf.collectionView cellForItemAtIndexPath:indexPath];
                    
                    [cell.imageView setImageWithURL:[obj performSelector:@selector(thumbnailURL)]];
                    
                }
            });
        }];
        
        operation.queuePriority = (indexPath.item == 0) ?
        NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
        
        [self.thumbnailQueue addOperation:operation];
    }
    else if(obj.localIconString != nil)
    {
        cell = (WSCollectionViewItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionDefaultCellidentifier forIndexPath:indexPath];
        
        [cell.imageView setImage:[UIImage imageNamed:obj.localIconString]];
        
    }
    else if (obj.fontAwesomeIconString != nil)
    {
        
        cell = (WSCollectionViewItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionDetailCellidentifier forIndexPath:indexPath];
        
        [cell setFontAwesomeIcon:obj.fontAwesomeIconString];
    }
    else
    {
        cell = (WSCollectionViewItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionDetailCellidentifier forIndexPath:indexPath];
        
        [cell setFontAwesomeIcon:fa_minus];
    }
    
    [cell setPrimaryText:obj.localizedName];
    [cell setSecondaryText:obj.localizedDescription];
    
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    wsDataObject* obj = (wsDataObject*)[self objectForIndexPath:indexPath];
    
    
    if (IS_IPAD) {
        
        if([obj respondsToSelector:@selector(thumbnailURL)])
        {
            
            return CGSizeMake(230, 180);
            
        }
        else if(obj.localIconString != nil)
        {
            return CGSizeMake(230, 140);
            
        }
        else if (obj.fontAwesomeIconString != nil)
        {
            
            return CGSizeMake(230, 80);
        }
        else
        {
            return CGSizeMake(230, 80);
            
        }
        
        return CGSizeMake(230, 140);
        
    }
    
    else
    {
        switch (self.thumbnailSize) {
            case thumbnailSmall:
                
                return CGSizeMake(140, 100);
                
                break;
            case thumbnailMedium:
                
                return CGSizeMake(140,140);
                
                break;
                
            case thumbnailLarge:
                
                return CGSizeMake(140,200);
                
                break;
                
            default:
                break;
        }
    }
    
}



- (NSString*) titleForItemAtSection:(NSUInteger)section withIndex:(NSUInteger)index
{
    wsObject* parentObject = self.collections[section];
    wsObject* obj = parentObject.children[index];
    
    return obj.localizedName;
}


- (wsObject*) objectForItemAtSection:(NSUInteger)section withIndex:(NSUInteger)index
{
    wsObject* parentObject = self.collections[section];
    wsObject* obj = parentObject.children[index];
    
    return obj;
}



- (wsObject*) objectForIndexPath:(NSIndexPath*) indexPath
{
    if (indexPath)
    {
        
        if (self.collections.count >= indexPath.section) {

            wsObject* parentObject = self.collections[indexPath.section];
    
            if (parentObject.children.count >= indexPath.row) {
                
                return parentObject.children[indexPath.row];
                
            }
            
        }
    }
    return nil;
}




- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.collections.count;
}







-(void) refreshCollectionSections
{
    VerboseLog();
    
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collections.count)]];
        
        self.collections = self.collectionSource.collections;
        
        [self.collectionView insertSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.collections.count)]];
    }
                                      completion:^(BOOL finished) {
                                          

                                          
                                      }];
}



-(void) refreshCollectionWithObject:(wsCollectionObject*) newCollectionObject
{
    // calculate index set diff
    
    // previous
    NSSet* prePaths = self.collectionSource.originalIndexList;
    NSSet* postPaths = [newCollectionObject validIndexPaths];
    
    // pre - post => sets that need to be removed (aka are not present in post set)
    NSMutableSet* ipToRemove = [NSMutableSet setWithSet:prePaths];

    // post - pre => sets that remain or need to be added
    NSMutableSet* ipToAdd = [NSMutableSet setWithSet:postPaths];

    [ipToRemove minusSet:postPaths];
    [ipToAdd minusSet:prePaths];

    NSLog(@"%@", ipToRemove);
    NSLog(@"%@", ipToAdd);
    
    [self.collectionView selectItemAtIndexPath:nil animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView deleteItemsAtIndexPaths:[ipToRemove allObjects]];
        
        [self.collectionView insertItemsAtIndexPaths:[ipToAdd allObjects]];

    }
                                  completion:^(BOOL finished) {
//                                      [self.collectionView reloadData];
                                  }];
}


-(void)refreshControlAction:(id)sender {
    
    [self.refreshControl endRefreshing];
    
    [self.collectionSource refreshAsCurrentCollection];

}



#pragma mark - Selecting items -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // get the object you've selected
    wsObject* obj = [self objectForIndexPath:indexPath];

    if ([obj isKindOfClass:[wsCollectionObject class]]) {
    
        wsCollectionObject* co = (wsCollectionObject*)obj;
        self.temporaryObj = co;
        goingForward = YES;
        [co setDelegate:self];
        
        [co initializeCollection];
        
    }
    else if ([obj isKindOfClass:[wsActionObject class]]){

        // if action, perform this notification string with the base object
        
        NSDictionary* msg = @{@"action": obj,
                              @"object": self.collectionSource.children[indexPath.section]};
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:obj.notificationString object:msg];
        
    }
    else
    {
        // default action... do default notification with the object itself
        [[NSNotificationCenter defaultCenter] postNotificationName:obj.notificationString object:obj];
        
    }

//    if ([obj isKindOfClass:[wsActionObject class]]) {
//        
//        
//        
//    }
//    
//    if ([obj isKindOfClass:[wsActionObject class]]) {
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:obj.notificationString object:obj];
//        
//    }
//    
    
    
//    // set the update callback if needed
//    if ([obj respondsToSelector:@selector(callback)]) {
//        
//        NSLog(@"object contains callback functionality, define");
//        
//        // Batch this so the other sections will be updated on completion
//        __weak wsCollectionViewController *weakSelf = self;
//        
//        ((wsServerObject*)obj).callback =^ (BOOL refreshSuccess) {
//            
//            if (refreshSuccess) {
//                [weakSelf refreshCollectionLayout];
//            }
//        };
//    }
//    

    
    // if it is a collection object, just load it and let the interface figure it out
//    if ([obj isKindOfClass:[wsCollectionObject class]]) {
//        
//        [self refreshCollectionLayout];
//    }
    
//    
//    if ([obj isKindOfClass:[wsServerObject class]]) {
//    
//        [(wsServerObject*)self.dataObj loadRootPath];
//
//    }
}


#pragma mark - History stack -

-(void) createHistoryViewContainer
{

    [[UIBarButtonItem appearance] setTitleTextAttributes:
     @{NSFontAttributeName: kHistoryTitleFont,
       NSBackgroundColorAttributeName: kHistoryBackgroundColor}
                                                forState:UIControlStateNormal];
    
    
#if ToolBarOnTop

    self.historyView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CollectionToolBarHeight)];

#else
    
    self.historyView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - CollectionToolBarHeight, self.view.frame.size.width, CollectionToolBarHeight)];
    
#endif
    self.historyView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    self.historyView.barTintColor = kHistoryBackgroundColor;
    [self.view addSubview:self.historyView ];
}

-(void) updateHistoryView
{
    if (self.historyView) {
        
        NSMutableArray* items = [NSMutableArray new];
        
        int i=0;
        for (wsObject* obj in self.historyStack) {
            
            UIBarButtonItem* historyItem = [[UIBarButtonItem alloc] initWithTitle:obj.localizedName style:UIBarButtonItemStylePlain target:self action:@selector(selectHistoryitem:)];
            
            historyItem.tintColor = kHistoryTitleColor;
            historyItem.tag = i++;
            [items addObject:historyItem];

            UIBarButtonItem * divider = [[UIBarButtonItem alloc] initWithTitle:@"|" style:UIBarButtonItemStylePlain target:nil action:nil];
            divider.tintColor = kHistorySpacerColor;
            [items addObject:divider];
            
        }
        
        [self.historyView setItems:items animated:YES];
        
    }
}

-(void) selectHistoryitem:(UIBarButtonItem*)sender{
    
    VerboseLog();
//    NSLog(@"%@", sender);
//    NSLog(@"%d", sender.tag);

    [self goToHistoryIndex:sender.tag];
    
}

-(void) goToPreviousObject
{
    wsCollectionObject* co = [self popFromHistoryStack];
    
    if (co) {
        
        self.temporaryObj = co;
        self.temporaryObj.delegate = self;
        [self.temporaryObj refreshAsNewCollection];
    }
}

-(void) goToHistoryIndex:(NSUInteger) index
{
    wsCollectionObject* co = self.historyStack[index];
    
    if (co) {

        [self.historyStack removeObjectsInRange:NSMakeRange(index, self.historyStack.count - index  )];
        [self updateHistoryView];
        
        
        self.temporaryObj = co;
        self.temporaryObj.delegate = self;
        [self.temporaryObj refreshAsNewCollection];
        

    }
    
}

-(void) pushToHistoryStack:(wsCollectionObject*) theObject
{
    if (![theObject isEqual:[self.historyStack lastObject]]) {
        
        VerboseLog(@"Pushed %@", theObject.class);
        
        [self.historyStack addObject:theObject];
    }
    else{
        VerboseLog(@"Trying to push current obj to history stack");
    }

    
        [self updateHistoryView];

}

-(wsCollectionObject*) popFromHistoryStack
{
    VerboseLog();
    
    wsCollectionObject* co = nil;
    
    if (self.historyStack.count > 0) {
        
        // verify something is present
        co = self.historyStack.lastObject;
        
        [self.historyStack removeLastObject];
    }
    
    [self updateHistoryView];
    
    return co;
}



#pragma mark - collection object delegates

-(void) collectionObjectFailedToLoad:(wsCollectionObject *)collectionObject
{
    VerboseLog();
    self.temporaryObj = nil;
    
    // maybe present a modal here that connection failed
    
    // unselect
    [self.collectionView selectItemAtIndexPath:nil animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

-(void) collectionObjectHasNewSections:(wsCollectionObject *)collectionObject
{
    VerboseLog();
    
    // push the previous to the stack, iff going forward (ignore reloads and backwards navigation
    if (goingForward) {
        [self pushToHistoryStack:self.collectionSource];
    }
    goingForward = NO;

    // this means that the collection object we're trying to load has data and should be presented as the next view
    // this doesn't mean that the collection is completely done loading
    
    if (self.temporaryObj) {
        
        self.collectionSource = self.temporaryObj;
        self.temporaryObj = nil;
    }
    
    [self refreshCollectionSections];
    
}

-(void) collectionObjectHasNewItems:(wsCollectionObject *)collectionObject
{
    [self refreshCollectionWithObject:collectionObject];
}

-(void) collectionShouldReloadData:(wsCollectionObject *)collectionObject
{
    [self.collectionView reloadData];
}

#pragma mark - Notifications

-(void) registerNotifications
{
    VerboseLog();
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGoBackNotification:) name:kNotificationGoBack object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddObjectSuccessNotification:) name:kNotificationAddObjectSuccess object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(HandleOpenObject:) name:kNotificationOpenObject object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRemoveObject:) name:kNotificationRemoveObject object:nil];
    
}

-(void) unregisterNotifications
{

    VerboseLog();
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}






-(void) handleGoBackNotification:(NSNotification*) notification
{
    VerboseLog();
    
    [self goToPreviousObject];
}




-(void) HandleOpenObject:(NSNotification*) notification {

    VerboseLog(@"%@", self.collectionSource.class);    
    
    wsObject* obj = [notification object];
    
//    NSLog(@"%@", obj.class);
    
    if ([obj isKindOfClass:[wsCollectionObject class]]) {
        
        wsCollectionObject* co = (wsCollectionObject*)obj;
        self.temporaryObj = co;
        goingForward = YES;
        [co setDelegate:self];
        
        [co initializeCollection];
        
    }
    else if ([obj isKindOfClass:[wsActionObject class]]){
     
        // receives
        //        NSDictionary* msg = @{@"action": obj,
        //                              @"collection": self.collectionSource.children[indexPath.section]};
        
        [[NSNotificationCenter defaultCenter] postNotificationName:obj.notificationString object:obj];
        
    }
    else{
        
        // default action... do default notification with the object itself
        [[NSNotificationCenter defaultCenter] postNotificationName:obj.notificationString object:obj];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModal object:nil];
}


-(void) handleRemoveObject:(NSNotification*) notification {
    
    NSDictionary* msg = notification.object;
    
    wsCollectionObject* collectionObject = msg[@"source"];
    wsObject* objectToDelete = msg[@"object"];
    
    if([collectionObject respondsToSelector:@selector(deleteChildAndSave:)])
    {
        [collectionObject performSelectorOnMainThread:@selector(deleteChildAndSave:) withObject:objectToDelete waitUntilDone:YES];
    }
    else{
        
#if ISMBF
        
        [[WSMetaDataStore sharedDataStore] removeObjectFromStarList:objectToDelete];
#else
    
        
        [collectionObject removeChild:objectToDelete];
        
#endif

    }
    
    // put this in a cache until it returns with new data
    self.temporaryObj = self.collectionSource;
    
    [self.collectionSource refreshAsNewCollection];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModal object:nil];
}


-(void) handleAddObjectSuccessNotification:(NSNotification*) notification
{
    
    wsCollectionObject* sourceObject = notification.object[@"source"];
    wsObject* objectToAdd = notification.object[@"object"];
    
    VerboseLog(@"Addding %@ into %@", objectToAdd.class, sourceObject.class);
    
    if ([sourceObject respondsToSelector:@selector(addChildAndSave:)]) {

        [sourceObject performSelectorOnMainThread:@selector(addChildAndSave:) withObject:objectToAdd waitUntilDone:YES];
    }
    
    // put this in a cache until it returns with new data

    self.temporaryObj = self.collectionSource;
    
    [self.collectionSource initializeCollection];


    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDismissModal object:nil];
    
}

//-(void) handleAddObjectNotification:(NSNotification*) notification
//{
//    NSDictionary* msg = [notification object];
//    
//    VerboseLog(@"%@", self.collectionSource.class);
//    
//    self.modalViewController = [[WSAddNewLocationViewController alloc] init];
//    self.modal = [[RNBlurModalView alloc] initWithViewController:self.parentViewController.parentViewController view:self.modalViewController.view];
//    self.modal.animationOptions = UIViewAnimationOptionTransitionCrossDissolve;
//    
//    WSAddNewLocationViewController* anlvc = (WSAddNewLocationViewController*)self.modalViewController;
//    [anlvc setSourceObject:msg[@"object"]];
//    
//    [self.modal show];
//
//    NSDictionary* msg = [notification object]
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:<#(NSString *)#> object:<#(id)#>]
//}


@end


