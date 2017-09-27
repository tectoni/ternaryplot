#import "DiagramView.h"

#import"Graphic.h"
#import "Headers.h"
#import"SelData.h"

static void *PropertyObservationContext = (void *)1091;
static void *GraphicsObservationContext = (void *)1092;
static void *SelectionIndexesObservationContext = (void *)1093;

NSString *GRAPHICS_BINDING_NAME = @"graphics";
NSString *SELECTIONINDEXES_BINDING_NAME = @"selectionIndexes";


@implementation DiagramView



+ (void)initialize
{
	[self exposeBinding:GRAPHICS_BINDING_NAME];
	[self exposeBinding:SELECTIONINDEXES_BINDING_NAME];
}


- (NSArray *)exposedBindings
{
	return [NSArray arrayWithObjects:GRAPHICS_BINDING_NAME, @"selectedObjects", nil];
}

- (id)initWithFrame:(NSRect)frameRect
{
//	float axisLength;
//	axisLength = 400.0;
if ((self = [super initWithFrame:frameRect]) != nil) {
		// Add initialization code here
			[self setBoundsOrigin:NSMakePoint(-300.0,-480.0)];
			selArray = [[NSMutableArray alloc] init];

			NSLog(@"DiagramView initWithFrame %@", self);
			[NSApp setDelegate: self];
			[self setSaveable: YES];
			[self setNeedsDisplay: YES];
			bindingInfo = [[NSMutableDictionary alloc] init];
			[self prepareAttributes];
	//		header = [[Headers alloc]init];
			
			
	}
	return self;
}


- (void)unbind:(NSString *)bindingName
{
	
    if ([bindingName isEqualToString:GRAPHICS_BINDING_NAME])
	{
		id graphicsContainer = [self graphicsContainer];
		NSString *graphicsKeyPath = [self graphicsKeyPath];
		
		[graphicsContainer removeObserver:self forKeyPath:graphicsKeyPath];
		[bindingInfo removeObjectForKey:GRAPHICS_BINDING_NAME];
 		[self setOldGraphics:nil];
   }
	else
		if ([bindingName isEqualToString:SELECTIONINDEXES_BINDING_NAME])
		{
			id selectionIndexesContainer = [self selectionIndexesContainer];
			NSString *selectionIndexesKeyPath = [self selectionIndexesKeyPath];
			
			[selectionIndexesContainer removeObserver:self forKeyPath:selectionIndexesKeyPath];
			[bindingInfo removeObjectForKey:SELECTIONINDEXES_BINDING_NAME];
		}
	else
	{
		[super unbind:bindingName];
	}
    [self setNeedsDisplay:YES];
}

