//
//  Data.m
//  DrPlot
//
//  Created by Peter Appel on 12/09/2007.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import "Symbol.h"


@implementation Symbol

+ (void)initialize
{
    // This method gets invoked for every subclass of Symbol that's instantiated. That's a good thing, in this case. In most other cases it means you have to check self to protect against redundant invocations.
    
    // Set up use of the KVO dependency mechanism for the receiving class. The use of +keysForValuesAffectingDrawingBounds and +keysForValuesAffectingDrawingContents allows subclasses to easily customize this when they define entirely new properties that affect how they draw.
	
	NSArray *boundsChangingKeys = [[self keysForValuesAffectingDrawingBounds] allObjects];
	[self setKeys:boundsChangingKeys triggerChangeNotificationsForDependentKey:@"drawingBounds"];
	[self setKeys:[[self keysForValuesAffectingDrawingContents] allObjects] triggerChangeNotificationsForDependentKey:@"drawingContents"];
	
}

+ (NSSet *)keysForValuesAffectingDrawingBounds
{    
    // The  properties managed by Symbol that affect the drawing bounds.
	static NSSet *keysForValuesAffectingDrawingBounds = nil;
	if (!keysForValuesAffectingDrawingBounds)
	{
		keysForValuesAffectingDrawingBounds =
		[[NSSet alloc] initWithObjects:
			@"xLoc", @"yLoc", @"radius", nil];
	}
    return keysForValuesAffectingDrawingBounds;
}

+ (NSSet *)keysForValuesAffectingDrawingContents
{    
    // The  properties managed by symbol that affect the drawing contents.
	static NSSet *keysForValuesAffectingDrawingContents = nil;
	if (!keysForValuesAffectingDrawingContents)
	{
		keysForValuesAffectingDrawingContents =
		[[NSSet alloc] initWithObjects:
			@"xLoc", @"yLoc",  @"color", @"radius", @"pathType", nil];
	}
	return keysForValuesAffectingDrawingContents;
}






- (id)init
{
if (self = [super init])
	{
		[self setIdentificator:@"#"];
		[self setaValue:1.0];
		[self setbValue:1.0];
		[self setcValue:4.0];
		[self setRadius:2.0];
		[self setColor:[NSColor redColor]];
		[self setPathType:1];
		[self setXLoc:15.0];
		[self setYLoc:15.0];
	}
	return self;
}



-(void)drawInView:(NSView *)aView
{
 	NSPoint point = [self convertABC2XY:aValue b: bValue c:cValue];
	[self setXLoc:point.x];
	[self setYLoc:point.y];
	NSRect symbolBounds =  
				NSMakeRect(xLoc-radius, yLoc-radius, radius*2, radius*2);
	NSBezierPath *symbol = [NSBezierPath bezierPath];
		NSLog(@"symbol drawInView %@", self);

//	NSLog(@"symbol drawInView %f  %f", xLoc, yLoc);
	NSColor *myColor = [self color];
	if (myColor == nil) { myColor = [NSColor redColor]; }
	
		switch (pathType) {
			// Circle
			case 0: {
				symbol = [NSBezierPath bezierPathWithOvalInRect:symbolBounds];
				[myColor setStroke];
				[symbol stroke];
			}
				break;

			// Dot	
			case 1: {
				symbol = [NSBezierPath bezierPathWithOvalInRect:symbolBounds];
				[myColor set];
				[symbol fill];

			}
				break;
				
			// Square
			case 2: {
				symbol = [NSBezierPath bezierPathWithRect:symbolBounds];
				[myColor setStroke];
				[symbol stroke];
			}
				break;

			// Filled Square
			case 3: {
				symbol = [NSBezierPath bezierPathWithRect:symbolBounds];
				[myColor set];
				[symbol fill];
			}
				
				break;
			default:
				break;
		}		
	[symbol setLineWidth:0.5];
}


- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected
{
	// ignore isSelected here for simplicity...
	// don't count shadow for selection
	NSRect symbolBounds = 
	NSMakeRect(xLoc-radius, yLoc-radius, radius*2, radius*2);
	NSBezierPath *symbol;
	symbol = [NSBezierPath bezierPathWithOvalInRect:symbolBounds];
	return [symbol containsPoint:point];
}




-(NSPoint)convertABC2XY:(float)a b:(float)b c:(float)c
{
NSPoint point = NSMakePoint((b/(a + b + c) + c/(a + b + c) * 0.5) * 500.0, c/(a + b + c) * 0.8660254 * 500.0);
return point;
}



- (NSRect)drawingBounds
{
	
	NSRect symbolBounds = NSMakeRect(xLoc-radius, yLoc-radius,
									 radius*2, radius*2);
		
	return (symbolBounds);
}

- (float)radius 
{ 
	return radius; 
}

- (void)setRadius:(float)aRadius
{
	radius = aRadius;
}

- (float)aValue
{
	return aValue;
}


- (float)bValue
{
	return bValue;
}

- (float)cValue
{
	return cValue;
}


- (void)setaValue:(float)x
{
	aValue = x;
}

- (void)setbValue:(float)x
{
	bValue = x;
}

- (void)setcValue:(float)x
{
	cValue = x;
}







-(void)dealloc
{
	[super dealloc];
}

- (void)setIdentificator:(NSString *)anIdentificator
{
	anIdentificator = [anIdentificator copy];
	[identificator release];
	identificator = anIdentificator;
}

- (NSString *)identificator
{
	return identificator;
}


- (float)xLoc 
{ 
return xLoc;
}

- (void)setXLoc:(float)aXLoc
{
	xLoc = aXLoc;
}

- (float)yLoc 
{ 
return yLoc; 
}

- (void)setYLoc:(float)aYLoc
{
	yLoc = aYLoc;
}

- (NSColor *)color { return color; }

- (void)setColor:(NSColor *)aColor
{
    if (color != aColor) {
        [color release];
        color = [aColor retain];
    }
}

-(int)pathType { return pathType; }

- (void)setPathType:(int)aPathType 
{
        pathType = aPathType;
}

@end
