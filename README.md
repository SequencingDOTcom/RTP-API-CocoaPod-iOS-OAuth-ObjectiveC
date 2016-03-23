# CocoaPods plugin for quickly adding Sequencing.com's OAuth2 to iOS apps coded in Objective-C

=========================================
This repo contains CocoaPods plugin code for implementing Sequencing.com's OAuth2 authentication for your Objective-C iOS app so that your app can securely access [Sequencing.com's](https://sequencing.com/) API and app chains.

* oAuth flow is explained [here](https://github.com/SequencingDOTcom/OAuth2-code-with-demo)
* Example that uses this Pod is located [here](https://github.com/SequencingDOTcom/OAuth2-code-with-demo/tree/master/objective-c)

Contents
=========================================
* Cocoa Pod integration
* Resources
* Maintainers
* Contribute

Cocoa Pod integration
======================================

You need to follow instruction below if you want to install and use OAuth logic and file selector logic in your existed or new project.

* create a new project in Xcode

* install pod
	* see [CocoaPods guides](https://guides.cocoapods.org/using/using-cocoapods.html)
	* create Podfile in your project directory: ```$ pod init```
    * specify "sequencing-oauth-api-objc" pod parameters: ```$ pod 'sequencing-oauth-api-objc', '~> 1.0.3'```
	* install the dependency in your project: ```$ pod install```
	* always open the Xcode workspace instead of the project file: ```$ open *.xcworkspace```

* use authorization method(s)
	* create View Controllers, e.g. for Login screen and for Start screen
	
	* in your LoginViewController class:
	
		* add imports
			```
			#import "SQOAuth.h"
			#import "SQToken.h"
			```
		
		* for authorization you need to specify your application parameters in NSString format (BEFORE using authorization method) 
			```
			static NSString *const CLIENT_ID	 = @"your CLIENT_ID here";
			static NSString *const CLIENT_SECRET = @"your CLIENT_SECRET here";
			static NSString *const REDIRECT_URI	 = @"REDIRECT_URI here";
			static NSString *const SCOPE         = @"SCOPE here";
			```    
			
		* register these parameters into OAuth module instance
			```
			[[SQOAuth sharedInstance] registrateApplicationParametersCliendID:CLIENT_ID 
										ClientSecret:CLIENT_SECRET 
										RedirectUri:REDIRECT_URI 
										Scope:SCOPE];
			```
		
		* add import for protocol
			```
			#import "SQAuthorizationProtocol.h"
			```
			
		* subscribe your class for this protocol
			```
			<SQAuthorizationProtocol>
			```
	
		* subscribe your class as delegate for such protocol
			```
			[[SQOAuth sharedInstance] setAuthorizationDelegate:self];
			```
		
		* add methods for SQAuthorizationProtocol
			```
			- (void)userIsSuccessfullyAuthorized:(SQToken *)token {
				dispatch_async(dispatch_get_main_queue(), ^{
					// your code is here for successful user authorization
				});
			}

			- (void)userIsNotAuthorized {
				dispatch_async(dispatch_get_main_queue(), ^{
					// your code is here for unsuccessful user authorization
				});
			}
			```
		
		* you can authorize your user now (e.g. via "login" button). For authorization you can use ```authorizeUser``` method. You can get access via shared instance of SQOAuth class)
			```
			[[SQOAuth sharedInstance] authorizeUser];
			```
			
			Related method from SQAuthorizationProtocol will be called as a result
		
		* example of Login button (you can use ```@"button_signin_black"``` image that is included into the Pod within ```AuthImages.xcassets```)
			```
			// set up login button
    		UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    		[loginButton setImage:[UIImage imageNamed:@"button_signin_black"] forState:UIControlStateNormal];
    		[loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    		[loginButton sizeToFit];
    		[loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    		[self.view addSubview:loginButton];
    
    		// adding constraints for login button
    		NSLayoutConstraint *xCenter = [NSLayoutConstraint constraintWithItem:loginButton 
    															attribute:NSLayoutAttributeCenterX 
    															relatedBy:NSLayoutRelationEqual 
    															toItem:self.view 
    															attribute:NSLayoutAttributeCenterX 
    															multiplier:1 constant:0];
    															
    		NSLayoutConstraint *yCenter = [NSLayoutConstraint constraintWithItem:loginButton
    															attribute:NSLayoutAttributeCenterY
    															relatedBy:NSLayoutRelationEqual
    															toItem:self.view
    															attribute:NSLayoutAttributeCenterY
    															multiplier:1
    															constant:0];
    		[self.view addConstraint:xCenter];
    		[self.view addConstraint:yCenter];
    		```
    	
    	* example of ```loginButtonPressed``` method 
    		```
    		- (void)loginButtonPressed {
    			[[SQOAuth sharedInstance] authorizeUser];
    		}
    		```
    		
		
		* add segue in Storyboard from LoginViewController to MainViewController with identifier ```GOTO_MAIN_SCREEN```
		
		* add constant for segue id
			```static NSString *const GOTO_MAIN_SCREEN_SEGUE_ID = @"GOTO_MAIN_SCREEN";```
		
		* example of navigation methods when user is authorized
			```
			- (void)userIsSuccessfullyAuthorized:(SQToken *)token {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self performSegueWithIdentifier:GOTO_MAIN_SCREEN_SEGUE_ID sender:token];
				});
			}
			
			- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
				if ([segue.identifier isEqual:GOTO_MAIN_SCREEN_SEGUE_ID]) {
					StartViewController *startVC = segue.destinationViewController;
					[startVC setToken:sender];
				}
			}
			```
		
	* in your StartViewController class:
		
		* add imports
			```
			#import "SQOAuth.h"
			#import "SQToken.h"
			```
		
		* add import for protocol
			```
			#import "SQTokenRefreshProtocol.h"
			```
		
		* subscribe your class for these protocols
			```
			<SQTokenRefreshProtocol>
			```
		
		* subscribe your class as delegate for such protocols
			```
			[[SQOAuth sharedInstance] setRefreshTokenDelegate:self];
			```
		
		* add method for SQTokenRefreshProtocol - it is called when token is refreshed
			```
			- (void)tokenIsRefreshed:(SQToken *)updatedToken {
				// your code is here to handle refreshed token
			}
			```
		
		* in method ```userIsSuccessfullyAuthorized``` you'll receive SQToken object, that contains following 5 properties with clear titles for usage:
			```	
			NSString *accessToken
			NSDate   *expirationDate
			NSString *tokenType
			NSString *scope
			NSString *refreshToken
			```
	
		* in method ```tokenIsRefreshed``` you'll receive updated token with the same object model.
			DO NOT OVERRIDE REFRESH_TOKEN PROPERTY for TOKEN object - it comes as null after refresh token request
	
		* for your extra needs you can always get access directly to the up-to-day token object which is stored in ```SQAuthResult``` class via ```token``` property
			```
			[[SQAuthResult sharedInstance] token];
			```


Resources
======================================
* [App chains](https://sequencing.com/app-chains)
* [File selector code](https://github.com/SequencingDOTcom/File-Selector-code)
* [Developer center](https://sequencing.com/developer-center)
* [Developer documentation](https://sequencing.com/developer-documentation/)

Maintainers
======================================
This repo is actively maintained by [Sequencing.com](https://sequencing.com/). Email the Sequencing.com bioinformatics team at gittaca@sequencing.com if you require any more information or just to say hola.

Contribute
======================================
We encourage you to passionately fork us. If interested in updating the master branch, please send us a pull request. If the changes contribute positively, we'll let it ride.
