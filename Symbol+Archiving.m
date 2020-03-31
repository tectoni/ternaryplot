//
//  Symbol+Archiving.m
//  Trinity
//
//  Created by Peter Appel on 05/01/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//


#import "Symbol.h"

@implementation Symbol (Archiving)


- (id)initWithCoder:(NSCoder *)coder
{
	if (![coder allowsKeyedCoding])
	{
		NSLog(@"Symbol only works with NSKeyedArchiver");
	}
	NSData *idData = [coder decodeObjectForKey:@"identificator"];
	NSString *newID = [NSKeyedUnarchiver unarchiveObjectWithData:idData];
	[self setIdentificator:newID];
	[self setXLoc:[coder decodeFloatForKey:@"xLoc"]];
	[self setYLoc:[coder decodeFloatForKey:@"yLoc"]];
	[self setaValue:[coder decodeFloatForKey:@"aValue"]];
	[self setbValue:[coder decodeFloatForKey:@"bValue"]];
	[self setcValue:[coder decodeFloatForKey:@"cValue"]];
	[self setRadius:[coder decodeFloatForKey:@"radius"]];
	[self setPathType:[coder decodeIntForKey:@"pathType"]];
	NSData *colorData = [coder decodeObjectForKey:@"color"];
	NSColor *newColor = [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
	[self setColor:newColor];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	if (![coder allowsKeyedCoding])
	{
		NSLog(@"Symbol only works with NSKeyedArchiver");
	}
	NSData *idData = [NSKeyedArchiver archivedDataWithRootObject:identificator];
	[coder encodeObject:idData forKey:@"identificator"];

	[coder encodeFloat:[self xLoc] forKey:@"xLoc"];
	[coder encodeFloat:[self yLoc] forKey:@"yLoc"];
	[coder encodeFloat:[self aValue] forKey:@"aValue"];
	[coder encodeFloat:[self bValue] forKey:@"bValue"];
	[coder encodeFloat:[self cValue] forKey:@"cValue"];
	[coder encodeInt:[self pathType] forKey:@"pathType"];
	[coder encodeFloat:[self radius] forKey:@"radius"];
	NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
	[coder encodeObject:colorData forKey:@"color"];
}

@end
