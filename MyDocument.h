//
//  MyDocument.h
//  TriPlot
//
//  Created by Peter Appel on 12/09/2007.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

/* MyDocument */

#import <Cocoa/Cocoa.h>
@class DiagramView;
@class Headers;
@class GraphicsArrayController;

@interface MyDocument : NSDocument
{
	NSMutableDictionary *dict;
	NSMutableArray *theLoadedSelArray;
	
	NSString *aLab;
	NSString *bLab;
	NSString *cLab;	
	
	IBOutlet NSButton *connectCheckbox;
	IBOutlet NSButton *showLabelsCheckbox;

	IBOutlet id mainWindow;
	IBOutlet id table;

	IBOutlet DiagramView *diagramView;
	IBOutlet GraphicsArrayController *graphicsController;
	IBOutlet NSButton *updateButton;

	IBOutlet NSTextField *textFieldA;
	IBOutlet NSTextField *textFieldB;
	IBOutlet NSTextField *textFieldC;

	NSMutableArray *graphics;
	IBOutlet NSPopUpButton *popup;
	Headers *loadedHeader;
	Headers *header;
    BOOL containsData;

}

-(void)updateUI;
- (void)handleNotify:(NSNotification *)n;

-(void)setGraphics:(NSMutableArray *)aGraphics;
-(NSMutableArray *)graphics;
- (unsigned int)countOfGraphics;
- (id)objectInGraphicsAtIndex:(unsigned int)index;
- (void)insertObject:(id)anObject inGraphicsAtIndex:(unsigned int)index;
- (void)removeObjectFromGraphicsAtIndex:(unsigned int)index;
- (void)replaceObjectInGraphicsAtIndex:(unsigned int)index withObject:(id)anObject;
- (void)setLoadedHeader:(Headers *)x;
- (void)setHeader:(Headers *)x;
-(IBAction)savePDF:(id)sender;
-(IBAction)importTextFile:(id)sender;
-(IBAction)exportTextFile:(id)sender;
-(IBAction)updateLabels:(id)sender;
-(IBAction)connectPoints:(id)sender;	
-(IBAction)showLabels:(id)sender;	

-(void)updateCellHeaders;
-(void)writeRecordsToTextFile:(NSString *)path;


@end
