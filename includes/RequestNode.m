//
//  RequestNode.m
//  MOSL
//
//  Created by Sharma Elanthiraiyan on 10/4/13.
//  Copyright (c) 2013 Raghu. All rights reserved.
//

#import "RequestNode.h"
#import "NSDictionary+DictHacks.h"
#import "Logger.h"
@implementation RequestNode

- (id)initWithDataPart:(id<JSONModelBaseProtocol>)dataPart
{
    self = [super init];
    if (self) {
        [self addElement:[[dataPart class] getServletGroup] byPathStr:@"/echo/svcGroup"];
        [self addElement:[[dataPart class] getServletName] byPathStr:@"/echo/svcName"];
        [self addElement:[[dataPart class] getServletVersion] byPathStr:@"/echo/svcVersion"];
        
        if ([dataPart respondsToSelector:@selector(isValid:)]) {
            NSError *error = nil;
            [dataPart isValid:&error];

            if (error) {
                logDebug(@"unable to send request due to internal error reason : %@",[error description]);
                return nil;
            }
        }
        
        NSDictionary *dictionary = [dataPart toDict];
        if ([dictionary count] == 0) {
            [self addElement:[NSDictionary dictionary] byPathStr:@"/request/data"];
        }
        else {
            Node *n = [dictionary createNode];
            [self addNode:n byPathStr:@"/request/data"];
        }
    }
	return self;
}

@end
