//
//  SQTokenStorageAppSettings.m
//  Copyright © 2017 Sequencing.com. All rights reserved
//


#import "SQTokenStorageAppSettings.h"
#import "SQToken.h"


NSString *KEY_TOKEN_ACCESS = @"__SEQUENCING-OAUTH-COCOAPOD-OBJC-PLUGIN-USERTOKEN-KEY";




@interface SQTokenStorageAppSettings ()

@property (nonatomic) NSUserDefaults *userDefaults;

@end




@implementation SQTokenStorageAppSettings

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    //NSLog(@"SQTokenStorageAppSettings INIT");
    return self;
}

- (void)dealloc {
    //NSLog(@"SQTokenStorageAppSettings DEALLOC");
}



- (SQToken *)loadToken {
    [_userDefaults synchronize];
    NSData *tokenData = [_userDefaults objectForKey:KEY_TOKEN_ACCESS];
    SQToken *token = [NSKeyedUnarchiver unarchiveObjectWithData:tokenData];
    
    //NSLog(@"load token: %@", [token accessToken]);
    if (token)
        return token;
    else
        return nil;
}


- (void)saveToken:(SQToken *)token {
    //NSLog(@"save token: %@", [token accessToken]);
    if (!token) return;
    
    if ([token.accessToken length] == 0) return;
    
    SQToken *oldToken = [self loadToken];
    if (!oldToken) [self archiveToken:token];
    else {
        oldToken.accessToken    = token.accessToken;
        oldToken.expirationDate = token.expirationDate;
        oldToken.tokenType      = token.tokenType;
        oldToken.scope          = token.scope;
        if (token.refreshToken != nil) // DO NOT OVERRIDE REFRESH_TOKEN HERE (after refresh token request it comes as null)
            oldToken.refreshToken = token.refreshToken;
        [self archiveToken:oldToken];
    }
}


- (void)archiveToken:(SQToken *)token {
    NSData *tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    [_userDefaults setObject:tokenData forKey:KEY_TOKEN_ACCESS];
    [_userDefaults synchronize];
}


- (void)eraseToken {
    [_userDefaults removeObjectForKey:KEY_TOKEN_ACCESS];
}


@end
