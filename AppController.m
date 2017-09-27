//
//  AppController.m
//  Trinity
//
//  Created by Peter Appel on 19.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

#import "PreferenceController.h"

@implementation AppController

+ (void)initialize {
	
	// Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	// Put defaults in the dictionary
	[defaultValues setObject:[NSNumber numberWithBool:YES]
					  forKey:BNREmptyDocKey];
	
		// Register the dictionary of defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
	NSLog(@"registered defaults: %@", defaultValues);
}

- (IBAction)showPreferencePanel:(id)sender
{
	// Is preferenceController nil?
	if (!preferenceController) {
		preferenceController = [[PreferenceController alloc] init];
	}
	[preferenceController showWindow:self];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	NSLog(@"applicationShouldOpenUntitledFile:");
	return [[NSUserDefaults standardUserDefaults] boolForKey:BNREmptyDocKey];
}

- (void)dealloc
{
	[preferenceController release];
	[super dealloc];
}

@end
