//
//  SBSecondViewController.h
//  ASLExplorer
//
//  Created by Paul Dardeau on 2/8/13.
//  Copyright (c) 2013 Paul Dardeau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBSecondViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

- (IBAction)queryButtonClicked:(id)sender;
- (IBAction)logLevelValueChanged:(id)sender;

@end
