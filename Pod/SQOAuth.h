//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>
#import "SQAuthorizationProtocol.h"
@class SQToken;


@interface SQOAuth : NSObject

@property (weak, nonatomic) id<SQAuthorizationProtocol> authorizationDelegate;

// designated initializer
+ (instancetype)sharedInstance;

// method to set up apllication registration parameters
- (void)registerApplicationParametersCliendID:(NSString *)client_id
                                 clientSecret:(NSString *)client_secret
                                  redirectUri:(NSString *)redirect_uri
                                        scope:(NSString *)scope;


// authorization method that uses SQAuthorizationProtocol as result
- (void)authorizeUserWithOAuthDelegate:(id<SQAuthorizationProtocol>)delegate;

// method to registrate new account / resetpassword
- (void)callRegisterResetAccountFlowForViewController:(UIViewController *)viewController;


// receive updated token
- (void)token:(void(^)(SQToken *token))tokenResult;

// shoud be used when user is authorized but token is expired
- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void(^)(SQToken *updatedToken))tokenResult;

// should be called when sign out, this method will stop refreshToken autoupdater
- (void)userDidSignOut;

@end
