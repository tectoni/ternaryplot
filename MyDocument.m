//
//  MyDocument.m
//  Trinity
//
//  Created by Peter Appel on 12/09/2007.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import "MyDocument.h"
#import "DiagramView.h"
#import "Headers.h"
#import "MyDocument_Pasteboard.h"
#import "GraphicsArrayController.h"
#import "PreferenceController.h"

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
		graphics =[[NSMutableArray alloc] init];
        containsData = NO;
}
    return self;
}

- (void)windowControllerWillLoadNib:(NSWindowController *)aController
{
	
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	[super windowControllerDidLoadNib:aController];
	// Add any code here that needs to be executed once the windowController has loaded the document's window.
	
	[diagramView bind: @"graphics" toObject: graphicsController
		  withKeyPath:@"arrangedObjects" options:nil];
	[diagramView bind: @"selectionIndexes" toObject: graphicsController
		  withKeyPath:@"selectionIndexes" options:nil];
	
	if (containsData)
	{
		[diagramView setSelArray:theLoadedSelArray];
		[header setAHeader:aLab];
		[header setBHeader:bLab];
		[header setCHeader:cLab];
		
		[textFieldA setStringValue:aLab];
		[textFieldB setStringValue:bLab];
		[textFieldC setStringValue:cLab];
		[self updateLabels:self];
		[self updateUI];
		
		
		/*	[self setHeader:loadedHeader];
		NSString *st = [NSString stringWithString:[header aHeader]];
		[textFieldA setStringValue:st];
		[textFieldB setStringValue:[NSString stringWithString:[header bHeader]]];
		[textFieldC setStringValue:[NSString stringWithString:[header cHeader]]];
		*/
	}
	
}

- (void)awakeFromNib
{
	int k, count;
    /**** Add the title of your new demo to the END of this array. ****/
    NSArray *titles = [NSArray arrayWithObjects:	NSLocalizedString(@"Circle", @"Circle"),
													NSLocalizedString(@"Dot", @"Dot"),
													NSLocalizedString(@"Square", @"Square"),
													NSLocalizedString(@"FilledSquare", @"Filled Square"),
													nil];
	
  		[diagramView setShowLabelsYN:[showLabelsCheckbox state]];
		[diagramView setConnectPointsYN:[connectCheckbox state]];
		[self updateLabels:self];

    NSNotificationCenter *notify;
    notify =[NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(handleNotify:) name:@"selectionAdded" object:nil];
	[notify addObserver:self selector:@selector(handleNotify:) name:@"selectionRemoved" object:nil];


  /* Zero out the menu. */
    [popup removeAllItems];
    
    count = [titles count];
	
    for (k = 0; k < count; k++)
        [popup addItemWithTitle:[titles objectAtIndex:k]];
		
}

- (void)handleNotify:(NSNotification *)n
{
	NSString *notificationName = [n name];
    SEL sel = @selector(aSelector);
	// Add the inverse of this operation to the undo stack
	if ([notificationName isEqualToString:@"selectionAdded"])
	{
		NSLog(@"selectionAdded ");
		[[self undoManager] registerUndoWithTarget:self selector:sel object:nil];

	}
	else if ([notificationName isEqualToString:@"selectionRemoved"])
	{
			NSLog(@"selectionRemoved");

		[[self undoManager] registerUndoWithTarget:self selector:sel object:nil];

	}
}


- (void)setLoadedHeader:(Headers *)x
{
    if (loadedHeader != x) {
		[loadedHeader release];
        loadedHeader = [x retain];
    }
}

- (void)setHeader:(Headers *)x
{
    if (header != x) {
		[header release];
        header = [x retain];
    }
}

- (void)setGraphics:(NSMutableArray *)aGraphics
{
    if (graphics != aGraphics) {
        [graphics release];
        graphics = [aGraphics mutableCopy];
    }
}

-(IBAction)connectPoints:(id)sender
{
	NSLog(@"connectPoints");
	[diagramView setConnectPointsYN:[connectCheckbox state]];
	[diagramView setNeedsDisplay:YES];
}

-(IBAction)showLabels:(id)sender
{
	NSLog(@"showLabels");
	[diagramView setShowLabelsYN:[showLabelsCheckbox state]];
	[diagramView setNeedsDisplay:YES];
}


- (unsigned int)countOfGraphics 
{
 return [graphics count];

}


- (id)objectInGraphicsAtIndex:(unsigned int)index 
{
    return [graphics objectAtIndex:index];
}

- (void)insertObject:(id)anObject inGraphicsAtIndex:(unsigned int)index 
{
    SEL sel = @selector(aSelector);

	[[self undoManager] registerUndoWithTarget:self selector:sel object:nil];
	// Add the inverse of this operation to the undo stack
//	NSUndoManager *undo = [self undoManager];
//	[[undo prepareWithInvocationTarget:self] removeObjectFromGraphicsAtIndex:index];
//	if (![undo isUndoing]) {
//		[undo setActionName:NSLocalizedString(@"InsertPoint",  @"Insert Point")];
//		NSLog(@"adding undo with");
//		}

    [graphics insertObject:anObject atIndex:index];
}

