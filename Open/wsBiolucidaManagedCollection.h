//
//  wsBiolucidaManagedCollection.h
//  Open
//
//  Created by Rich Stoner on 1/3/14.
//  Copyright (c) 2014 WholeSlide. All rights reserved.
//

#import "wsCollectionObject.h"

@interface wsBiolucidaManagedCollection : wsCollectionObject

-(void) addChildAndSave:(wsServerObject *)theObject;

-(void) deleteChildAndSave:(wsServerObject*) theObject;



@end
