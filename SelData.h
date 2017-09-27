//
//  SelData.h
//  DynamicSelections
//
//  Created by Peter Appel on 03/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SelData : NSObject <NSCoding>
{

 NSArray *sel;
//	NSIndexSet *sel;
	int countOfSel;
	int noOfPoints;
}

- (int)noOfPoints;
- (void)setNoOfPoints:(int)aNoOfPoints;

- (int)countOfSel;
- (void)setCountOfSel:(int)aCountOfSel;

 - (NSArray *)sel;
 -(void)setSel:(NSArray *)aSel;

//- (NSIndexSet *)sel;
//-(void)setSel:(NSIndexSet *)aSel;


@end
