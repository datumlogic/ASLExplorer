//
//  SBSystemMessage.h
//  ASLExplorer
//
//  Created by Paul Dardeau on 2/8/13.
//  Copyright (c) 2013 Paul Dardeau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBSystemMessage : NSObject

@property (strong,nonatomic) NSDate *timestamp;
@property (strong,nonatomic) NSString *host;
@property (strong,nonatomic) NSString *sender;
@property (strong,nonatomic) NSString *facility;
@property (strong,nonatomic) NSString *messageText;
@property (strong,nonatomic) NSString *messageId;
@property (strong,nonatomic) NSString *session;
@property (nonatomic) int pid;
@property (nonatomic) int uid;
@property (nonatomic) int gid;
@property (nonatomic) int level;


@end
