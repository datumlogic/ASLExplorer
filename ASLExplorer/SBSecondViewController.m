//
//  SBSecondViewController.m
//  ASLExplorer
//
//  Created by Paul Dardeau on 2/8/13.
//  Copyright (c) 2013 Paul Dardeau. All rights reserved.
//

#include <asl.h>

#import "SBSecondViewController.h"
#import "SBSystemMessage.h"
#import "SBAppDelegate.h"

@interface SBSecondViewController ()

@property (strong,nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) IBOutlet UISlider *slider;
@property (strong,nonatomic) IBOutlet UILabel *levelLabel;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSArray *listMessages;

@property (nonatomic) int logLevel;

@end

@implementation SBSecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Query", @"Query");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    self.logLevel = -1;
    [self logLevelValueChanged:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (NSArray *) queryMessages:(NSString*)sender
                maxLogLevel:(int)maxLogLevel
              sinceTimstamp:(NSDate*)sinceTimestamp
                  maxNumber:(int)maxNumberMessages
             restrictUidGid:(BOOL)restrictUidGid
{
    aslmsg q = asl_new(ASL_TYPE_QUERY);
    
    if ([sender length] > 0) {
        asl_set_query(q, ASL_KEY_SENDER, [sender UTF8String], ASL_QUERY_OP_EQUAL);
    }
        
    if (sinceTimestamp != nil) {
        NSString *since = [NSString stringWithFormat:@"%.f",
                           [sinceTimestamp timeIntervalSince1970]];
        asl_set_query(q, ASL_KEY_TIME, [since UTF8String], ASL_QUERY_OP_GREATER);
    }
    
    aslresponse r = asl_search(NULL, q);
    
    NSMutableArray *logEntries = [NSMutableArray array];
    aslmsg m;
    const char *host;
    const char *messageSender;
    const char *session;
    const char *facility;
    const char *messageText;
    const char *messageId;
    const char *timestamp;
    const char *level;
    const char *uid;
    const char *gid;
    const char *pid;
    NSString *appUid = nil;
    NSString *appGid = nil;
    
    if (restrictUidGid) {
        SBAppDelegate *appDelegate = (SBAppDelegate*) [[UIApplication sharedApplication] delegate];
        appGid = appDelegate.gid;
        appUid = appDelegate.uid;
    }
    
    while (NULL != (m = aslresponse_next(r)))
    {
        SBSystemMessage *systemMessage = nil;

        level = asl_get(m, ASL_KEY_LEVEL);
        if (level != NULL) {
            int logLevel = atoi(level);
            if (logLevel > maxLogLevel) {
                continue;
            }

            uid = asl_get(m, ASL_KEY_UID);
            gid = asl_get(m, ASL_KEY_GID);
            pid = asl_get(m, ASL_KEY_PID);

            if (restrictUidGid) {
                if (uid != NULL) {
                    NSString *uidValue = [NSString stringWithUTF8String:uid];
                    if (![appUid isEqualToString:uidValue]) {
                        continue;
                    }
                }
                
                if (gid != NULL) {
                    NSString *gidValue = [NSString stringWithUTF8String:gid];
                    if (![appGid isEqualToString:gidValue]) {
                        continue;
                    }
                }
            }

            systemMessage = [[SBSystemMessage alloc] init];
            systemMessage.level = logLevel;
            
            if (uid != NULL) {
                systemMessage.uid = atoi(uid);
            } else {
                systemMessage.uid = -1;
            }
            
            if (gid != NULL) {
                systemMessage.gid = atoi(gid);
            } else {
                systemMessage.gid = -1;
            }
            
            if (pid != NULL) {
                systemMessage.pid = atoi(pid);
            } else {
                systemMessage.pid = -1;
            }
        }
        
        host = asl_get(m, ASL_KEY_HOST);
        if (host != NULL) {
            systemMessage.host = [NSString stringWithUTF8String:host];
        }
        
        messageSender = asl_get(m, ASL_KEY_SENDER);
        if (messageSender != NULL) {
            systemMessage.sender = [NSString stringWithUTF8String:messageSender];
        }
        
        session = asl_get(m, ASL_KEY_SESSION);
        if (session != NULL) {
            systemMessage.session = [NSString stringWithUTF8String:session];
        }
        
        facility = asl_get(m, ASL_KEY_FACILITY);
        if (facility != NULL) {
            systemMessage.facility = [NSString stringWithUTF8String:facility];
        }
        
        messageText = asl_get(m, ASL_KEY_MSG);
        if (messageText != NULL) {
            systemMessage.messageText = [NSString stringWithUTF8String:messageText];
        }
        
        messageId = asl_get(m, ASL_KEY_MSG_ID);
        if (messageId != NULL) {
            systemMessage.messageId = [NSString stringWithUTF8String:messageId];
        }
        
        timestamp = asl_get(m, ASL_KEY_TIME);
        if (timestamp != NULL) {
            double timestampValue = atof(timestamp);
            systemMessage.timestamp = [NSDate dateWithTimeIntervalSince1970:timestampValue];
        }
        
        if (maxNumberMessages > 0) {
            if ([logEntries count] < maxNumberMessages) {
                [logEntries addObject:systemMessage];
            } else {
                NSLog(@"maximum messages requested reached");
                break;
            }
        } else {
            [logEntries addObject:systemMessage];
        }
    }
    
    aslresponse_free(r);
    asl_free(q);
    
    return logEntries;
}

- (NSInteger)tableView:(UITableView*)tv numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 ) {
        return [self.listMessages count];
    }
    
    return 0;
}

