//
//  WindowController.h
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface WindowController : NSWindowController

@property (assign) IBOutlet NSSegmentedControl *sourceTypeSegment;
@property (assign) IBOutlet NSTextField *url;
@property (assign) IBOutlet NSTextField *userName;
@property (assign) IBOutlet NSTextField *password;
@property (assign) IBOutlet NSTextField *jsonFilesLocation;
@property (assign) IBOutlet NSButton *jsonFilesLocationButton;
@property (assign) IBOutlet NSTextField *status;
@property (assign) IBOutlet NSTextField *parentClass;
@property (assign) IBOutlet NSTextField *targetPath;
@property (assign) IBOutlet NSButton *shouldCleanUpFolderBeforeGenerating;
@property (assign) IBOutlet NSButton *shouldGenerateClassesOnlyForDataPart;
@property (assign) IBOutlet NSButton *shouldUseSchemaToGenerateClassFiles;

- (IBAction)sourceTypeSegmentChanged:(id)sender;
- (IBAction)generate:(id)sender;
- (IBAction)selectTargetFolder:(id)sender;
@end
