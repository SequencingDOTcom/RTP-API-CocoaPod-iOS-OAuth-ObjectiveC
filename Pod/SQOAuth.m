//
//  SQOAuth.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import "SQOAuth.h"
#import "SQServerManager.h"
#import "SQToken.h"
#import "SQTokenStorageAppSettings.h"
#import "SQTokenStorageProtocol.h"



@interface SQOAuth ()

@property (weak, nonatomic) id<SQAuthorizationProtocol> authorizationDelegate;
@property (weak, nonatomic) id<SQTokenStorageProtocol>  tokenStorageDelegate;

@end



@implementation SQOAuth

#pragma mark - Initializer

+ (instancetype)sharedInstance {
    static SQOAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SQOAuth alloc] init];
        // [instance setTokenStorageDelegate:tokenStorage];
    });
    return instance;
}


- (id<SQTokenStorageProtocol>)tokenStorageDelegate {
    return [[SQTokenStorageAppSettings alloc] init];
}


- (void)registrateApplicationParametersCliendID:(NSString *)client_id
                                   clientSecret:(NSString *)client_secret
                                    redirectUri:(NSString *)redirect_uri
                                          scope:(NSString *)scope
                                  oAuthDelegate:(id<SQAuthorizationProtocol>)delegate {
    
    if (client_id && client_secret && redirect_uri && scope)
        [[SQServerManager sharedInstance] registrateParametersCliendID:client_id ClientSecret:client_secret RedirectUri:redirect_uri Scope:scope];
    
    self.authorizationDelegate = delegate;
}




#pragma mark - for Guest user

- (void)authorizeUser {
    [[SQServerManager sharedInstance] authorizeUser:^(SQToken *token, BOOL didCancel, BOOL error) {
        
        if (token.accessToken != nil) {
            [self.tokenStorageDelegate saveToken:token];
            
            if (self.authorizationDelegate)
                [self.authorizationDelegate userIsSuccessfullyAuthorized:token];
            
        } else if (didCancel) {
            if (self.authorizationDelegate)
                [self.authorizationDelegate userDidCancelAuthorization];
            
        } else if (error) {
            if (self.authorizationDelegate)
                [self.authorizationDelegate userIsNotAuthorized];
        }
    }];
}




#pragma mark - Token methods for Authorized user

- (void)token:(void(^)(SQToken *token))tokenResult {
    SQToken *currentToken = [self.tokenStorageDelegate loadToken];
    
    if ([self isTokenUpToDay]) // token is valid > let's return current token
        tokenResult(currentToken);
    
    else { // token is expired > let's update it
        [self withRefreshToken:currentToken updateAccessToken:^(SQToken *updatedToken) {
            if (updatedToken) {
                [self.tokenStorageDelegate saveToken:updatedToken];
                tokenResult(updatedToken);
                
            } else // smth is wrong, we can't update token
                tokenResult(nil);
        }];
    }
}


- (BOOL)isTokenUpToDay {
    BOOL tokenIsValid = NO;
    SQToken *currentToken = [self.tokenStorageDelegate loadToken];
    
    if (currentToken) {
        NSDate *nowDate = [NSDate date];
        NSDate *expDate = currentToken.expirationDate;
        
        if ([nowDate compare:expDate] == NSOrderedDescending) { // token is expired NSOrderedDescending
            NSLog(@">>>>> [SQOAuth]: token is expired");
            
        } else { // token is valid
            NSLog(@">>>>> [SQOAuth]: token is valid");
            tokenIsValid = YES;
        }
    }
    return tokenIsValid;
}


- (void)withRefreshToken:(SQToken *)refreshToken updateAccessToken:(void (^)(SQToken *))tokenResult {
    if (refreshToken.refreshToken == nil) { // we can't updated token without "refresh token" value
        tokenResult(nil);
        return;
    }
    
    [[SQServerManager sharedInstance] withRefreshToken:refreshToken
                                     updateAccessToken:^(SQToken *updatedToken) {
                                         
                                         if (!updatedToken) { // invalid token
                                             tokenResult(nil);
                                             return;
                                         }
                                         
                                         if (!updatedToken.accessToken || [updatedToken.accessToken length] == 0) { // invalid token
                                             tokenResult(nil);
                                             return;
                                         }
                                         
                                         if (!updatedToken.refreshToken || [updatedToken.refreshToken length] == 0) { // invalid token
                                             tokenResult(nil);
                                             return;
                                         }
                                         
                                         // let's return valid token
                                         tokenResult(updatedToken);
                                     }];
}


- (void)userDidSignOut {
    [self.tokenStorageDelegate eraseToken];
    self.authorizationDelegate = nil;
}




#pragma mark -
#pragma mark Registrate new account

- (void)registrateNewAccountForEmailAddress:(NSString *)emailAddress {
    [[SQServerManager sharedInstance] registrateAccountForEmailAddress:emailAddress withResult:^(NSString *error) {
        
        if (error == nil) {
            if (self.authorizationDelegate)
                [self.authorizationDelegate emailIsRegisteredSuccessfully];
            
        } else {
            if (self.authorizationDelegate)
                [self.authorizationDelegate emailIsNotRegistered:error];
        }
    }];
}



#pragma mark -
#pragma mark Reset password

- (void)resetPasswordForEmailAddress:(NSString *)emailAddress {
    [[SQServerManager sharedInstance] resetPasswordForEmailAddress:emailAddress withResult:^(NSString *error) {
        
        if (error == nil) {
            if (self.authorizationDelegate)
                [self.authorizationDelegate applicationForPasswordResetIsAccepted];
            
        } else {
            if (self.authorizationDelegate)
                [self.authorizationDelegate applicationForPasswordResetIsNotAccepted:error];
        }
    }];
}



@end