-(void)dealloc
{
	[bindingInfo release];
	[oldGraphics release];
	[super dealloc];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
    ofObject:(id)object
    change:(NSDictionary *)change
    context:(void *)context
{
	
    if (context == GraphicsObservationContext)
	{
		/*
		 Should be able to use
		 NSArray *oldGraphics = [change objectForKey:NSKeyValueChangeOldKey];
		 etc. but the dictionary doesn't contain old and new arrays.
		 */
		NSArray *newGraphics = [object valueForKeyPath:[self graphicsKeyPath]];
		
		NSMutableArray *onlyNew = [newGraphics mutableCopy];
		[onlyNew removeObjectsInArray:oldGraphics];
		[self startObservingGraphics:onlyNew];
		[onlyNew release];
		
		NSMutableArray *removed = [oldGraphics mutableCopy];
		[removed removeObjectsInArray:newGraphics];
		[self stopObservingGraphics:removed];
		[removed release];
		
		[self setOldGraphics:newGraphics];
		
		// could check drawingBounds of old and new, but...
		[self setNeedsDisplay:YES];
		return;
    }
	
	if (context == PropertyObservationContext)
	{
		NSRect updateRect;
		
		if ([keyPath isEqualToString:@"drawingBounds"])
		{
			NSRect newBounds = [[change objectForKey:NSKeyValueChangeNewKey] rectValue];
			NSRect oldBounds = [[change objectForKey:NSKeyValueChangeOldKey] rectValue];
			updateRect = NSUnionRect(newBounds,oldBounds);
		}
		else
		{
			updateRect = [(NSObject <Graphic> *)object drawingBounds];
		}
		updateRect = NSMakeRect(updateRect.origin.x-1.0,
								updateRect.origin.y-1.0,
								updateRect.size.width+2.0,
								updateRect.size.height+2.0);
		[self setNeedsDisplayInRect:updateRect];
		return;
	}
	
	if (context == SelectionIndexesObservationContext)
	{
		[self setNeedsDisplay:YES];
		return;
	}
}

- (void)startObservingGraphics:(NSArray *)graphics
{
	if ([graphics isEqual:[NSNull null]])
	{
		return;
	}
	
	/*
	 Register to observe each of the new graphics, and each of their observable properties -- we need old and new values for drawingBounds to figure out what our dirty rect
	 */
	NSEnumerator *graphicsEnumerator = [graphics objectEnumerator];
	
	/*
	 Declare newGraphic as NSObject * to get key value observing methods
	 Add Graphic protocol for drawing
	 */
    NSObject <Graphic> *newGraphic;
	/*
	 Register as observer for all the drawing-related properties
	 */
    while (newGraphic = [graphicsEnumerator nextObject])
	{
		[newGraphic addObserver:self
					 forKeyPath:GraphicDrawingBoundsKey
						options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
						context:PropertyObservationContext];
		
		[newGraphic addObserver:self
					 forKeyPath:GraphicDrawingContentsKey
						options:0
						context:PropertyObservationContext];
	}
}


- (void)stopObservingGraphics:(NSArray *)graphics
{
	if ([graphics isEqual:[NSNull null]])
	{
		return;
	}
	
	NSEnumerator *graphicsEnumerator = [graphics objectEnumerator];
	
    id oldGraphic;
    while (oldGraphic = [graphicsEnumerator nextObject])
	{
		[oldGraphic removeObserver:self forKeyPath:GraphicDrawingBoundsKey];
		[oldGraphic removeObserver:self forKeyPath:GraphicDrawingContentsKey];
	}
}


- (void)bind:(NSString *)bindingName
	   toObject:(id)observableObject
	withKeyPath:(NSString *)observableKeyPath
		   options:(NSDictionary *)options
{
	
    if ([bindingName isEqualToString:GRAPHICS_BINDING_NAME])
	{
		if ([bindingInfo objectForKey:GRAPHICS_BINDING_NAME] != nil)
		{
			[self unbind:GRAPHICS_BINDING_NAME];	
		}
		/*
		 observe the controller for changes -- note, pass binding identifier as the context, so we get that back in observeValueForKeyPath:... -- that way we can determine what needs to be updated
		 */
		
		NSDictionary *bindingsData = [NSDictionary dictionaryWithObjectsAndKeys:
									  observableObject, NSObservedObjectKey,
									  [[observableKeyPath copy] autorelease], NSObservedKeyPathKey,
									  [[options copy] autorelease], NSOptionsKey, nil];
		[bindingInfo setObject:bindingsData forKey:GRAPHICS_BINDING_NAME];
		
		[observableObject addObserver:self
						   forKeyPath:observableKeyPath
							  options:(NSKeyValueObservingOptionNew |
									   NSKeyValueObservingOptionOld)
							  context:GraphicsObservationContext];
		[self startObservingGraphics:[observableObject valueForKeyPath:observableKeyPath]];
		
    }
	else
		if ([bindingName isEqualToString:SELECTIONINDEXES_BINDING_NAME])
		{
			if ([bindingInfo objectForKey:SELECTIONINDEXES_BINDING_NAME] != nil)
			{
				[self unbind:SELECTIONINDEXES_BINDING_NAME];	
			}
			/*
			 observe the controller for changes -- note, pass binding identifier as the context, so we get that back in observeValueForKeyPath:... -- that way we can determine what needs to be updated
			 */
			
			NSDictionary *bindingsData = [NSDictionary dictionaryWithObjectsAndKeys:
										  observableObject, NSObservedObjectKey,
										  [[observableKeyPath copy] autorelease], NSObservedKeyPathKey,
										  [[options copy] autorelease], NSOptionsKey, nil];
			[bindingInfo setObject:bindingsData forKey:SELECTIONINDEXES_BINDING_NAME];
			
			
			[observableObject addObserver:self
							   forKeyPath:observableKeyPath
								  options:0
								  context:SelectionIndexesObservationContext];
		}
	else
	{
		/*
		 For every binding except "graphics" and "selectionIndexes" just use NSObject's default implementation. It will start observing the bound-to property. When a KVO notification is sent for the bound-to property, this object will be sent a [self setValue:theNewValue forKey:theBindingName] message, so this class just has to be KVC-compliant for a key that is the same as the binding name.  Also, NSView supports a few simple bindings of its own, and there's no reason to get in the way of those.
		 */
		[super bind:bindingName toObject:observableObject withKeyPath:observableKeyPath options:options];
	}
    [self setNeedsDisplay:YES];
}


-(void)drawRect:(NSRect)rect
{
	int i;
	NSPoint a, b, c, aPoint, bPoint, cPoint;
	NSRect bounds = [self bounds];
//	bounds.origin = NSMakePoint(150.0, 150.0);

	//
	// These are for converting raw data coordinates into
	// display coordinates.
	//
	float tickLength;	
	float axisLength;
	tickLength = 3;
	axisLength = 500.0;		
	[[NSColor whiteColor] set];
	[NSBezierPath fillRect:bounds];
	[[NSColor blackColor] set];
	NSBezierPath *tickPath; 
	NSEraseRect(rect);
	NSBezierPath *path;
//	NSLog(@"frame %f  %f  %f  %f",  bounds.size.width, bounds.size.height,  bounds.origin.x, bounds.origin.y);
//	NSLog(@"boundsRect = %@", NSStringFromRect(bounds));
//	NSLog(@"frameRect = %@", NSStringFromRect([self frame]));

// Draw Ternary
	path = [[NSBezierPath alloc] init];
			[path setLineWidth: 1.0];
			a.x = 0;
			a.y = 0;
			b.x = a.x + axisLength;
			b.y = a.y;
			c.x = b.x / 2;
			c.y = axisLength * 0.8660254;
			[path moveToPoint: a];
			[path lineToPoint: b];
			[path lineToPoint: c];
			[path closePath];
	[path stroke];

// Draw Ticks

if (showTicks) {
	tickPath = [[NSBezierPath alloc] init];
	for (i=0; i < 9; i++) {
		
		[tickPath moveToPoint: NSMakePoint( (i+1) * 10 / 2 * axisLength / 100, (i+1) * 10 * 0.8660254 * axisLength / 100)];
		[tickPath lineToPoint: NSMakePoint( (tickLength + (i+1) * 10 / 2) * axisLength / 100, (i+1) * 10 * 0.8660254 * axisLength / 100)];
		
		[tickPath moveToPoint: NSMakePoint( (i+1) * 10 / 2 * axisLength / 100, (i+1) * 10 * 0.8660254 * axisLength / 100)];
		[tickPath lineToPoint: NSMakePoint( (tickLength + ((i+1) * 10 - tickLength) / 2) * axisLength / 100, ((i+1) * 10 - tickLength) * 0.8660254 * axisLength / 100)];

		[tickPath moveToPoint: NSMakePoint( (i+1) * 10  * axisLength / 100, 0)];
		[tickPath lineToPoint: NSMakePoint( ((i+1) * 10 + tickLength/2) * axisLength / 100, tickLength * 0.8660254 * axisLength / 100)];

		[tickPath moveToPoint: NSMakePoint( (i+1) * 10  * axisLength / 100, 0)];
		[tickPath lineToPoint: NSMakePoint( ((i+1) * 10 - tickLength + tickLength/2) * axisLength / 100, tickLength * 0.8660254 * axisLength / 100)];
		
		[tickPath moveToPoint: NSMakePoint( (100 - (i+1) * 10 + (i+1) * 10 / 2)  * axisLength / 100, (i+1) * 10 * 0.8660254 * axisLength / 100)];
		[tickPath lineToPoint: NSMakePoint( (100 - (i+1) * 10 + ((i+1) * 10 - tickLength) / 2)  * axisLength / 100, ((i+1) * 10  - tickLength) * 0.8660254 * axisLength / 100)];

		[tickPath moveToPoint: NSMakePoint( (100 - (i+1) * 10 + (i+1) * 10 / 2)  * axisLength / 100, (i+1) * 10 * 0.8660254 * axisLength / 100)];
		[tickPath lineToPoint: NSMakePoint( (100 - (i+1) * 10 - tickLength + (i+1) * 10 / 2)  * axisLength / 100, (i+1) * 10 * 0.8660254 * axisLength / 100)];
		}
		[tickPath stroke];
	}


	/*
	 Draw graphics
	 */
	NSArray *graphicsArray = [self graphics];
	NSEnumerator *graphicsEnumerator = [graphicsArray objectEnumerator];
	NSObject <Graphic> *graphic;
    while (graphic = [graphicsEnumerator nextObject])
	{
		//NSLog(@"DiagramView drawRect %@", self);
	//	NSLog(@"DiagramView xxxxxxxxx %@", self);

     //   NSRect graphicDrawingBounds = [graphic drawingBounds];
     //   if (NSIntersectsRect(rect, graphicDrawingBounds))
		//{
			[graphic drawInView:self];
       // }
    }

	NSIndexSet *currentSelectionIndexes = [self selectionIndexes];
	if (currentSelectionIndexes != nil)
	{
		NSBezierPath *path = [NSBezierPath bezierPath];
		unsigned int index = [currentSelectionIndexes firstIndex];
		while (index != NSNotFound)
		{
			graphic = [graphicsArray objectAtIndex:index];
				//				NSLog(@"reingegangen");

			NSRect graphicDrawingBounds = [graphic drawingBounds];
			if (NSIntersectsRect(rect, graphicDrawingBounds))
			{
				[path appendBezierPathWithRect:graphicDrawingBounds];
//	NSLog(@"DiagramView 2 graphicDrawingBounds r%@ db %@", NSStringFromRect(rect), NSStringFromRect(graphicDrawingBounds));

			}
			index = [currentSelectionIndexes indexGreaterThanIndex:index];
		}
		[[NSColor redColor] set];
		[path setLineWidth:1.0];
		[path stroke];
	}
	
	
	if (connectPointsYN) {
			for (i = 0; i < [selArray count]; i++) {
		//	NSIndexSet *selection = [[selArray objectAtIndex:i] sel];
					NSLog(@"sel no %u", i);	

			SelData *aSel = [selArray objectAtIndex:i];
			NSArray *points2Connect = [aSel sel];
		if ( [points2Connect count] > 1) {
					unsigned int index = 0;
					NSLog(@"first index %u", index);	
					if ([graphicsArray containsObject:[points2Connect objectAtIndex:index]])
					graphic = [points2Connect objectAtIndex:index];
//					index = [selection indexGreaterThanIndex:index];
					NSBezierPath *tieline = [NSBezierPath bezierPath];		
					[[NSColor blueColor] set];
					[tieline setLineWidth:0.5];
					[tieline moveToPoint: NSMakePoint([graphic xLoc], [graphic yLoc])];
					
					index++;
										NSLog(@"first index %u", index);	

					while (index < [points2Connect count])
					{
					NSLog(@"loop index %u", index);	

					graphic = [points2Connect objectAtIndex:index];
					NSPoint a = NSMakePoint([graphic xLoc], [graphic yLoc]);
					[tieline lineToPoint: a];
					index++;
					NSLog(@"looped to %u", index);	

					}
					NSLog(@"broken with %u", index);	

					[tieline closePath];
					
					if ([points2Connect count] > 3) {
						NSLog(@"inside routine at index %u", index);	

							graphic = [points2Connect objectAtIndex:0];
							a =  NSMakePoint([graphic xLoc], [graphic yLoc]);
							[tieline moveToPoint: a];
														
							graphic = [points2Connect objectAtIndex:2];
							a =  NSMakePoint([graphic xLoc], [graphic yLoc]);
							[tieline lineToPoint: a];
							
							// This procedure should be optimised soon!!!! very quick & dirty
							
							graphic = [points2Connect objectAtIndex:3];
							a =  NSMakePoint([graphic xLoc], [graphic yLoc]);
							[tieline moveToPoint: a];
						
							graphic = [points2Connect objectAtIndex:1];
							a =  NSMakePoint([graphic xLoc], [graphic yLoc]);
							[tieline lineToPoint: a];
						}
												NSLog(@"outsinde routine at index %u", index);	

				[tieline stroke];
				}
			}	// for - Loop

}	// if (connectPointsYN)



	
if (showLabelsYN) {	
	aPoint.x = -10.0;
	aPoint.y = -25.0,
		[aString drawAtPoint:aPoint withAttributes:attributes]; 	
	bPoint.x = axisLength + 10.0 - [bString sizeWithAttributes:attributes].width;
	bPoint.y = -25.0,
		[bString drawAtPoint:bPoint withAttributes:attributes]; 	
	cPoint.x = axisLength/2 - ([cString sizeWithAttributes:attributes].width/2);
	cPoint.y = axisLength * 0.8660254;
	[cString drawAtPoint:cPoint withAttributes:attributes]; 	
}

NSLog(@"drawRect %@", self);
[self retain];
}




- (void)prepareAttributes
{
    attributes = [[NSMutableDictionary alloc] init];
    
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:16]
                   forKey:NSFontAttributeName];
    
    [attributes setObject:[NSColor blackColor]
                   forKey:NSForegroundColorAttributeName];
}



