//////////////////////////////////////////////////////////////////////////////////////
//
//    This software is Copyright © 2013 WholeSlide, Inc. All Rights Reserved.
//
//    Permission to copy, modify, and distribute this software and its documentation
//    for educational, research and non-profit purposes, without fee, and without a
//    written agreement is hereby granted, provided that the above copyright notice,
//    this paragraph and the following three paragraphs appear in all copies.
//
//    Permission to make commercial use of this software may be obtained by contacting:
//
//    Rich Stoner, WholeSlide, Inc
//    8070 La Jolla Shores Dr, #410
//    La Jolla, CA 92037
//    stoner@wholeslide.com
//
//    This software program and documentation are copyrighted by WholeSlide, Inc. The
//    software program and documentation are supplied "as is", without any
//    accompanying services from WholeSlide, Inc. WholeSlide, Inc does not warrant
//    that the operation of the program will be uninterrupted or error-free. The
//    end-user understands that the program was developed for research purposes and is
//    advised not to rely exclusively on the program for any reason.
//
//    IN NO EVENT SHALL WHOLESLIDE, INC BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
//    SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
//    OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF WHOLESLIDE,INC
//    HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. WHOLESLIDE,INCSPECIFICALLY
//    DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE PROVIDED
//    HEREUNDER IS ON AN "AS IS" BASIS, AND WHOLESLIDE,INC HAS NO OBLIGATIONS TO
//    PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS UNLESS
//    OTHERWISE STATED.
//
//////////////////////////////////////////////////////////////////////////////////////
//
//    WSConstants.h
//    Open
//

// system

#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CATiledLayer.h>

// pods
//
#import <RATreeView.h>
#import <AFNetworking/AFNetworking.h>
#import <UIImageView+AFNetworking.h>
#import <FontAwesome.h>
#import <WYPopoverController.h>
#import <MPColorTools.h>
#import <XMLDictionary.h>
#import <GZIP.h>
#import <DropboxSDK/DropboxSDK.h>

//

#ifndef Open_WSConstants_h
#define Open_WSConstants_h

// Define shared macros here

#define AppDelegate (OWAppDelegate*)[[UIApplication sharedApplication] delegate]
#define IS_IPAD                 (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE               (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5             (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

#define VerboseLog(fmt, ...)    NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)



// Define types (typedef enum) here

typedef enum {
    tabbedViewStateSingle,
    tabbedViewStateDual,
    tabbedViewStateQuad
} tabbedViewState;
//
//
//typedef enum : NSUInteger {
//    defaultTabActionUndefined,
//    defaultTabActionNotification,
//    defaultTabActionPreviewHere,
//    defaultTabActionCustom,
//} defaultTabAction;

typedef enum : NSUInteger {
    defaultButtonActionUndefined,
    defaultButtonActionOpenSelectedInCurrentTab,
    defaultButtonActionOpenSelectedInTab,
    defaultButtonActionResetSelection,
    defaultButtonActionResetView,
    defaultButtonActionAnimateToViewTop,
    defaultButtonActionAnimateToViewBottom,
    defaultButtonActionAnimateToViewRight,
    defaultButtonActionAnimateToViewLeft,
    defaultButtonActionAnimateToViewFront,
    defaultButtonActionAnimateToViewBack,
    defaultButtonActionGoBackWithinTab,
    defaultButtonActionToggleDebug,
} defaultButtonAction;


typedef enum {
    reserveredLayerIDClear,
    reserveredLayerIDAxes,
    reserveredLayerIDOffset,
} reserveredLayerID;

typedef enum {
    reserveredObjectIDClear,
    reserveredObjectIDXAxis,
    reserveredObjectIDYAxis,
    reserveredObjectIDZAxis,
    reserveredObjectIDOffset,
} reserveredObjectID;

struct vertexDataTextured
{
	GLKVector3		vertex;
	GLKVector3		normal;
	GLKVector2      texCoord;
};
typedef struct vertexDataTextured vertexDataTextured;
typedef vertexDataTextured* vertexDataTexturedPtr;


// pulled from cocos2d... not sure why...
/** Subtracts two CGPoint structures.
 @return CGPoint
 @since v0.7.2
 */
