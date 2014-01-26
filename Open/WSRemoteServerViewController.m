//
//  WSRemoteServerViewController.m
//  Open
//
//  Created by Rich Stoner on 10/28/13.
//  Copyright (c) 2013 WholeSlide. All rights reserved.
//

#import "WSRemoteServerViewController.h"

//#import "WSRemoteServerDescription.h"

#import "WSPopOverContentViewController.h"

#import <RATreeView.h>
#import "RADataObject.h"

#import <SSZipArchive.h>
#import <zipzap/zipzap.h>
#import <WYPopoverController.h>
#import <MPColorTools.h>


@interface WSRemoteServerViewController () <RATreeViewDelegate, RATreeViewDataSource, UITableViewDelegate, WYPopoverControllerDelegate>
{
    WYPopoverController* popoverController;
    
    

}

@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) id expanded;
@property (weak, nonatomic) RATreeView *treeView;

@property (strong, nonatomic) WSRemoteServerDescription* remoteServerDescription;


@end






@implementation WSRemoteServerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    WYPopoverBackgroundView* popoverAppearance = [WYPopoverBackgroundView appearance];
    //    [popoverAppearance setAutoresizingMask:UIViewAutoresizingNone];
    //    [popoverAppearance setTintColor:[UIColor colorWithRed:235./255. green:235./255. blue:235./255. alpha:1]];
    [popoverAppearance setTintColor:kTabActiveBackgroundColor];
    //    [popoverAppearance setOuterStrokeColor:[UIColor darkGrayColor]];
    //    [popoverAppearance setInnerStrokeColor:[UIColor darkGrayColor]];
    [popoverAppearance setOuterCornerRadius:10];
    [popoverAppearance setMinOuterCornerRadius:10];
    
    [popoverAppearance setOuterShadowBlurRadius:6];
    [popoverAppearance setOuterShadowColor:[UIColor colorWithWhite:0 alpha:0.85]];
    [popoverAppearance setOuterShadowOffset:CGSizeMake(0, 1)];
    
    //    [popoverAppearance setGlossShadowColor:[UIColor darkGrayColor]];
    //    [popoverAppearance setGlossShadowOffset:CGSizeMake(0, 1)];
    
    [popoverAppearance setBorderWidth:0];
    
    [popoverAppearance setArrowHeight:0];
    [popoverAppearance setArrowBase:0];
    
    [popoverAppearance setInnerCornerRadius:10];
    [popoverAppearance setInnerShadowBlurRadius:10];
    [popoverAppearance setInnerShadowColor:[UIColor colorWithWhite:0 alpha:0.75]];
    [popoverAppearance setInnerShadowOffset:CGSizeMake(0, 0)];
    
    [popoverAppearance setViewContentInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    
    
    
    
    //    UINavigationBar* navBarAppearance = [UINavigationBar appearanceWhenContainedIn:[WYPopoverBackgroundView class], [UINavigationController class], nil];
    //
    //    [navBarAppearance setTitleTextAttributes:@{
    //                                               UITextAttributeTextColor : [UIColor darkGrayColor],
    //                                               UITextAttributeTextShadowColor: [UIColor whiteColor],
    //                                               UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 0)]
    //                                               }];
    
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    //    if(!dirs || dirs.count ==0)
    
    //    NSURL *rootUrl = [dirs lastObject];
    
    //    self.data = [self rowsForDirectory:[rootUrl URLByDeletingLastPathComponent]];
    //    self.data = [self rowsForDirectory:rootUrl];
    
    RATreeView *treeView = [[RATreeView alloc] initWithFrame:self.view.frame];
    treeView.delegate = self;
    treeView.dataSource = self;
    treeView.backgroundColor = kTabActiveBackgroundColor;
    //    treeView.separatorStyle = RATreeViewCellSeparatorStyleSingleLine;
    treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
    treeView.allowsSelection = YES;
    
    [treeView reloadData];
    //    [treeView expandRowForItem:phone withRowAnimation:RATreeViewRowAnimationLeft]; //expands Row
    //    [treeView setBackgroundColor:UIColorFromRGB(0xF7F7F7)];
    
    self.treeView = treeView;
    [self.view addSubview:treeView];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNotificationHasUpdatedFolderList object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        
        if(self.remoteServerDescription)
        {
            
            self.data = [self subfoldersForFolder:self.remoteServerDescription.folders];
            
            [treeView reloadData];
        }
    }];
}