- (void)setSaveable:(BOOL)yn
{
	saveable = yn;
}


- (BOOL)saveable
{
	return saveable;
}





- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSString *selectorString;
	selectorString = NSStringFromSelector([menuItem action]);
	NSLog(@"validateCalled for %@", selectorString);
	
	// By using the action instead of the title, we do not
	// have to worry about whether the menu item is localized
	if ([menuItem action] == @selector(savePDF:)) {
		return saveable;
	} else {
		return YES;
	}
}



- (void) setTicks:(id)sender 
{ 
	showTicks = [sender state];
	[self setNeedsDisplay:YES];
	NSLog(@"DiagramView setTicks %@", self);
}


- (void)mouseDown:(NSEvent *)event
{
	/*
	 Fairly simple just to illustrate the point
	 */
	// find out if we hit anything
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	NSEnumerator *gEnum = [[self graphics] reverseObjectEnumerator];
	id aGraphic;
	while (aGraphic = [gEnum nextObject])
    {
		if ([aGraphic hitTest:p isSelected:NO])
		{
			break;
		}
	}
	
	/*
	 if no graphic hit, then if extending selection do nothing else set selection to nil
	 */
	if (aGraphic == nil)
	{
		if (!([event modifierFlags] & NSShiftKeyMask))
		{
			[[self selectionIndexesContainer] setValue:nil forKeyPath:[self selectionIndexesKeyPath]];
		}
		return;
	}
	
	/*
	 graphic hit
	 if not extending selection (Shift key down) then set selection to this graphic
	 if extending selection, then:
	 - if graphic in selection remove it
	 - if not in selection add it
	 */
	NSIndexSet *selection = nil;
	unsigned int graphicIndex = [[self graphics] indexOfObject:aGraphic];
	
	if (!([event modifierFlags] & NSShiftKeyMask))
	{
		selection = [NSIndexSet indexSetWithIndex:graphicIndex];
	}
	else
	{
		if ([[self selectionIndexes] containsIndex:graphicIndex])
		{
			selection = [[[self selectionIndexes] mutableCopy] autorelease];
			[(NSMutableIndexSet *)selection removeIndex:graphicIndex];
		}
		else
		{
			selection = [[[self selectionIndexes] mutableCopy] autorelease];
			[(NSMutableIndexSet *)selection addIndex:graphicIndex];
		}
	}
	[[self selectionIndexesContainer] setValue:selection forKeyPath:[self selectionIndexesKeyPath]];
}



