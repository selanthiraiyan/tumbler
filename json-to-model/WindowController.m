//
//  WindowController.m
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "WindowController.h"
#import "Constants.h"
#import "JSONModel.h"
#import "NSString+StringHelper.h"

@interface WindowController ()

@property (strong) NSMutableArray *jsonModels;
@property (strong) NSString *pathAtWhichJSONFilesAreLocated;
@end

@implementation WindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [self.url setStringValue:[self getStoredURL]];
    [self.parentClass setStringValue:[self getStoredParentClassName]];
    [self.jsonFilesLocation setStringValue:[self getStoredSourcePath]];
    [self.targetPath setStringValue:[self getStoredTargetPath]];
    [self setUpUIElementsBasedOnSegmentSelection];
    
}

- (IBAction)sourceTypeSegmentChanged:(id)sender
{
    [self setUpUIElementsBasedOnSegmentSelection];
}

- (void)setUpUIElementsBasedOnSegmentSelection
{
    
    [self.url setEnabled:YES];
    [self.userName setEnabled:YES];
    [self.password setEnabled:YES];
    [self.jsonFilesLocation setEnabled:YES];
    [self.jsonFilesLocationButton setEnabled:YES];
    
    if (self.sourceTypeSegment.selectedSegment == 0) {
        [self.url setEnabled:NO];
        [self.userName setEnabled:NO];
        [self.password setEnabled:NO];
    }
    else if (self.sourceTypeSegment.selectedSegment == 1) {
        [self.jsonFilesLocation setEnabled:NO];
        [self.jsonFilesLocationButton setEnabled:NO];
    }
}

- (void)updateStatus:(NSString*)status
{
    [self.status setStringValue:status];
    NSLog(@"STATUS:%@", status);
}

- (IBAction)selectTargetFolder:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseDirectories:YES];
    [openDlg setPrompt:@"Select"];
    
    if ( [openDlg runModal] == NSFileHandlingPanelOKButton )
    {
        NSArray* files = [openDlg URLs];
        
        for( int i = 0; i < [files count]; i++ )
        {
            NSString* fileName = [[files objectAtIndex:i] path];
            if (sender == self.jsonFilesLocationButton) {
                [self.jsonFilesLocation setStringValue:fileName];
            }
            else {
                [self.targetPath setStringValue:fileName];
            }
        }
    }
}

- (BOOL)canGenerate {
    if ([self.url stringValue] == nil || [[self.url stringValue] isEqualToString:@""]) {
        [self updateStatus:@"Please enter a url ..."];
        return NO;
    }
    else if ((self.sourceTypeSegment.selectedSegment == 0) && ([self.jsonFilesLocation stringValue] == nil || [[self.jsonFilesLocation stringValue] isEqualToString:@""])) {
        [self updateStatus:@"Please select a valid source location for JSON files ..."];
        return NO;
    }
    else if ([self.targetPath stringValue] == nil || [[self.targetPath stringValue] isEqualToString:@""]) {
        [self updateStatus:@"Please select a valid target path ..."];
        return NO;
    }
    
    return YES;
}

- (IBAction)generate:(id)sender
{
    if ([self canGenerate]) {
        NSString *url = [self.url stringValue];
        
        [self storeURL:url];
        [self storeSourcePath:[self.jsonFilesLocation stringValue]];
        [self storeTargetPath:[self.targetPath stringValue]];
        [self storeParentClassName:[self.parentClass stringValue]];
        
        [self updateStatus:[NSString stringWithFormat:@"Generating classes from URL %@", url]];
        
        [self cleanup];
        
        if (self.sourceTypeSegment.selectedSegment != 0) {
            [self checkoutFiles:url];
            self.pathAtWhichJSONFilesAreLocated = PATH_TO_CHECKOUT_SCHEMA_FILES;
        }
        else {
            self.pathAtWhichJSONFilesAreLocated = [self.jsonFilesLocation stringValue];
        }
        
        [self processFiles];
        
        [self processJSONModelsAndCreateClassFiles];
        
        [self updateStatus:@"Model classes generated. Have fun coding ..."];
    }
}