- (NSArray *) subfoldersForFolder:(NSArray*) theArray
{
    NSMutableArray* folderArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary* folderDescription in theArray) {
        
        RADataObject* folderObject = [[RADataObject alloc] initWithName:folderDescription[@"name"]
                                                                    url:folderDescription[@"folder_path"]
                                                               children:nil
                                                            isDirectory:nil];
        
        id subfolders = folderDescription[@"folders"];
        
        // there are more folders
        if([subfolders isKindOfClass:[NSArray class]]) {
        
            [folderObject setChildren:[self subfoldersForFolder:subfolders]];
        }
        else {
        }

        [folderArray addObject:folderObject];
        
    }
    
    return folderArray;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        CGRect statusBarViewRect = [[UIApplication sharedApplication] statusBarFrame];
        float heightPadding = statusBarViewRect.size.height+self.navigationController.navigationBar.frame.size.height;
        self.treeView.contentInset = UIEdgeInsetsMake(heightPadding, 0.0, 0.0, 0.0);
        self.treeView.contentOffset = CGPointMake(0.0, -heightPadding);
    }
    self.treeView.frame = self.view.bounds;
}



#pragma mark TreeView Delegate methods
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 44;
}

- (NSInteger)treeView:(RATreeView *)treeView indentationLevelForRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    return 3 * treeNodeInfo.treeDepthLevel;
}

- (BOOL)treeView:(RATreeView *)treeView shouldExpandItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    
    return YES;
}

- (BOOL)treeView:(RATreeView *)treeView shouldItemBeExpandedAfterDataReload:(id)item treeDepthLevel:(NSInteger)treeDepthLevel
{
    if ([item isEqual:self.expanded]) {
        return YES;
    }
    
    return NO;
}

- (void)treeView:(RATreeView *)treeView willDisplayCell:(UITableViewCell *)cell forItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    
    cell.backgroundColor = [kTabActiveBackgroundColor colorDarkenedBy:0.2 * treeNodeInfo.treeDepthLevel];

}

#pragma mark -


- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo {
    

    
    if (self.remoteServerDescription) {
    
        RADataObject* folder = (RADataObject*)item;
        
        NSMutableString* folderPath = [[NSMutableString alloc] initWithString:folder.name];
        
        RATreeNodeInfo* parentNode = treeNodeInfo.parent;
        
        for (int i=0; i<treeNodeInfo.treeDepthLevel; i++) {
            
            RADataObject* obj = (RADataObject*)parentNode.item;
            [folderPath insertString:[NSString stringWithFormat:@"%@/", obj.name] atIndex:0];
            
            parentNode = parentNode.parent;
        }
        

        [self.remoteServerDescription getImageListForPath:folderPath withCallback:@selector(exampleCallback)];
        
        
    }
    
    
    
//    if ([obj.name rangeOfString:@"ImageProperties.xml"].location != NSNotFound) {
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPresentTiledImageViewer object:obj.url];
//        
//        
//        //        UITableViewCell* cell = [treeView cellForItem:item];
//        
//        
//    }
    
    //    NSString* extension = [url pathExtension];
    //
    //    if ([extension isEqualToString:@"zip"]) {
    //
    //
    //        NSLog(@"%@", url);
    //
    //        // Unzipping
    //        //            NSString *zipPath = @"path_to_your_zip_file";
    //        //            NSString *destinationPath = @"path_to_the_folder_where_you_want_it_unzipped";
    //        //            [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath];
    //        //
    //
    //    }
    