- (NSArray *)oldGraphics
{
	return oldGraphics;
}

- (void)setOldGraphics:(NSArray *)anOldGraphics
{
    if (oldGraphics != anOldGraphics) {
        [oldGraphics release];
        oldGraphics = [anOldGraphics mutableCopy];
    }
}


// bindings-related -- infoForBinding and convenience methods

- (NSDictionary *)infoForBinding:(NSString *)bindingName
{
	NSDictionary *info = [bindingInfo objectForKey:bindingName];
	if (info == nil) {
		info = [super infoForBinding:bindingName];
	}
	return info;
}

- (id)graphicsContainer
{
	return [[self infoForBinding:GRAPHICS_BINDING_NAME] objectForKey:NSObservedObjectKey];
}

- (NSString *)graphicsKeyPath {
	return [[self infoForBinding:GRAPHICS_BINDING_NAME] objectForKey:NSObservedKeyPathKey];
}

- (id)selectionIndexesContainer
{
	return [[self infoForBinding:SELECTIONINDEXES_BINDING_NAME] objectForKey:NSObservedObjectKey];
}

- (NSString *)selectionIndexesKeyPath {
	return [[self infoForBinding:SELECTIONINDEXES_BINDING_NAME] objectForKey:NSObservedKeyPathKey];
}