- (void)processJSONModelsAndCreateClassFiles
{
    NSError *error = nil;
    NSFileManager *fm = [[NSFileManager alloc]init];
    
    for (JSONModel *model in self.jsonModels) {
        
        NSString *rawPath = [self.targetPath stringValue];
        NSString *folderPath = [[[rawPath stringByAppendingPathComponent:model.servletGroup] stringByAppendingPathComponent:model.servletName] stringByAppendingPathComponent:[self getFileNameSuffix:model]];
        
        
        if ([fm createDirectoryAtURL:[NSURL fileURLWithPath:folderPath] withIntermediateDirectories:YES attributes:nil error:&error] == NO) {
            NSLog(@"%@", error);
        }
        
        NSString *headerContent = [self getHeaderStringFromJSONModel:model];
        NSString *headerFile = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.h", model.className]];
        [headerContent writeToFile:[NSURL fileURLWithPath:headerFile] atomically:YES encoding: NSUTF8StringEncoding error: NULL];
        
        NSString *implementationContent = [self getImplementationStringFromJSONModel:model];
        NSString *implementationFile = [folderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.m", model.className]];
        [implementationContent writeToFile:[NSURL fileURLWithPath:implementationFile] atomically:YES encoding: NSUTF8StringEncoding error: NULL];
        
    }
}

- (NSString*)getHeaderStringFromJSONModel:(JSONModel*)model
{
    return [model getHeaderPart];
}

- (NSString*)getImplementationStringFromJSONModel:(JSONModel*)model
{
    return [model getImplementationPart];
}

- (void)processFiles
{
    self.jsonModels = [NSMutableArray array];
    NSDirectoryEnumerator *enumerator = [self getEnumeratorFromPath:self.pathAtWhichJSONFilesAreLocated];
    for (NSURL *url in enumerator) {
        NSError *error;
        NSNumber *isDirectory = nil;
        if (! [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:&error]) {
            NSLog(@"oops: %@", error);
        }
        else if (! [isDirectory boolValue]) {
            NSString *fileName = [url lastPathComponent];
            
            if (self.shouldUseSchemaToGenerateClassFiles.state == NSOnState) {
                if ([fileName hasSuffix:@".schema"] == NO)
                    continue;
            }
            else {
                if ([fileName hasSuffix:@".json"] == NO)
                    continue;
            }
            
            NSArray *splittedString = [fileName componentsSeparatedByString:@"_"];
            NSString *servletGroup = [splittedString objectAtIndex:0];
            NSString *servletName = [splittedString objectAtIndex:1];
            NSString *servletVersion = [[splittedString objectAtIndex:2] substringToIndex:5];
            
            
            NSDictionary *dict = [self getDictFromJSONFileAtURL:url];
            NSDictionary *requestPart = [dict objectForKey:@"request"];
            NSDictionary *responsePart = [dict objectForKey:@"response"];
            
            if (self.shouldUseSchemaToGenerateClassFiles.state == NSOnState) {
                requestPart = [[dict objectForKey:@"properties"] objectForKey:@"request"];
                responsePart = [[dict objectForKey:@"properties"] objectForKey:@"response"];
            }
            
            if (self.shouldGenerateClassesOnlyForDataPart.state == NSOnState) {
                if (self.shouldUseSchemaToGenerateClassFiles.state == NSOnState) {
                    requestPart = [[requestPart objectForKey:@"properties"] objectForKey:@"data"];
                    responsePart = [[responsePart objectForKey:@"properties"] objectForKey:@"data"];
                }
                else {
                    requestPart = [requestPart objectForKey:@"data"];
                    responsePart = [responsePart objectForKey:@"data"];
                }
            }
            
            NSString *className = [NSString stringWithFormat:@"%@%@ModelRequest", servletName, servletGroup];
            JSONModel *requestModel = [[JSONModel alloc]initWithName:className];
            requestModel.servletName = servletName;
            requestModel.servletGroup = servletGroup;
            requestModel.servletVersion = servletVersion;
            requestModel.parentClassName = [self.parentClass stringValue];
            requestModel.isRequest = YES;
            requestModel.schemaDefinition =requestPart;
            
            className = [NSString stringWithFormat:@"%@%@ModelResponse", servletName, servletGroup];
            JSONModel *responseModel = [[JSONModel alloc]initWithName:className];
            responseModel.servletName = servletName;
            responseModel.servletGroup = servletGroup;
            responseModel.servletVersion = servletVersion;
            responseModel.parentClassName = [self.parentClass stringValue];
            responseModel.isRequest = NO;
            responseModel.schemaDefinition = responsePart;

            if (self.shouldUseSchemaToGenerateClassFiles.state == NSOnState) {
                [self processDictSchema:requestPart usingJSONModel:requestModel];
                [self processDictSchema:responsePart usingJSONModel:responseModel];
            }
            else {
                [self processDictJSON:requestPart usingJSONModel:requestModel];
                [self processDictJSON:responsePart usingJSONModel:responseModel];
            }
        }
    }
}

- (void)processDictJSON:(NSDictionary*)dict usingJSONModel:(JSONModel*)jsonModel
{
    [self.jsonModels addObject:jsonModel];
    
    for (NSString *key in [dict allKeys]) {
        
        id object = [dict objectForKey:key];
        
        if ([object isKindOfClass:[NSArray class]]) {
            
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:@"NSMutableArray"  instanceName:key];
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
            
            id objectInArray = [object objectAtIndex:0];
            
            if ([objectInArray isKindOfClass:[NSDictionary class]]) {
                NSString *className = [NSString stringWithFormat:@"%@%@", jsonModel.className, [key capitalizeFirstLetter]];
                JSONModel *model = [[JSONModel alloc]initWithName:className outerClass:jsonModel];
                
                [self processDictJSON:objectInArray usingJSONModel:model];
            }
        }
        else if ([object isKindOfClass:[NSDictionary class]]) {
            
            NSString *className = [NSString stringWithFormat:@"%@%@", jsonModel.className, [key capitalizeFirstLetter]];
            JSONModel *model = [[JSONModel alloc]initWithName:className outerClass:jsonModel];
            
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:className  instanceName:key];
            dataType.isOfCustomClass = YES;
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
            
            [self processDictJSON:object usingJSONModel:model];
        }
        else {
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:NSStringFromClass([object class]) instanceName:key];
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
        }
    }
}

