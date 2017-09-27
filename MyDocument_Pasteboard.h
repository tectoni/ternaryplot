//
//  MyDocument_Pasteboard.h
//  TetLab
//
//  Created by Peter Appel on 12/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MyDocument.h"


@interface MyDocument(Pasteboard) 

/* Methods for writing to the pasteboard */

-(BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type;
-(void)copy:(id)sender;

-(void)cut:(id)sender;


/* Methods for writing from the pasteboard */
-(NSArray *)readablePasteboardTypes;
-(BOOL)canTakeValueFromPasteboard:(NSPasteboard *)pb;
-(void)paste:(id)sender;


@end
