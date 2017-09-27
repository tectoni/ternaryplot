/* DiagramView */

#import <Cocoa/Cocoa.h>
@class Symbol;
@class Headers;
@class SelData;

@interface DiagramView : NSView
{
	NSMutableArray *selArray;
	IBOutlet NSTableView *selTable;
	NSArray *oldGraphics;
	BOOL showTicks;
	IBOutlet NSArrayController *symbolController;
	IBOutlet NSWindow *window;
	IBOutlet NSMenu *zoomMenu;
	BOOL saveable;
	BOOL connectPointsYN;
	BOOL showLabelsYN;

	NSMutableDictionary *bindingInfo;
	
	//    NSString *string;
    NSMutableDictionary *attributes;
	NSString *aString;
	NSString *bString;
	NSString *cString;
//	Headers *header;
}

-(IBAction)createSel:(id)sender;
-(IBAction)deleteSelectedSel:(id)sender;
-(IBAction)zoomLevel:(id)sender;
- (void)broadcastSelAdd;
- (void)broadcastSelRemoved;



-(void)tableViewSelectionDidChange:(NSNotification *)aNotification;
-(void)updateSel;
-(void)prepareAttributes;

// Getter & Setter Methods
-(NSArray *)oldGraphics;
-(void)setOldGraphics:(NSArray *)anOldGraphics;
-(void)setShowLabelsYN:(BOOL)sender;
-(BOOL)showLabelsYN;
-(BOOL)connectPointsYN;
-(void)setConnectPointsYN:(BOOL)sender;
-(void)setSelArray:(NSMutableArray *)aSelArray;
-(NSMutableArray *)selArray;
-(void)setaString:(NSString *)x;
-(NSString *)aString;
-(void)setbString:(NSString *)x;
-(NSString *)bString;
-(void)setcString:(NSString *)x;
-(NSString *)cString;
-(void) setTicks:(id)sender;
-(BOOL)saveable;
-(void)setSaveable:(BOOL)yn;

// bindings-related -- infoForBinding and convenience methods
-(NSDictionary *)infoForBinding:(NSString *)bindingName;
-(id)graphicsContainer;
-(NSString *)graphicsKeyPath;
-(id)selectionIndexesContainer;
-(NSString *)selectionIndexesKeyPath;
-(NSArray *)graphics;
-(NSIndexSet *)selectionIndexes;
-(void)startObservingGraphics:(NSArray *)graphics;
-(void)stopObservingGraphics:(NSArray *)graphics;

@end
