//
//  SelData.m
//  DynamicSelections
//
//  Created by Peter Appel on 03/07/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SelData.h"


@implementation SelData


- (id)init
{
	
    if (self = [super init])
	{
		[self setNoOfPoints:0];
		[self setCountOfSel:0];
		[self setSel:[NSArray array]];
	}
	return self;
}


- (int)countOfSel
{
	return countOfSel;
}

- (void)setCountOfSel:(int)aCountOfSel
{
	countOfSel = aCountOfSel;
}

- (int)noOfPoints
{
	return noOfPoints;
}

- (void)setNoOfPoints:(int)aNoOfPoints
{
	noOfPoints = aNoOfPoints;
}


 - (NSArray *)sel {return sel;}

-(void)setSel:(NSArray *)aSel
{
	if (sel != aSel)
    {
        [sel autorelease];
		sel = [[NSArray alloc] initWithArray: aSel];
	}
}


/*
- (NSIndexSet *)sel {return sel;}


-(void)setSel:(NSIndexSet *)aSel
{
	if (sel != aSel)
    {
        [sel autorelease];
		sel = [[NSIndexSet alloc] initWithIndexSet: aSel];
	}
}
*/

- (void) dealloc
{
 //   [name release];
    
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)coder
{
	self=[super init];
//	NSData *idData = [coder decodeObjectForKey:@"sel"];
//	NSIndexSet *newSel = [NSUnarchiver unarchiveObjectWithData:idData];
//	[self setSel:newSel];
	[self setSel:[coder decodeObjectForKey:@"sel"]];
	[self setCountOfSel:[coder decodeIntForKey:@"countOfSel"]];
	[self setNoOfPoints:[coder decodeIntForKey:@"noOfPoints"]];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
//	NSData *idData = [NSArchiver archivedDataWithRootObject:sel];
//	[encoder encodeObject:idData forKey:@"sel"];
	[encoder encodeObject:[self sel] forKey:@"sel"];

	[encoder encodeInt:[self countOfSel] forKey:@"countOfSel"];
	[encoder encodeInt:[self noOfPoints] forKey:@"noOfPoints"];
}
	
@end
