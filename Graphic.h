//
//  Graphic.h
//  DrPlot
//
//  Created by Peter Appel on 19/12/2007.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


extern NSString *GraphicDrawingBoundsKey;
extern NSString *GraphicDrawingContentsKey;

/*
 Graphic protocol to define methods all graphics objects must implement
 */

@protocol Graphic
+ (NSSet *)keysForValuesAffectingDrawingBounds;
+ (NSSet *)keysForValuesAffectingDrawingContents;
- (NSRect)drawingBounds;
-(void)drawInView:(NSView *)aView;
- (float)xLoc;
- (void)setXLoc:(float)aXLoc;
- (float)yLoc;
- (void)setYLoc:(float)aYLoc;




-(float)aValue;
-(void)setaValue:(float)aAValue;

-(float)bValue;
-(void)setbValue:(float)aBValue;

-(float)cValue;
-(void)setcValue:(float)aCValue;

- (BOOL)hitTest:(NSPoint)point isSelected:(BOOL)isSelected;

-(NSPoint)convertABC2XY:(float)a b:(float)b c:(float)c;

@end