- (void)removeObjectFromGraphicsAtIndex:(unsigned int)index 
{
    SEL sel = @selector(aSelector);

	[[self undoManager] registerUndoWithTarget:self selector:sel object:nil];

	// Add the inverse of this operation to the undo stack
//	NSUndoManager *undo = [self undoManager];
//	[[undo prepareWithInvocationTarget:self] insertObject:[graphics objectAtIndex:index] inGraphicsAtIndex:index];
//	if (![undo isUndoing]) {
//		[[self undoManager] setActionName:@"Delete Point"];
//	}


    [graphics removeObjectAtIndex:index];
}



- (void)replaceObjectInGraphicsAtIndex:(unsigned int)index withObject:(id)anObject 
{
    [graphics replaceObjectAtIndex:index withObject:anObject];
}



- (void)dealloc
{
	[graphics release];
	//[self setGraphics:nil];
	[super dealloc];
}


- (NSMutableArray *)graphics
{
	return graphics;
}

- (void)updateUI
{
    [table reloadData];
	
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

// Methods for importing text file
- (IBAction)importTextFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setPrompt:@"Choose File"];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    
    NSLog(@"importTextFile");
    
    //  [panel setNameFieldStringValue:nil];
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result)
     {
         if (result == NSModalResponseOK)
         {
             NSArray* urls = [panel URLs];
             NSString*    textFilePath = [[urls objectAtIndex: 0 ] absoluteString];
                        [graphicsController createRecordsFromTextFile:textFilePath];
         }
     }];
    
}
/*
- (IBAction)importTextFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	NSLog(@"importTextFile");
    [panel beginSheetForDirectory:nil 
							 file:nil 
							types:nil 
				   modalForWindow:mainWindow
					modalDelegate:self 
				   didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) 
					  contextInfo:nil];
    [panel setCanChooseDirectories:NO];
    [panel setPrompt:@"Choose File"];
}


- (void)openPanelDidEnd:(NSOpenPanel *)openPanel returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    NSString *textFilePath;
	NSLog(@"openPanelDidEnd");
    if (returnCode == NSOKButton) {
        textFilePath = [openPanel filename];
        [graphicsController createRecordsFromTextFile:textFilePath];
    }
}

*/
//Methods for exporting data to text file

- (IBAction)exportTextFile:(id)sender
{
    NSArray* fileTypes = [NSArray arrayWithObjects:@"txt", nil];
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setPrompt:@"Save Text File"];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedFileTypes: fileTypes];
    NSLog(@"exportTextFile");
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result)
     {
         if (result == NSModalResponseOK)
         {
             [self writeRecordsToTextFile:[panel.URL path]];
         }
     }];
}



- (void)writeRecordsToTextFile:(NSString *)path
{
     NSError *error = nil;
    NSMutableString *csvString = [NSMutableString string];
    NSEnumerator *pointEnum = [graphics objectEnumerator];
    id point;
    while ( point = [pointEnum nextObject] ) {
		NSString *string = [point valueForKey:@"identificator"];
        NSNumber *aV = [point valueForKey:@"aValue"];
        NSNumber *bV = [point valueForKey:@"bValue"];
		NSNumber *cV = [point valueForKey:@"cValue"];
        [csvString appendString:[NSString stringWithFormat:@"%@\t%@\t%@\t%@\n", string, aV, bV, cV]]; // Tab delimited data
    }
    NSLog(@"writeRecordsToTextFile");

 BOOL ok =   [csvString writeToFile:path atomically:YES encoding: NSASCIIStringEncoding error:&error];
    if (error) {
        NSLog(@"Fail: %@", [error localizedDescription]);
    }
}

#pragma mark Saving as PDF

//
// The action for saving to PDF file. Just do a save panel and
// use -didEnd to handle results.
//



-(IBAction) savePDF:(id)sender
{
    NSArray* fileTypes = [NSArray arrayWithObjects:@"pdf", nil];
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setPrompt:@"Save PDF"];
    [panel setCanCreateDirectories:NO];
    [panel setAllowedFileTypes: fileTypes];
    NSLog(@"exportTextFile");
    [panel beginSheetModalForWindow:mainWindow completionHandler:^(NSInteger result)
     {
         if (result == NSModalResponseOK)
         {
                 NSLog(@"didEnd called for %@", self);
                 NSRect bounds = [diagramView bounds];
                 NSSize frameSize = [diagramView frame].size;
                 
                 /*        frameSize.width = bounds.size.width;
                  frameSize.height = bounds.size.height;
                  [self setFrameSize:frameSize];
                  [self setBounds:bounds];
                  */
                 NSRect r = NSMakeRect(bounds.origin.x, bounds.origin.y, frameSize.width, frameSize.height);
                //    NSRect r = [self bounds];
                 NSData *data = [diagramView dataWithPDFInsideRect:r];
                 [data writeToFile: [panel.URL path] atomically: YES];
        }
     }];
}



