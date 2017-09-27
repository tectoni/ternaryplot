//
//  Headers.m
//  Trinity
//
//  Created by Peter Appel on 20/01/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Headers.h"


@implementation Headers


-(id)init
{
if (self = [super init])
{
		[self setAHeader:@"links"];
		[self setBHeader:@"rechts"];
		[self setCHeader:@"op"];
}
return self;
}


-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:aHeader forKey:@"aHeader"];
	[coder encodeObject:bHeader forKey:@"bHeader"];
	[coder encodeObject:cHeader forKey:@"cHeader"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if (self = [super init]) {
		[self setCHeader:[coder decodeObjectForKey:@"aHeader"]];
		[self setBHeader:[coder decodeObjectForKey:@"bHeader"]];
		[self setCHeader:[coder decodeObjectForKey:@"cHeader"]];
	}
	return self;
}

- (void)setAHeader:(NSString *)x
{
	x = [x copy];
	[aHeader release];
	aHeader = x;
}

- (void)setBHeader:(NSString *)x
{
	x = [x copy];
	[bHeader release];
	bHeader = x;
}

- (void)setCHeader:(NSString *)x
{
	x = [x copy];
	[cHeader release];
	cHeader = x;
}

- (NSString *)aHeader
{
	return aHeader;
}

- (NSString *)bHeader
{
	return bHeader;
}

- (NSString *)cHeader
{
	return cHeader;
}


-(void)dealloc
{
[aHeader release];
[bHeader release];
[cHeader release];
[super dealloc];
}

@end
