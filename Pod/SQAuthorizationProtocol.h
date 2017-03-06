//
//  SQAuthorizationProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
@class SQToken;


@protocol SQAuthorizationProtocol <NSObject>

@required
// authorization methods
- (void)userIsSuccessfullyAuthorized:(SQToken *)token;
- (void)userIsNotAuthorized;
- (void)userDidCancelAuthorization;

// registrate new account methods
- (void)emailIsRegisteredSuccessfully;
- (void)emailIsNotRegistered:(NSString *)errorMessage;

// reset password methods
- (void)applicationForPasswordResetIsAccepted;
- (void)applicationForPasswordResetIsNotAccepted:(NSString *)errorMessage;

@end