- (NSArray *)graphics
{	
    return [[self graphicsContainer] valueForKeyPath:[self graphicsKeyPath]];	
}




- (void) setShowLabelsYN:(BOOL)yn
{ 
	showLabelsYN = yn;
	//	[self setNeedsDisplay:YES];
	//	NSLog(@"DiagramView setTicks %@", self);
}

-(BOOL)showLabelsYN {return showLabelsYN;}




-(void)setConnectPointsYN:(BOOL)yn
{
	connectPointsYN = yn;
}

-(BOOL)connectPointsYN { return connectPointsYN; }


- (NSMutableArray *)selArray {return selArray;}


- (void)setSelArray:(NSMutableArray *)aSelArray
{
    if (selArray != aSelArray) {
        [selArray release];
        selArray = [aSelArray mutableCopy];
[selTable reloadData];
    }
}



- (NSIndexSet *)selectionIndexes
{
	return [[self selectionIndexesContainer] valueForKeyPath:[self selectionIndexesKeyPath]];
}



- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
	[super viewWillMoveToSuperview:newSuperview];
	if (newSuperview == nil)
	{
		[self stopObservingGraphics:[self graphics]];
		[self unbind:GRAPHICS_BINDING_NAME];
		[self unbind:SELECTIONINDEXES_BINDING_NAME];
	}
}


