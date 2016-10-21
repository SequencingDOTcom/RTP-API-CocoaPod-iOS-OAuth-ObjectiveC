//
//  SQRegistrationWebViewController.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


typedef void(^RegistrationCompletionBlock)(NSMutableDictionary *response);


@interface SQRegistrationWebViewController : UIViewController

- (id)initWithURL:(NSURL *)url andCompletionBlock:(RegistrationCompletionBlock)completionBlock;

@end