- (void)processDictSchema:(NSDictionary*)dict usingJSONModel:(JSONModel*)jsonModel
{
    [self.jsonModels addObject:jsonModel];

    NSDictionary *properties = [dict objectForKey:@"properties"];

    for (NSString *key in [properties allKeys]) {
        

        NSDictionary *property = [properties objectForKey:key];

        NSString *type = [property objectForKey:@"type"];
        NSString *idFromSchema = key;
        
        if ([type isEqualToString:@"array"]) {
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:@"NSMutableArray"  instanceName:idFromSchema];
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
            
            NSString *innerType = [[property objectForKey:@"items"] objectForKey:@"type"];
            
            if ([innerType isEqualToString:@"object"]) {
                NSString *className = [NSString stringWithFormat:@"%@%@", jsonModel.className, [idFromSchema capitalizeFirstLetter]];
                JSONModel *model = [[JSONModel alloc]initWithName:className outerClass:jsonModel];
                model.schemaDefinition = [property objectForKey:@"items"];
                [self processDictSchema:[property objectForKey:@"items"] usingJSONModel:model];
            }

        }
        else if ([type isEqualToString:@"object"]) {
            NSString *className = [NSString stringWithFormat:@"%@%@", jsonModel.className, [idFromSchema capitalizeFirstLetter]];
            JSONModel *model = [[JSONModel alloc]initWithName:className outerClass:jsonModel];
            model.schemaDefinition = property;

            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:className  instanceName:idFromSchema];
            dataType.isOfCustomClass = YES;
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];

            [self processDictSchema:property usingJSONModel:model];
        }
        else if ([type isEqualToString:@"boolean"]) {
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:@"Boolean" instanceName:idFromSchema];
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
        }
        else if ([type isEqualToString:@"integer"] || [type isEqualToString:@"number"]) {
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:@"Number" instanceName:idFromSchema];
            dataType.schemaDefinition = property;
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
        }
        else if ([type isEqualToString:@"string"]) {
            JSONDataType *dataType = [[JSONDataType alloc]initWithClassName:@"String" instanceName:idFromSchema];
            dataType.schemaDefinition = property;
            [jsonModel.consistsOfInstanceVarsOfClass addObject:dataType];
        }
        else if ([type isEqualToString:@"null"]) {
            
        }
    }
}


