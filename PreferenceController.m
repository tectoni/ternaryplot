//
//  PreferenceController.m
//  Trinity
//
//  Created by Peter Appel on 19.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferenceController.h"

NSString *BNREmptyDocKey = @"EmptyDocumentFlag";


@implementation PreferenceController

-(id)init
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

-(int)digits
{
	return digits;
}

-(void)setDigits:(int)x
{
	digits = x;
}

- (BOOL)emptyDoc
{
	NSUserDefaults *defaults;
	
	defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:BNREmptyDocKey];
}

- (void)windowDidLoad
{
}

@end
