//
//  JSONDataType.m
//  json-to-model
//
//  Created by Sharma Elanthiraiyan on 7/8/13.
//  Copyright (c) 2013 Sharma Elanthiraiyan. All rights reserved.
//

#import "JSONDataType.h"
#import "NSString+StringHelper.h"
#import "NumberValidator.h"
#import "StringValidator.h"
#import "Constants.h"

@interface JSONDataType ()

@property (strong) NSMutableString *comment;

@end

@implementation JSONDataType
@synthesize className, instanceName;
@synthesize comment;
- (id)initWithClassName:(NSString*)className1 instanceName:(NSString*)instanceName1
{
    self = [super init];
    if (self) {
        if ([className1 hasSuffix:@"String"]) {
            className = @"NSString";
        }
        else if ([className1 hasSuffix:@"Number"] || [className1 hasSuffix:@"Boolean"]) {
            className = @"NSNumber";
        }
        else {
            className = className1;
        }
        instanceName = instanceName1;
        comment = [NSMutableString string];
    }
    return self;
}

- (void)appendComment:(NSString*)comment1
{
    if ([self.comment length] == 0) {
        [self.comment appendString:@"//"];
    }
    [self.comment appendString:comment1];
}

- (NSString*)getDeclarationHeaderPart
{
    return [NSString stringWithFormat:@"\n@property (strong) %@ *%@;%@", className, instanceName, self.comment];
}

- (NSString*)getDeclarationImplementationPart
{
    return [NSString stringWithFormat:@"\n@synthesize %@;",self.instanceName];
}

- (NSString*)getValidationHeaderPart
{
    if (self.schemaDefinition) {
        return [NSString stringWithFormat:@"\n- (BOOL)is%@Valid:(NSError**)error;", [self.instanceName capitalizeFirstLetter]];
    }
    return nil;
}

- (NSString*)getValidationImplementationPart
{
    if (self.schemaDefinition) {
        
        if ([self.className isEqualToString:@"NSNumber"]) {
            return [NSString stringWithFormat:@"\n- (BOOL)is%@Valid:(NSError**)error\n{\n%@\n}", [self.instanceName capitalizeFirstLetter], [NumberValidator getValidationMethodForNumberNamed:self.instanceName usingSchemaDefinition:self.schemaDefinition]];
        }
        else if ([self.className isEqualToString:@"NSString"]) {
            return [NSString stringWithFormat:@"\n- (BOOL)is%@Valid:(NSError**)error\n{\n%@\n}", [self.instanceName capitalizeFirstLetter], [StringValidator getValidationMethodForStringNamed:self.instanceName usingSchemaDefinition:self.schemaDefinition]];
        }
    }
    return nil;
}


@end
