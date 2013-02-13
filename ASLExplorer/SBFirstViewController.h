//
//  SBFirstViewController.h
//  ASLExplorer
//
//  Created by Paul Dardeau on 2/8/13.
//  Copyright (c) 2013 Paul Dardeau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBFirstViewController : UIViewController

- (IBAction)logLevelValueChanged:(id)sender;
- (IBAction)pickNewMessageClicked:(id)sender;
- (IBAction)logMessageClicked:(id)sender;
- (IBAction)nslogSwitchToggled:(id)sender;
- (IBAction)restrictGidUidToggled:(id)sender;

@end