- (NSString*)getFileNameSuffix:(JSONModel*)jsonModel
{
    return jsonModel.isRequest?@"Request":@"Response";;
}

- (NSDictionary*)getDictFromJSONFileAtURL:(NSURL*)url
{
    [self updateStatus:[NSString stringWithFormat:@"Generating dictionary from file at URL %@", url]];
    
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:NSJSONReadingAllowFragments error:&error];
    return dict;
}

- (void)checkoutFiles:(NSString*)url
{
    [self updateStatus:[NSString stringWithFormat:@"Checking out files from url %@", url]];
    
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/usr/bin/svn"];
    
    NSArray *arguments;
    arguments = [NSArray arrayWithObjects: @"co", url, PATH_TO_CHECKOUT_SCHEMA_FILES, @"--username", [self.userName stringValue], @"--password", [self.password stringValue], nil];
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    [task setStandardInput:[NSPipe pipe]];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"grep returned:\n%@", string);
    [self updateStatus:string];
}

- (void)deleteAllFilesInFolder:(NSString*)path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:path];
    for (NSString *file in enumerator) {
        NSError *error;
        NSString *fullPath = [path stringByAppendingPathComponent:file];
        NSLog(@"Deleting %@ at %@", file, fullPath);
        if (![fileManager removeItemAtPath:fullPath error:&error] && error) {
            NSLog(@"oops: %@", error);
        }
    }
}

- (void)cleanup {
    [self updateStatus:@"Cleaning up"];
    
    if (self.shouldCleanUpFolderBeforeGenerating.state == NSOnState) {
        NSLog(@"Deleting all files from target path");
        [self deleteAllFilesInFolder:[self.targetPath stringValue]];
        [self deleteAllFilesInFolder:PATH_TO_CHECKOUT_SCHEMA_FILES];
    }
    
}

#pragma mark User Defauts storage related methods

- (void)storeParentClassName:(NSString*)name {
    [self storeString:name forKey:KEY_TO_STORE_PARENT_CLASS_NAME];
}

- (NSString*)getStoredParentClassName {
    return [self getStoredStringForKey:KEY_TO_STORE_PARENT_CLASS_NAME];
}

- (void)storeSourcePath:(NSString*)path
{
    [self storeString:path forKey:KEY_TO_STORE_SOURCE_PATH];
}

- (NSString*)getStoredSourcePath
{
    return [self getStoredStringForKey:KEY_TO_STORE_SOURCE_PATH];
}

- (void)storeTargetPath:(NSString*)path
{
    [self storeString:path forKey:KEY_TO_STORE_TARGET_PATH];
}

- (NSString*)getStoredTargetPath {
    return [self getStoredStringForKey:KEY_TO_STORE_TARGET_PATH];
}

- (void)storeURL:(NSString*)url {
    [self storeString:url forKey:KEY_TO_STORE_URL];
}

- (NSString*)getStoredURL {
    return [self getStoredStringForKey:KEY_TO_STORE_URL];
}

- (void)storeString:(NSString*)string forKey:(NSString*)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:string forKey:key];
    [prefs synchronize];
}

- (NSString*)getStoredStringForKey:(NSString*)key {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    return [prefs stringForKey:key];
}

#pragma mark Helper methods
- (NSDirectoryEnumerator*)getEnumeratorFromPath:(NSString*)path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSURL *directoryURL = [NSURL URLWithString:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:^(NSURL *url, NSError *error) {
                                             // Handle the error.
                                             // Return YES if the enumeration should continue after the error.
                                             return YES;
                                         }];
    return enumerator;
}
@end
