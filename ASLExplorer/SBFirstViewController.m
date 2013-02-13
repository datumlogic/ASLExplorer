//
//  SBFirstViewController.m
//  ASLExplorer
//
//  Created by Paul Dardeau on 2/8/13.
//  Copyright (c) 2013 Paul Dardeau. All rights reserved.
//
#include <asl.h>

#import "SBFirstViewController.h"
#import "SBAppDelegate.h"

static NSString *kDefaultFacility = @"Some Facility";
static NSString *kDefaultLogMessage = @"Some other log message";

static NSString *facilities =
@"Dining Room"
"|Library"
"|Ball Room"
"|Lounge"
"|Kitchen"
"|Hall"
"|Billiard Room"
"|Study"
"|Conservatory";

static NSString *emergencyMessages =
@"Aliens are invading!"
"|Zombie attack!"
"|The roof is on fire!"
"|Nuclear attack!"
"|Siri, call 911!"
"|I've fallen, and can't get up!";

static NSString *alertMessages =
@"Battery low, device about to turn off"
"|Hey guys! Watch this!"
"|Door ajar!"
"|Danger Will Robinson!"
"|Beware the ides of March"
"|Don't make me stop this car!";

static NSString *criticalMessages =
@"Time is of the essense"
"|And now for the tricky part..."
"|Et tu, Brute?"
"|A friend in need is a friend indeed"
"|Rikki don't lose that number"
"|Don't call us we'll call you";

static NSString *errorMessages =
@"Unable to read from database"
"|Unable to write to database"
"|This does not compute!"
"|The iPhone maps sent me here"
"|My dog ate my homework"
"|The check is in the mail";

static NSString *warningMessages =
@"GPS turned off"
"|User denied access to location"
"|Toto, we're not in Kansas anymore!"
"|Lucy's in the sky with diamonds"
"|Surgeon General has determined that smoking is bad"
"|What happens in Vegas stays in Vegas";

static NSString *noticeMessages =
@"Objects in mirror are closer than they appear"
"|Pedestrians have the right of way"
"|Shirt and shoes required for entry"
"|We reserve the right to refuse service"
"|This product contains no MSG"
"|Violators will be towed at owner expense";

static NSString *infoMessages =
@"An apple a day keeps the doctor away"
"|A penny saved is a penny earned"
"|Patience is a virtue"
"|Two wrongs don't make a right"
"|Honesty is the best policy"
"|Never a dull moment"
"|Never trust a skinny chef";

static NSString *debugMessages =
@"Attempted division by zero"
"|Missing mime type"
"|Keyboard driver missing. Press F1 to continue."
"|You didn't think I'd do that, did you?"
"|Access violation"
"|System error. Status code=53.";



@interface SBFirstViewController ()

@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UISwitch *onOffUseNSLog;
@property (strong, nonatomic) IBOutlet UISwitch *onOffRestrictGidUid;
@property (strong, nonatomic) IBOutlet UILabel *senderValue;
@property (strong, nonatomic) IBOutlet UILabel *levelValue;
@property (strong, nonatomic) IBOutlet UILabel *facilityValue;
@property (strong, nonatomic) IBOutlet UILabel *messageValue;


@property (strong, nonatomic) NSArray *listFacilities;

@property (strong, nonatomic) NSArray *listEmergencyMessages;
@property (strong, nonatomic) NSArray *listAlertMessages;
@property (strong, nonatomic) NSArray *listCriticalMessages;
@property (strong, nonatomic) NSArray *listErrorMessages;
@property (strong, nonatomic) NSArray *listWarningMessages;
@property (strong, nonatomic) NSArray *listNoticeMessages;
@property (strong, nonatomic) NSArray *listInfoMessages;
@property (strong, nonatomic) NSArray *listDebugMessages;

@property (weak, nonatomic) NSString *facility;
@property (weak, nonatomic) NSString *logMessage;

@property (nonatomic) int logLevel;
@property (nonatomic) BOOL usePlainNSLog;
@property (nonatomic) BOOL restrictGidUid;


@end

@implementation SBFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Generate", @"Generate");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    srand(time(NULL));
    
    self.listFacilities = [facilities componentsSeparatedByString:@"|"];
    
    self.listEmergencyMessages = [emergencyMessages componentsSeparatedByString:@"|"];
    self.listAlertMessages = [alertMessages componentsSeparatedByString:@"|"];
    self.listCriticalMessages = [criticalMessages componentsSeparatedByString:@"|"];
    self.listErrorMessages = [errorMessages componentsSeparatedByString:@"|"];
    self.listWarningMessages = [warningMessages componentsSeparatedByString:@"|"];
    self.listNoticeMessages = [noticeMessages componentsSeparatedByString:@"|"];
    self.listInfoMessages = [infoMessages componentsSeparatedByString:@"|"];
    self.listDebugMessages = [debugMessages componentsSeparatedByString:@"|"];
    
    self.logLevel = -1;
    self.usePlainNSLog = NO;
    self.restrictGidUid = NO;
    
    self.onOffUseNSLog.on = self.usePlainNSLog;
    self.onOffRestrictGidUid.on = self.restrictGidUid;
    
    SBAppDelegate *appDelegate = (SBAppDelegate*) [[UIApplication sharedApplication] delegate];
    self.senderValue.text = appDelegate.sender;
    
    [self logLevelValueChanged:nil];
    [self pickNewMessageClicked:nil];
    
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*)messageFromList:(NSArray*)listMessages
              defaultMessage:(NSString*)defaultMessage
{
    const int countMessages = [listMessages count];
    if (countMessages > 0) {
        const int index = rand() % countMessages;
        if ((index >= 0) && (index < countMessages)) {
            return [listMessages objectAtIndex:index];
        } else {
            return defaultMessage;
        }
    } else {
        return defaultMessage;
    }
}