- (void)setaString:(NSString *)x
{
	x = [x copy];
	[aString release];
	aString = x;
	[self setNeedsDisplay:YES];
}
- (void)setbString:(NSString *)x
{
	x = [x copy];
	[bString release];
	bString = x;
	[self setNeedsDisplay:YES];
}

- (void)setcString:(NSString *)x
{
	x = [x copy];
	[cString release];
	cString = x;
	[self setNeedsDisplay:YES];
}



- (NSString *)aString
{
	return aString;
}

- (NSString *)bString
{
	return bString;
}

- (NSString *)cString
{
	return cString;
}


// Delegate methods
- (int)numberOfRowsInTableView:(NSTableView *)aTable
{
	 return [selArray count];
}




- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSString *columnKey = [aTableColumn identifier];
	SelData *aSel = [selArray objectAtIndex:rowIndex];
	return 	[aSel valueForKey:columnKey];
}


- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	NSString *columnKey = [aTableColumn identifier];
	SelData *aSel = [selArray objectAtIndex:rowIndex];
	[aSel setValue:anObject forKey:columnKey];
}

- (void)broadcastSelAdd
{
    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify postNotificationName:@"selectionAdded" object:nil];
}

- (void)broadcastSelRemoved
{
    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify postNotificationName:@"selectionRemoved" object:nil];
}



-(IBAction)createSel:(id)sender
{

	[self broadcastSelAdd];
	SelData *newSel = [[SelData alloc] init]; 
	[newSel setCountOfSel:[selArray count]+1];
	[newSel setNoOfPoints:[[symbolController selectionIndexes] count]];
	[newSel setSel:[symbolController selectedObjects]];
	NSLog(@"name %i",  [newSel countOfSel] );

	[selArray addObject:newSel];
	[newSel release];
	[self setNeedsDisplay:YES];
	[selTable reloadData];
}

-(IBAction)deleteSelectedSel:(id)sender
{
	[self broadcastSelRemoved];
	NSIndexSet *rows = [selTable selectedRowIndexes];
	
	if ([rows count] > 0) {
		unsigned int row = [rows lastIndex];
		
		while (row != NSNotFound) {
			[selArray removeObjectAtIndex:row];
			row = [rows indexLessThanIndex:row];
		}
		[self setNeedsDisplay:YES];
		[selTable reloadData];
	} else {
		NSBeep();
	}
}



- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
{
//	NSLog(@"tableViewSelectionDidChange");
 if ([aNotification object] == selTable) {
//	NSLog(@"true");
	[self updateSel];
	}
	else {
//	NSLog(@"else");
	[selTable deselectAll:nil];
	}
}

-(void)updateSel
{
	unsigned selectedRow = [selTable selectedRow];
	NSLog(@"vgfr %i",  selectedRow );

	if (selectedRow == -1)
		{
		// fill code to handle null selection
					[selTable deselectAll:nil];

		}
	else		
	{
		[symbolController setSelectedObjects:[[selArray objectAtIndex:selectedRow] sel] ];
		[selTable selectRow:selectedRow byExtendingSelection:NO];
		NSLog(@"selextion %i,  %i", [[[selArray objectAtIndex:selectedRow] sel] count], selectedRow );

	}
}	




@end