static inline CGPoint
CGPointSub(const CGPoint v1, const CGPoint v2)
{
    return CGPointMake(v1.x - v2.x, v1.y - v2.y);
}

static inline CGFloat
CGPointMag(const CGPoint v1)
{
    return sqrtf(powf(v1.x, 2) + powf(v1.y, 2));
}



static inline NSString*
GLKVector2String(const GLKVector2 v1)
{
    return [NSString stringWithFormat:@"(%f, %f)", v1.x, v1.y];
}

static inline NSString*
GLKVector3String(const GLKVector3 v1)
{
    return [NSString stringWithFormat:@"(%f, %f, %f)", v1.x, v1.y, v1.z];
}

static inline NSString*
GLKVector3IntString(const GLKVector3 v1)
{
    return [NSString stringWithFormat:@"(%d, %d, %d)", (int)v1.x, (int)v1.y, (int)v1.z];
}




// Define constant values here

#define NUMBER_OF_SUBVIEWS 1
#define kANIMATE_URGENCY 0.25
#define USE_GL_VIEW 0
#define kThumbnailWidth 200
#define kThumbnailHeight 200
#define kTabHeight 50
#define CollectionToolBarHeight 40
#define ToolBarOnTop 0

#define k3DToolBarHeight 200
#define k3DToolBarWidth 300
#define kZNavHeight 300


// Define colors and textures here

#define kBlueFade GLKVector4Make(0.0, 0.75, 1.0, 0.1)
#define kBindingLightTexture [UIColor colorWithPatternImage: [UIImage imageNamed:@"binding_light"]]
#define kPinStripeSuit [UIColor colorWithPatternImage: [UIImage imageNamed:@"pinstriped_suit"]]

#define kMBFWhite UIColorFromRGB(0xF5F5F5)
#define kMBFGreen UIColorFromRGB(0x007654)
#define kMBFBlue  UIColorFromRGB(0x2971B9)


#define kDURABase UIColorFromRGB(0x1d1f21)

#define kDURABlue UIColorFromRGB(0x00CCFF)

//#define kDURABase UIColorFromRGB(0x34352d)


// Define notification names here

#define kNotificationPresentObject @"kPresentObject"
#define kNotificationShowObjectBrowser @"kShowObjectBrowser"
#define kNotificationAddObject @"kAddNewObject"
#define kNotificationAddObjectSuccess @"kAddNewObjectSuccess"
#define kNotificationRemoveObject @"kRemoveObject"
#define kNotificationOpenObject @"kOpenObject"
#define kNotificationGoBack @"kGoBack"
#define kNotificationOpenSettings @"kOpenSettingsView"
#define kNotificationUpdatePosition @"kUpdatePosition"
#define kNotificationAdjustTileView @"kUpdateTileView"
#define kNotificationRequestDropboxLink @"KNotificationRequestDropboxLink"
#define kNotificationOpenSelection @"kOpenSelection"
#define kNotificationSelectNext @"kSelectNext"
#define kNotificationOpenHelp @"kOpenHelp"
#define kNotificationSaveObjectLocal @"kSaveObjectLocal"
#define kNotificationPresentMoreInformation  @"kPresentMoreInformatino"
#define kNotificationPresentAddServer @"kPresentAddServer"

#define kNotificationServerLoginSuccess @"kServerLoginSuccess"
#define kNotificationServerLoginFailed @"kServerLoginFailure"
#define kNotificationServerLoginMissingValues @"kServerLoginMissingValues"

#define kNotificationDismissModal @"kDismissModal"

#define kNotificationIncreaseZ @"kIncreaseZ"
#define kNotificationDecreaseZ @"kDecreaseZ"
#define kNotificationSetZ @"kSetZ"

// Strings

#define kApplicationName @"Biolucida Viewer"


/* Fonts

 Tab active font
 Tab background font
 
 Section header font
 Section detail font
 
 CollectionItem header font
 CollectionItem detail font
 
 Preview header font
 Preview detail font
 Preview floating label font
 
 History title font
 
 */

#define kSystemMenuFont [UIFont fontWithName:@"AvenirNext-Bold" size:14]

#define kTabActiveFont [UIFont fontWithName:@"AvenirNext-Bold" size:14]
#define kTabBackgroundFont [UIFont fontWithName:@"AvenirNext-Regular" size:14]

