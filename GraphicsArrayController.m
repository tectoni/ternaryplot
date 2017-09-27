#import "GraphicsArrayController.h"
#import "Symbol.h"

@implementation GraphicsArrayController


/*
 Allow filtering by color, just for the fun of it
 */
 

- (NSArray *)arrangeObjects:(NSArray *)objects
{
	if (!shouldFilter)
	{
		return [super arrangeObjects:objects];
	}
	
	float filterHue = [filterColor hueComponent];
	NSMutableArray *filteredObjects = [NSMutableArray arrayWithCapacity:[objects count]];
	
	NSEnumerator *oEnum = [objects objectEnumerator];
	id item;
	while (item = [oEnum nextObject])
	{
		float hue = [[item color] hueComponent];
		if ((fabs(hue - filterHue) < 0.05) ||
			(fabs(hue - filterHue) > 0.95) ||
			(item == newSymbol))
		{
			[filteredObjects addObject:item];
			newSymbol = nil;
		}
	}
	return [super arrangeObjects:filteredObjects];
}



- (NSColor *)filterColor { return filterColor; }

- (void)setFilterColor:(NSColor *)aFilterColor
{
    if (filterColor != aFilterColor)
	{
        [filterColor release];
        filterColor = [aFilterColor retain];
		[self rearrangeObjects];
    }
}

- (BOOL)shouldFilter { return shouldFilter; }

- (void)setShouldFilter:(BOOL)flag
{
    if (shouldFilter != flag)
	{
		shouldFilter = flag;
		[self rearrangeObjects];
    }
}

-(void)createRecordsFromPasteboard:(NSString *)pbstring
{
	NSString *aString;
	float aV, bV, cV;
    NSMutableArray *newGraphics = [NSMutableArray array];
 //   NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];			
    NSScanner *scanner = [NSScanner scannerWithString:pbstring];
	NSCharacterSet *skippedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\n\t\r, ()\""];
	[scanner setCharactersToBeSkipped:skippedCharacters];
	while ([scanner isAtEnd] == NO) {
[scanner scanUpToCharactersFromSet:skippedCharacters intoString:&aString];
		[scanner scanFloat:&aV];
		[scanner scanFloat:&bV]; 
		[scanner scanFloat:&cV];
		[newGraphics addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				aString, @"identificator",
                [NSNumber numberWithFloat:aV], @"aValue",
                [NSNumber numberWithFloat:bV], @"bValue",
				[NSNumber numberWithFloat:cV], @"cValue",
                nil]];
		Symbol *allocedSymbol = [[Symbol alloc]init];	
		[allocedSymbol setIdentificator:aString];
		[allocedSymbol setRadius:3.0];
		[allocedSymbol setaValue: aV];
		[allocedSymbol setbValue: bV];
		[allocedSymbol setcValue: cV];
		[self addObject:allocedSymbol];
		[allocedSymbol release];
	}		
}


-(void)createRecordsFromTextFile:(NSString *)path
{
	float aV, bV, cV;
	NSString *aString;
    NSMutableArray *newGraphics = [NSMutableArray array];
    NSString *fileString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];			
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
	NSCharacterSet *skippedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\n, ()\t\""];
	[scanner setCharactersToBeSkipped:skippedCharacters];
	while ([scanner isAtEnd] == NO) {
		[scanner scanUpToCharactersFromSet:skippedCharacters intoString:&aString];
		[scanner scanFloat:&aV];
		[scanner scanFloat:&bV]; 
		[scanner scanFloat:&cV];
		[newGraphics addObject:
			[NSMutableDictionary dictionaryWithObjectsAndKeys:
				aString, @"identificator",
                [NSNumber numberWithFloat:aV], @"aValue",
                [NSNumber numberWithFloat:bV], @"bValue",
				[NSNumber numberWithFloat:cV], @"cValue",
                nil]];
				
		Symbol *allocedSymbol = [[Symbol alloc]init];	
		[allocedSymbol setIdentificator:aString];
		[allocedSymbol setRadius:3.0];
		
		[allocedSymbol setaValue: aV];
		[allocedSymbol setbValue: bV];
		[allocedSymbol setcValue: cV];
		
		NSPoint point = [allocedSymbol convertABC2XY:[allocedSymbol aValue] b:[allocedSymbol bValue] c:[allocedSymbol cValue]];
		
		
		[allocedSymbol setXLoc:point.x];
		[allocedSymbol setYLoc:point.y];
		[self addObject:allocedSymbol];
		[allocedSymbol release];
	}		
	//    [self setGraphics:newGraphics];
	//	NSLog(@"points %@:", points);
	//		[insertObject: addObjectsFromArray:newGraphics];
//	[self updateUI];
	
}

- newObject
{	
	/*
	 Randomize attributes of new symbols so we get a pretty display
	 */
	newSymbol = (Symbol *)[super newObject];	
	
	NSLog(@"newObject");

	
	float radius = 3.0;
	[newSymbol setRadius:radius];

//	float height = [diagramView bounds].size.height;
//	float width = [diagramView bounds].size.width;
	// NSLog(@"h w %f %f", height, width);

	
//	float xOffset = 10.0 + (height - 20.0) * random() / LONG_MAX;
//	float yOffset = 10.0 + (width - 20.0) * random() / LONG_MAX;


	

	[newSymbol setaValue: 1.0];
	[newSymbol setbValue: 2.0];
	[newSymbol setcValue: 1.0];
	
	NSPoint point = [newSymbol convertABC2XY:[newSymbol aValue] b:[newSymbol bValue] c:[newSymbol cValue]];
	
	
	[newSymbol setXLoc:point.x];
	[newSymbol setYLoc:point.y];

/*
Removed for version 1.3 to receive uniform symbol attributes for new added data


	NSColor *color = [NSColor colorWithCalibratedHue:random() / (LONG_MAX-1.0)
										  saturation:(0.5 + (random() / (LONG_MAX-1.0)) / 2.0)
										  brightness:(0.333 + (random() / (LONG_MAX-1.0)) / 3.0)
											   alpha:1.0];
											   
	[newSymbol setColor:color];
										   
											   
*/



	[newSymbol setColor:[NSColor blueColor]];
	[newSymbol setPathType:0];
	[newSymbol setIdentificator:@"#"];

	return newSymbol;
}


+ (void)initialize
{
	srandom([[NSDate date] timeIntervalSince1970]);
}



- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
	 toPasteboard:(NSPasteboard *)pboard
{
		
    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
}



- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
    if (row < 0) {
		row = 0;
	}
    return NO;
}




@end
