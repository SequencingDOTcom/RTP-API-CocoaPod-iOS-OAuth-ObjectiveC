//
//  SQRegistrationProtocol.h
//  Copyright © 2015-2016 Sequencing.com. All rights reserved
//

#import <Foundation/Foundation.h>


@protocol SQRegistrationProtocol <NSObject>

@required
- (void)userIsSuccessfullyRegistered;
- (void)userIsNotRegistered;

@optional
- (void)userDidCancelRegistration;

@end