//    if ([[obj.url pathExtension] isEqualToString:@"zip"]) {
//        
//        //        NSArray* test = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[obj.url URLByAppendingPathComponent:@"/"].absoluteString error:nil];
//        //
//        //        NSLog(@"%@", [obj.url URLByAppendingPathComponent:@"/Contents/"].absoluteString);
//        //        NSLog(@"%@", test);
//        //
//        ZZArchive* archive = [ZZArchive archiveWithContentsOfURL:obj.url];
//        
//        BOOL hasImageProperties=NO;
//        
//        for (ZZArchiveEntry* entry in archive.entries) {
//            
//            if ([entry.fileName rangeOfString:@"ImageProperties.xml"].location != NSNotFound) {
//                
//                NSLog(@"%@", entry.fileName);
//                hasImageProperties = YES;
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPresentTiledImageViewer object:obj.url];
//                
//                break;
//            }
//        }
//        
//        //        ZZArchiveEntry* firstArchiveEntry = oldArchive.entries[0];
//        //        NSLog(@"%@", firstArchiveEntry.fileName);
//        
//        //        NSLog(@"The first entry's uncompressed size is %lu bytes.", firstArchiveEntry.uncompressedSize);
//        //        NSLog(@"The first entry's data is: %@.", firstArchiveEntry.data);
//        //
//        
//        //         copyItemAtPath:[NSURL URLForCachesDirectoryWithAppendedPath:@"ZIP_FILE.zip/Contents/Test.m4a"].path
//        //                                                toPath:[NSURL URLForCachesDirectoryWithAppendedPath:@"Test.m4a"].path
//        //                                                 error:nil];
//        
//        
//        ////        NSString* destination = [(NSURL*)obj.url URLByDeletingPathExtension].absoluteString;
//        //        NSString* destination = [(NSURL*)obj.url URLByDeletingLastPathComponent].absoluteString;
//        //        NSLog(@"%@", destination);
//        //        NSString* d2 = [NSString stringWithFormat:@"%@/", destination];
//        
//        //        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        //        NSString *documentsDirectory = [paths objectAtIndex:0];
//        //        NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:@"/Images"];
//        //
//        //        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,obj.name];
//        //        NSString *zipPath = filePath;
//        //
//        //        [SSZipArchive unzipFileAtPath:zipPath toDestination:outputPath];
//        //
//        //        NSLog(@"unziped");
//        
//    }
    
    
}


- (void) exampleCallback
{


}


- (void) loadRemoteServer:(NSURL*) theURL
{
    self.remoteServerDescription = [[WSRemoteServerDescription alloc] initWithName:@"test" url:theURL];
    
    [self.remoteServerDescription getFolderListWithCallback:@selector(exampleCallback)];
    
    
    
    
    
    
//    NSArray *dirs = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
//    //    if(!dirs || dirs.count ==0)
//    
//    NSURL *rootUrl = [dirs lastObject];
//    
//    //    self.data = [self rowsForDirectory:[rootUrl URLByDeletingLastPathComponent]];
//    self.data = [self rowsForDirectory:rootUrl];
    
//    [self.treeView reloadData];
}

//-(RADataObject*) dataFromFolderList {
//    
//    NSDictionary* folderDictionary =
//    
//    
//    
//    
//}


#pragma mark - WYPopoverControllerDelegate

//- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
//{
//    return YES;
//}
//
//- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller
//{
//    if (controller == settingsPopoverController)
//    {
//        settingsPopoverController.delegate = nil;
//        settingsPopoverController = nil;
//    }
//    else if (controller == anotherPopoverController)
//    {
//        anotherPopoverController.delegate = nil;
//        anotherPopoverController = nil;
//    }
//}



#pragma mark TreeView Data Source

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(id)item treeNodeInfo:(RATreeNodeInfo *)treeNodeInfo
{
    NSInteger numberOfChildren = [treeNodeInfo.children count];
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    
    cell.backgroundColor = kTabActiveBackgroundColor;
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of children %d", numberOfChildren];
    cell.textLabel.text = ((RADataObject *)item).name;
    cell.textLabel.font = kDirectoryFont;
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    if (treeNodeInfo.treeDepthLevel == 0) {
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    //    }
    
    return cell;
}

- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return [self.data count];
    }
    
    RADataObject *data = item;
    return [data.children count];
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(id)item
{
    RADataObject *data = item;
    if (item == nil) {
        return [self.data objectAtIndex:index];
    }
    
    return [data.children objectAtIndex:index];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
