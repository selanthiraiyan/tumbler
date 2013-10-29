//
//  JSONModel.m
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "JSONModel.h"
#import "Condition.h"
#import "Validator.h"
#import "Constants.h"
@implementation JSONModel
@synthesize className;
@synthesize parentClassName;
@synthesize adoptsProtocolsNamed;
@synthesize consistsOfInstanceVarsOfClass;
@synthesize servletName;
@synthesize servletGroup;
@synthesize servletVersion;

@synthesize isRequest;
- (id)initWithName:(NSString*)name
{
    return [self initWithName:name outerClass:nil];
}

- (id)initWithName:(NSString *)name outerClass:(JSONModel*)model
{
    self = [super init];
    if (self) {
        className = name;
        parentClassName = @"NSObject";
        adoptsProtocolsNamed = [NSMutableArray array];
        consistsOfInstanceVarsOfClass = [NSMutableArray array];
        
        if (model) {
            servletGroup = model.servletGroup;
            servletName = model.servletName;
            servletVersion = model.servletVersion;
            isRequest = model.isRequest;
            parentClassName = model.parentClassName;
        }
    }
    return self;
}

- (NSString*)description
{
    NSString *dec = [super description];
    dec = [dec stringByAppendingFormat:@"Class name - %@ ", self.className];
    dec = [dec stringByAppendingFormat:@"Parent class name - %@ ", self.parentClassName];
    dec = [dec stringByAppendingFormat:@"Protocols - %@ ", self.adoptsProtocolsNamed];
    dec = [dec stringByAppendingFormat:@"Servlet name - %@ ", self.servletName];
    dec = [dec stringByAppendingFormat:@"Servlet group - %@ ", self.servletGroup];
    dec = [dec stringByAppendingFormat:@"Servlet version - %@ ", self.servletVersion];
    return dec;
}

- (NSString*)getHeaderPart
{
    NSMutableString *headerContent = [NSMutableString string];
    [headerContent appendString:[NSString stringWithFormat:@"\n//\n//  %@.h\n//  Tumbler\n//\n//  Created by Sharma Elanthiraiyan.\n//  Copyright (c) Sharma Elanthiraiyan. All rights reserved.\n//\n//\n  ",self.className]];
    [headerContent appendString:@"\n#import <Foundation/Foundation.h>"];
    
    NSString *parent = @"NSObject";
    if (self.parentClassName && ([self.parentClassName isEqualToString:@""] == NO)) {
        [headerContent appendString:[NSString stringWithFormat:@"\n#import \"%@.h\"", self.parentClassName]];
        parent = self.parentClassName;
    }
    
    NSMutableString *headerInnerPart = [NSMutableString string];
    NSMutableString *headerValidationPart = [NSMutableString string];
    NSString *selfValidation = [self getValidationHeaderPart];
    if (selfValidation) {
        [headerValidationPart appendString:selfValidation];
    }
    for (JSONDataType *dataType in self.consistsOfInstanceVarsOfClass) {
        [headerInnerPart appendString:[dataType getDeclarationHeaderPart]];
        if (dataType.isOfCustomClass) {
            [headerContent appendString:[NSString stringWithFormat:@"\n#import \"%@.h\"", dataType.className]];
        }
        
        NSString *validationMethod = [dataType getValidationHeaderPart];
        if (validationMethod) {
            [headerValidationPart appendString:validationMethod];
        }
    }
    
    [headerInnerPart appendString:@"\n\n//Validation related methods"];
    [headerInnerPart appendString:headerValidationPart];
    [headerInnerPart appendString:@"\n\n//Base related methods"];
    [headerInnerPart appendString:@"\n+ (NSString*)getServletName;"];
    [headerInnerPart appendString:@"\n+ (NSString*)getServletGroup;"];
    [headerInnerPart appendString:@"\n+ (NSString*)getServletVersion;"];
    [headerInnerPart appendString:@"\n- (NSString*)getClassNamePrefix;"];
    
    [headerContent appendString:[NSString stringWithFormat:@"\n@interface %@ : %@", self.className, parent]];
    [headerContent appendString:[NSString stringWithFormat:@"\n%@;", headerInnerPart]];
    [headerContent appendString:@"\n@end"];
    
    return headerContent;
    
}

