//
//  SQAuthorizationProtocol.h
//  oauthdemoapp
//
//  Created by Bogdan Laukhin on 3/16/16.
//  Copyright © 2016 ua.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQToken.h"

@protocol SQAuthorizationProtocol <NSObject>

@required

- (void)userIsSuccessfullyAuthorized:(SQToken *)token;
- (void)userIsNotAuthorized;

@end
