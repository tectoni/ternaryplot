//
//  PreferenceController.h
//  Trinity
//
//  Created by Peter Appel on 19.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern NSString *BNREmptyDocKey;


@interface PreferenceController : NSWindowController {

	int digits;
	IBOutlet NSTextField *digitTextField;
}

-(int) digits;
-(void) setDigits:(int)x;

@end
