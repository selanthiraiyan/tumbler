//
//  RequestNode.h
//  MOSL
//
//  Created by Sharma Elanthiraiyan on 10/4/13.
//  Copyright (c) 2013 Raghu. All rights reserved.
//

#import "Node.h"
#import "JSONModelBaseProtocol.h"
@interface RequestNode : Node

- (id)initWithDataPart:(id<JSONModelBaseProtocol>)dataPart;

@end