-(IBAction)updateLabels:(id)sender
{

//[myView setaString:string];			alternativ möglich
//[diagramView setaString:stringA];
[header setAHeader:[textFieldA stringValue]];
[header setBHeader:[textFieldB stringValue]];
[header setCHeader:[textFieldC stringValue]];
[diagramView setValue:[textFieldA stringValue] forKey:@"aString"];
[diagramView setValue:[textFieldB stringValue] forKey:@"bString"];
[diagramView setValue:[textFieldC stringValue] forKey:@"cString"];
[diagramView setNeedsDisplay:YES]; //wird benötigt mit setValue: forKey

[self updateCellHeaders];

}

-(void)updateCellHeaders
{
NSTableHeaderCell *headerACell = [[NSTableHeaderCell alloc] init];
[headerACell setStringValue:[textFieldA stringValue]];
    [headerACell setAlignment:NSTextAlignmentCenter];
[[table tableColumnWithIdentifier:@"aValue"] setHeaderCell:headerACell];
[headerACell release];

NSTableHeaderCell *headerBCell = [[NSTableHeaderCell alloc] init];
[headerBCell setStringValue:[textFieldB stringValue]];
    [headerBCell setAlignment:NSTextAlignmentCenter];
[[table tableColumnWithIdentifier:@"bValue"] setHeaderCell:headerBCell];
[headerBCell release];

NSTableHeaderCell *headerCCell = [[NSTableHeaderCell alloc] init];
[headerCCell setStringValue:[textFieldC stringValue]];
    [headerCCell setAlignment:NSTextAlignmentCenter];
[[table tableColumnWithIdentifier:@"cValue"] setHeaderCell:headerCCell];
[headerCCell release];

}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
	[graphicsController commitEditing];
	NSMutableData *data = [NSMutableData data];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
	dict = [NSMutableDictionary dictionaryWithObject:graphics forKey:@"graphics"];
//	[dict setObject:header forKey:@"label"];
	[archiver encodeObject:dict forKey:@"mainDict"];
	[archiver encodeObject:[diagramView selArray] forKey:@"auswahl"];
	//	[archiver encodeObject:header forKey:@"dieLabels"];
	
	[archiver encodeObject:[textFieldA stringValue] forKey:@"ersteLabel"];
	[archiver encodeObject:[textFieldB stringValue] forKey:@"zweiteLabel"];
	[archiver encodeObject:[textFieldC stringValue] forKey:@"dritteLabel"];
	
	[archiver finishEncoding];
	[archiver release];

	return data;
	
    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
	
}


-(void)terminate:(id)sender
{
    NSLog(@"terminate App");

}


/*
 
- (BOOL)windowShouldClose:(id)sender
{
	int res = NSRunAlertPanel(		NSLocalizedString(@"Attention", @"Attention"),
									NSLocalizedString(@"ReallyClose", @"Do you really want to close this window?"),
									NSLocalizedString(@"Yes", @"No"),
									NSLocalizedString(@"No", @"Yes"),
									nil);
	if (1 ==res) { return YES;}
	else
	{ return NO; }
}
*/	


- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    NSLog(@"About to read data of type %@", aType);
	NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [dict release];
    dict = [[unarchiver decodeObjectForKey:@"mainDict"] retain];
	theLoadedSelArray = [unarchiver decodeObjectForKey:@"auswahl"];
	
	aLab = [NSString stringWithString:[unarchiver decodeObjectForKey:@"ersteLabel"]];
	bLab = [NSString stringWithString:[unarchiver decodeObjectForKey:@"zweiteLabel"]];
	cLab = [NSString stringWithString:[unarchiver decodeObjectForKey:@"dritteLabel"]];
	
    [unarchiver finishDecoding];
    [unarchiver release];

	if (dict == nil) {
		return NO;
	} else {
    [self setGraphics:[dict objectForKey:@"graphics"]];
//    [self setLoadedHeader:[dict objectForKey:@"label"]];
		// For applications targeted for Tiger or later systems, you should use the new Tiger API readFromData:ofType:error:.  In this case you can also choose to override -readFromURL:ofType:error: or -readFromFileWrapper:ofType:error: instead.
	containsData=YES;
		return YES;
	}
}


- (void)printShowingPrintPanel:(BOOL)flag 
{ 
     NSPrintOperation *printOp; 
	[[self printInfo] setHorizontalPagination:NSFitPagination];
    [[self printInfo] setHorizontallyCentered:YES];
    [[self printInfo] setVerticallyCentered:YES];
    
     printOp=[NSPrintOperation printOperationWithView:diagramView 
                                            printInfo:[self printInfo]]; 
     [printOp setShowPanels:flag]; 
     [self runModalPrintOperation:printOp 
                         delegate:nil 
                   didRunSelector:NULL 
                      contextInfo:NULL]; 
} 


/***************************************************************************
TABLE METHODS
***************************************************************************/

// Delegate methods
- (int)numberOfRowsInTableView:(NSTableView *)table;
{
    return [graphics count];
}




@end
