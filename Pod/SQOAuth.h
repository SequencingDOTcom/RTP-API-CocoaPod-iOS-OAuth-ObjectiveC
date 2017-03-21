//
//  SQOAuth.h
//  Copyright © 2017 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SQAuthorizationProtocol.h"
#import "SQTokenAccessProtocol.h"
@class SQToken;



@interface SQOAuth : NSObject <SQTokenAccessProtocol>

@property (weak, nonatomic) UIViewController<SQAuthorizationProtocol> *delegate;
//@property (weak, nonatomic) UIViewController            *viewControllerDelegate;


// designated initializer
+ (instancetype)sharedInstance;


// method to set up apllication registration parameters
- (void)registerApplicationParametersCliendID:(NSString *)client_id
                                 clientSecret:(NSString *)client_secret
                                  redirectUri:(NSString *)redirect_uri
                                        scope:(NSString *)scope
                                     delegate:(UIViewController<SQAuthorizationProtocol> *)delegate;


// authorization method that uses SQAuthorizationProtocol as result
- (void)authorizeUser;

// method to registrate new account / resetpassword
- (void)callRegisterResetAccountFlow;


// receive updated token
- (void)token:(void(^)(SQToken *token))tokenResult;

// should be called when sign out, this method will erase token and delegates
- (void)userDidSignOut;


@end