- (NSString*)pickFacility
{
    return [self messageFromList:self.listFacilities
                  defaultMessage:kDefaultFacility];
}

- (NSString*)emergencyMessage
{
    return [self messageFromList:self.listEmergencyMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)alertMessage
{
    return [self messageFromList:self.listAlertMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)criticalMessage
{
    return [self messageFromList:self.listCriticalMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)errorMessage
{
    return [self messageFromList:self.listErrorMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)warningMessage
{
    return [self messageFromList:self.listWarningMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)noticeMessage
{
    return [self messageFromList:self.listNoticeMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)infoMessage
{
    return [self messageFromList:self.listInfoMessages
                  defaultMessage:kDefaultLogMessage];
}

- (NSString*)debugMessage
{
    return [self messageFromList:self.listDebugMessages
                  defaultMessage:kDefaultLogMessage];
}

#pragma mark - ASL message key support

+ (void) logToASL:(NSString*) sender
         facility:(NSString*) facility
            level:(int) level
          message:(NSString*) messageText
     restrictRead:(BOOL) restrictRead
{
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
    
    if ((level < ASL_LEVEL_EMERG) || (level > ASL_LEVEL_DEBUG)) {
        NSLog(@"Invalid level value: %d", level);
        return;
    }
    
    BOOL openNeeded = NO;
    
    if ((level > ASL_LEVEL_NOTICE) || restrictRead) {
        openNeeded = YES;
    }
    
    if (openNeeded) {
        uint32_t aslOpenFlags;
    
        // NOTE: swap the commented line below to stop output to standard err
        //       stream (xcode console)
        //aslOpenFlags = ASL_OPT_NO_REMOTE;
        aslOpenFlags = ASL_OPT_STDERR | ASL_OPT_NO_REMOTE;
    
        aslclient client = asl_open([sender UTF8String],
                                    [facility UTF8String],
                                    aslOpenFlags);
    
        if (client == NULL) {
            NSLog(@"Unable to access ASL");
            return;
        }
    
        if (level > ASL_LEVEL_NOTICE) {
            // NOTE: ASL doesn't seem to honor this call, it will still drop
            // anything below ASL_LEVEL_NOTICE
            asl_set_filter(client, ASL_FILTER_MASK_UPTO(ASL_LEVEL_DEBUG));
        }
    
        aslmsg msg = asl_new(ASL_TYPE_MSG);
    
        if (msg != NULL) {
            if (restrictRead) {
                SBAppDelegate *appDelegate = (SBAppDelegate*) [[UIApplication sharedApplication] delegate];
                NSString *gid = appDelegate.gid;
                NSString *uid = appDelegate.uid;

                //security for messages, only we can query for these
                if ([gid length] > 0) {
                    asl_set(msg, ASL_KEY_READ_GID, [gid UTF8String]);
                }
            
                if ([uid length] > 0) {
                    asl_set(msg, ASL_KEY_READ_UID, [uid UTF8String]);
                }
            }
        
            asl_log(client, msg, level, "%s", [messageText UTF8String]);
            asl_free(msg);
        } else {
            NSLog(@"Unable to create new ASL message");
        }
    
        asl_close(client);
    }
    else
    {
        aslmsg msg = asl_new(ASL_TYPE_MSG);

        if (msg != NULL) {
            int rc = asl_log(NULL, msg, level, "%s", [messageText UTF8String]);
            if (rc != 0) {
                //times are tough when even the logger fails you
                NSLog(@"Unable to log message");
            }
            asl_free(msg);
        }
    }
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
    
        self.levelValue.text = logLevelValue;
        [self pickNewMessageClicked:nil];
    }
}

- (IBAction)pickNewMessageClicked:(id)sender
{
    NSString* logMessage = @"";
    
    switch( self.logLevel )
    {
        case ASL_LEVEL_EMERG:
            logMessage = [self emergencyMessage];
            break;
        case ASL_LEVEL_ALERT:
            logMessage = [self alertMessage];
            break;
        case ASL_LEVEL_CRIT:
            logMessage = [self criticalMessage];
            break;
        case ASL_LEVEL_ERR:
            logMessage = [self errorMessage];
            break;
        case ASL_LEVEL_WARNING:
            logMessage = [self warningMessage];
            break;
        case ASL_LEVEL_NOTICE:
            logMessage = [self noticeMessage];
            break;
        case ASL_LEVEL_INFO:
            logMessage = [self infoMessage];
            break;
        case ASL_LEVEL_DEBUG:
            logMessage = [self debugMessage];
            break;
    }
    
    self.logMessage = logMessage;
    self.facility = [self pickFacility];
    self.messageValue.text = logMessage;
    self.facilityValue.text = self.facility;
}

- (IBAction)logMessageClicked:(id)sender
{
    if (self.usePlainNSLog) {
        NSLog(@"%@", self.logMessage);
    } else {
        SBAppDelegate *appDelegate = (SBAppDelegate*) [[UIApplication sharedApplication] delegate];

        [SBFirstViewController logToASL:appDelegate.sender
                               facility:self.facility
                                  level:self.logLevel
                                message:self.logMessage
                           restrictRead:self.restrictGidUid];
    }
}

- (IBAction)nslogSwitchToggled:(id)sender
{
    self.usePlainNSLog = self.onOffUseNSLog.on;
}

- (IBAction)restrictGidUidToggled:(id)sender
{
    self.restrictGidUid = self.onOffRestrictGidUid.on;
}

@end
