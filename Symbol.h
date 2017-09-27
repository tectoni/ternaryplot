//
//  Graphic.h
//  Trinity
//
//  Created by Peter Appel on 12/09/2007.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Graphic.h"

@interface Symbol : NSObject <Graphic> {
	NSString *identificator;
	float aValue;
	float bValue;
	float cValue;
	float radius;
	float xLoc;
	float yLoc;
	
	NSColor *color;
	int pathType;
}

-(NSString *)identificator;
-(void)setIdentificator:(NSString *)anIdentificator;

- (float)radius;
- (void)setRadius:(float)aRadius;

- (NSColor *)color;
- (void)setColor:(NSColor *)aColor;
-(int)pathType;
- (void)setPathType:(int)aPathType;
    
@end