- (NSString*)getImplementationPart
{
    NSMutableString *implementationContent = [NSMutableString string];
    NSMutableString *implementationInnerPart = [NSMutableString string];
    [implementationContent appendString:[NSString stringWithFormat:@"\n//\n//  %@.m\n//  Tumbler\n//\n//  Created by Sharma Elanthiraiyan.\n//  Copyright (c) Sharma Elanthiraiyan. All rights reserved.\n//\n//\n  ",self.className]];
    [implementationContent appendString:[NSString stringWithFormat:@"\n#import \"%@.h\"", self.className]];
    
    NSMutableString *implementationValidationPart = [NSMutableString string];
    NSString *selfValidation = [self getValidationImplementationPart];
    if (selfValidation) {
        [implementationValidationPart appendString:selfValidation];
    }
    for (JSONDataType *dataType in self.consistsOfInstanceVarsOfClass) {
        
        [implementationInnerPart appendString:[dataType getDeclarationImplementationPart]];
        
        NSString *validationMethod = [dataType getValidationImplementationPart];
        if (validationMethod) {
            [implementationValidationPart appendString:validationMethod];
        }
    }
    
    [implementationInnerPart appendString:implementationValidationPart];
    [implementationInnerPart appendString:[NSString stringWithFormat:@"\n+ (NSString*)getServletName \n{\n\treturn @\"%@\";\n}\n", self.servletName]];
    [implementationInnerPart appendString:[NSString stringWithFormat:@"\n+ (NSString*)getServletGroup \n{\n\treturn @\"%@\";\n}\n", self.servletGroup]];
    [implementationInnerPart appendString:[NSString stringWithFormat:@"\n+ (NSString*)getServletVersion \n{\n\treturn @\"%@\";\n}\n", self.servletVersion]];
    [implementationInnerPart appendString:[NSString stringWithFormat:@"\n- (NSString*)getClassNamePrefix \n{\n\treturn @\"%@\";\n}\n", self.className]];
    
    
    [implementationContent appendString:[NSString stringWithFormat:@"\n@implementation %@", self.className]];
    [implementationContent appendString:[NSString stringWithFormat:@"\n\n%@;", implementationInnerPart]];
    [implementationContent appendString:@"\n\n@end"];
    
    return implementationContent;
    
}

- (NSString*)getValidationHeaderPart
{
    if (self.schemaDefinition && SHOULD_CREATE_VALIDATION_METHODS) {
        return [NSString stringWithFormat:@"\n- (BOOL)isValid:(NSError**)error;"];
    }
    return nil;
}

- (NSString*)getValidationImplementationPart
{
    if (self.schemaDefinition && SHOULD_CREATE_VALIDATION_METHODS) {
        NSDictionary *properties = [self.schemaDefinition objectForKey:@"properties"];
        
        if (properties) {
            NSMutableArray *conditions = [NSMutableArray array];

            for (NSString *requiredPropertyName in [properties allKeys]) {
                NSDictionary *property = [properties objectForKey:requiredPropertyName];
                if ([property objectForKey:@"required"]) {
                    Condition *nilCondition = [[Condition alloc]init];
                    nilCondition.conditionStringInsideIf = [NSString stringWithFormat:@"self.%@ == nil", requiredPropertyName];
                    nilCondition.userInfoForError = [NSString stringWithFormat:@"%@ is nil which is a required property.", requiredPropertyName];
                    [conditions addObject:nilCondition];
                }
            }
            return [NSString stringWithFormat:@"\n- (BOOL)isValid:(NSError**)error\n"
                    "{\n"
                    "%@\n"
                    "}\n", [Validator getValidationMethodContent:conditions]];
        }
    }
    return nil;
}

@end
