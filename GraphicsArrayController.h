/* GraphicsArrayController */

#import <Cocoa/Cocoa.h>

@interface GraphicsArrayController : NSArrayController

{

IBOutlet NSView *diagramView;
	NSColor *filterColor;
	BOOL shouldFilter;
	id newSymbol;


}
-(void)createRecordsFromTextFile:(NSString *)path;

// table view drag and drop support

- (BOOL)tableView:(NSTableView *)aTableView
writeRowsWithIndexes:(NSIndexSet *)rowIndexes
	 toPasteboard:(NSPasteboard *)pboard;

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op;
    
- (BOOL)tableView:(NSTableView*)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op;

-(void)createRecordsFromPasteboard:(NSString *)pbstring;


@end