#define kSectionHeaderFont [UIFont fontWithName:@"AvenirNext-Bold" size:14]
#define kSectionDetailFont [UIFont fontWithName:@"AvenirNext-Regular" size:12]

#define kCollectionItemHeaderFont [UIFont fontWithName:@"AvenirNext-Bold" size:14]
#define kCollectionItemDetailFont [UIFont fontWithName:@"AvenirNext-Regular" size:10]

#define kPreviewHeaderFont [UIFont fontWithName:@"AvenirNext-Bold" size:16]
#define kPreviewDetailFont [UIFont fontWithName:@"AvenirNext-Regular" size:14]
#define kPreviewFloatingLabelFont [UIFont fontWithName:@"AvenirNext-Bold" size:12]

#define kAddItemFont [UIFont fontWithName:@"AvenirNext-Bold" size:14]
#define kAddItemFloatingLabelFont [UIFont fontWithName:@"AvenirNext-Bold" size:9]

#define kHistoryTitleFont [UIFont fontWithName:@"AvenirNext-Regular" size:14]




/* Colors

 System Menu background
 System Menu label color
 
 Tab container background color
 
 Tab active background color
 Tab active font color
 
 Tab inactive background color
 Tab inactive font color
 
 CollectionViewBackgroundColor
 
 CollectionItem background color
 CollectionItem header font color
 CollectionItem detail font color
 
 CollectionItem Shadow Color
 CollectionItem Shadow Select color
 
 Preview background color
 Preview header font color
 Preview detail font color
 Preview floating label color

 History background color
 History title color
 History spacer color
 
 Accessory Backgroundcolor
 
*/




#define kSystemMenuBackgroundColor          UIColorFromRGB(0x121212)
#define kSystemMenuLabelColor               UIColorFromRGB(0x121212)

#define kTabContainerBackgroundColor        [UIColor lightGrayColor]
#define kAddTabButtonColor                  [UIColor whiteColor]

#define kTabActiveBackgroundColor           kMBFWhite
#define kTabActiveFontColor                 kMBFGreen

#define kTabInactiveBackgroundColor         [UIColor colorWithRed:61.0/255.0 green:61.0/255.0 blue:58.0/255.0 alpha:1.0]
#define kTabInactiveFontColor               [UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:156.0/255.0 alpha:1.0]


#define kCollectionViewBackgroundColor      kMBFWhite

#define kSectionHeaderFontColor             [UIColor blackColor]
#define kSectionDetailFontColor             [UIColor darkGrayColor]
#define kSectionBackgroundColor             kCollectionViewBackgroundColor

#define kCollectionItemBackgroundColor      [UIColor clearColor]
#define kCollectionItemHeaderFontColor      [UIColor darkGrayColor]
#define kCollectionItemDetailFontColor      kMBFBlue

#define kCollectionSystemItemFontColor      [UIColor blackColor]

#define kCollectionItemShadowColor          [UIColor blackColor]
#define kCollectionItemShadowSelectColor    kMBFBlue

#define kPreviewBackgroundColor             kMBFWhite
#define kPreviewHeaderFontColor             [UIColor blackColor]
#define kPreviewDetailFontColor             [UIColor darkGrayColor]
#define kPreviewFloatingLabelColor          kMBFBlue
#define kPreviewTintColor                   kMBFBlue
#define kPreviewActionFontColor             [UIColor blackColor]
#define kPreviewActionSpacerColor           [UIColor lightGrayColor]



#define kAddItemFontColor                   [UIColor darkGrayColor]
#define kAddItemTintColor                   kMBFBlue
#define kAddItemFloatingLabelColor          UIColorFromRGB(0x00cc00)

#define kHistoryBackgroundColor             [UIColor lightGrayColor]
#define kHistoryTitleColor                  kMBFWhite
#define kHistorySpacerColor                 kMBFBlue

#define kAccessoryBackgroundColor           [UIColor colorWithWhite:0.05f alpha:1.0f]
#define kFontAwesomeIconColor               kMBFBlue

#define k3DBackgroundColor                  [UIColor colorWithWhite:0.05f alpha:1.0f]





#import "duraModel.h"
#import "WSMetaDataStore.h"



#endif


