- (NSString*)logLevelLabelForValue:(int)logLevel
{
    NSString *logLevelText = @"";
    
    switch( logLevel )
    {
        case ASL_LEVEL_EMERG:
            logLevelText = @"EMG";
            break;
        case ASL_LEVEL_ALERT:
            logLevelText = @"A";
            break;
        case ASL_LEVEL_CRIT:
            logLevelText = @"C";
            break;
        case ASL_LEVEL_ERR:
            logLevelText = @"E";
            break;
        case ASL_LEVEL_WARNING:
            logLevelText = @"W";
            break;
        case ASL_LEVEL_NOTICE:
            logLevelText = @"N";
            break;
        case ASL_LEVEL_INFO:
            logLevelText = @"I";
            break;
        case ASL_LEVEL_DEBUG:
            logLevelText = @"D";
            break;
    }
    
    return logLevelText;
}

- (UIColor*)backgroundColorForLevel:(int)logLevel
{
    UIColor *bgColor = [UIColor clearColor];
    
    switch( logLevel )
    {
        case ASL_LEVEL_EMERG:
            bgColor = [UIColor redColor];
            break;
        case ASL_LEVEL_ALERT:
            bgColor = [UIColor redColor];
            break;
        case ASL_LEVEL_CRIT:
            bgColor = [UIColor redColor];
            break;
        case ASL_LEVEL_ERR:
            bgColor = [UIColor orangeColor];
            break;
        case ASL_LEVEL_WARNING:
            bgColor = [UIColor yellowColor];
            break;
    }
    
    return bgColor;
}

- (UITableViewCell*)tableView:(UITableView*)tv cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"messageCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"messageCell"];
    }
    
    SBSystemMessage *message = [self.listMessages objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                           [self logLevelLabelForValue:message.level],
                           [self.dateFormatter stringFromDate:message.timestamp],
                           message.facility];
    cell.detailTextLabel.text = message.messageText;
    
    UIColor* bgColor = [self backgroundColorForLevel:message.level];
    cell.contentView.backgroundColor = bgColor;
    cell.textLabel.backgroundColor = bgColor;
    cell.detailTextLabel.backgroundColor = bgColor;
    
    return cell;
}

- (IBAction)queryButtonClicked:(id)sender
{
    SBAppDelegate *appDelegate = (SBAppDelegate*) [[UIApplication sharedApplication] delegate];
    
    /*
     #define ASL_LEVEL_EMERG   0
     #define ASL_LEVEL_ALERT   1
     #define ASL_LEVEL_CRIT    2
     #define ASL_LEVEL_ERR     3
     #define ASL_LEVEL_WARNING 4
     #define ASL_LEVEL_NOTICE  5
     #define ASL_LEVEL_INFO    6
     #define ASL_LEVEL_DEBUG   7
     */

    NSString *senderString = appDelegate.sender;
    int maxLogLevel = self.logLevel;
    NSDate *sinceTimestamp = nil;
    BOOL restrictUidGid = YES;
    int maxNumber = 150;
    
    self.listMessages = [SBSecondViewController queryMessages:senderString
                                                  maxLogLevel:maxLogLevel
                                                sinceTimstamp:sinceTimestamp
                                                    maxNumber:maxNumber
                                               restrictUidGid:restrictUidGid];
    [self.tableView reloadData];
}

- (IBAction)logLevelValueChanged:(id)sender
{
    const int sliderValueAsInt = (int) self.slider.value;
    
    if (self.logLevel != sliderValueAsInt) {
        self.logLevel = (int) self.slider.value;
        NSString* logLevelValue = @"";
        
        switch( self.logLevel )
        {
            case ASL_LEVEL_EMERG:
                logLevelValue = @"Emergency";
                break;
            case ASL_LEVEL_ALERT:
                logLevelValue = @"Alert";
                break;
            case ASL_LEVEL_CRIT:
                logLevelValue = @"Critical";
                break;
            case ASL_LEVEL_ERR:
                logLevelValue = @"Error";
                break;
            case ASL_LEVEL_WARNING:
                logLevelValue = @"Warning";
                break;
            case ASL_LEVEL_NOTICE:
                logLevelValue = @"Notice";
                break;
            case ASL_LEVEL_INFO:
                logLevelValue = @"Info";
                break;
            case ASL_LEVEL_DEBUG:
                logLevelValue = @"Debug";
                break;
        }
        
        self.levelLabel.text = logLevelValue;
    }
}

@end
