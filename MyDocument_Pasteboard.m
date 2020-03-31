//
//  MyDocument_Pasteboard.m
//  TetLab
//
//  Created by Peter Appel on 12/06/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MyDocument_Pasteboard.h"
#import "GraphicsArrayController.h"

@implementation MyDocument(Pasteboard)


/* Methods for writing to the pasteboard */



- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard type:(NSString *)type 
{
	BOOL result = NO;
    NSArray *transactions = [graphicsController selectedObjects];
	NSMutableString *csvString = [NSMutableString string];
    NSEnumerator *pointEnum = [transactions objectEnumerator];
    id point;
    while ( point = [pointEnum nextObject] ) {
		NSString *string = [point valueForKey:@"identificator"];
        NSNumber *aV = [point valueForKey:@"aValue"];
        NSNumber *bV = [point valueForKey:@"bValue"];
		NSNumber *cV = [point valueForKey:@"cValue"];
        [csvString appendString:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\n", string, aV, bV, cV]]; // Tab delimited data
    }

// add the string representation
if ( [type isEqualToString:NSStringPboardType] ) 
	{
	result = [pboard setString:(NSString *)csvString forType:type];
	NSLog(@"pboard %@  %@", csvString, type);
	NSLog(@"pboard %@",[pboard stringForType:NSStringPboardType]);
	}
return result;
 
}


-(void)copy:(id)sender
{
NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
NSPasteboard *pb = [NSPasteboard generalPasteboard];
[pb declareTypes:types owner:self];
[self writeSelectionToPasteboard:pb type:NSStringPboardType];
}





/* Methods for reading from the pasteboard */


-(void)paste:(id)sender
{
NSPasteboard *pb = [NSPasteboard generalPasteboard];
if (![self canTakeValueFromPasteboard:pb])
	{ NSBeep();}
}



-(BOOL)canTakeValueFromPasteboard:(NSPasteboard *)pb
{
	NSString *value;
	NSString *type;
	type =[pb availableTypeFromArray:[NSArray arrayWithObject: NSStringPboardType]];
	if (type) {
		value = [pb stringForType:NSStringPboardType];
		NSLog(@"pasteboard %@", value);
		[graphicsController createRecordsFromPasteboard:value];
		return YES;
		}
return NO;
}


-(void)cut:(id)sender
{
}


@end
