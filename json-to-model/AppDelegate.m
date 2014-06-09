//
//  AppDelegate.m
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "AppDelegate.h"
#import "WindowController.h"
@implementation AppDelegate
@synthesize myWindowController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
//    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
//    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // Insert code here to initialize your application
    self.myWindowController = [[WindowController alloc]
                                initWithWindowNibName:@"WindowController"];
    [self.window close];
    [self.myWindowController showWindow:self];
}

@end
