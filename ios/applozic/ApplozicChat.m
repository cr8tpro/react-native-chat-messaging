//
//  ApplozicChatManger.m
//  ApplozicSample
//
//  Created by Adarsh on 17/01/18.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import "ApplozicChat.h"
#import "ALChatManager.h"
#import <Applozic/ALUser.h>
#import <Applozic/ALPushAssist.h>
#import <Applozic/ALChannelService.h>
#import <Applozic/ALChannelService.h>
#import <Applozic/ALUserService.h>
#import <Applozic/ALContactService.h>

@implementation ApplozicChat

// To export a module named CalendarManager
RCT_EXPORT_MODULE();


/**
 * Login method of the user
 *
 */

RCT_EXPORT_METHOD(login:(NSDictionary *)userDetails andCallback:(RCTResponseSenderBlock)callback )
{
  
  ALUser * aluser =  [[ALUser alloc] initWithJSONString:[self getJsonString:userDetails]];
  
  ALChatManager * chatManger = [[ALChatManager alloc] init];
  
  [chatManger registerUserWithCompletion:aluser withHandler:^(ALRegistrationResponse *rResponse, NSError *error) {
    
    if(error){
      
      NSString* errorResponse = error.description;
      if(rResponse){
        
        errorResponse = [self getJsonString:[rResponse dictionary]];
      }
      return callback(@[errorResponse, [NSNull null]]);

    }else if ( rResponse.isRegisteredSuccessfully ){
      
      return callback(@[[NSNull null],[self getJsonString:[rResponse dictionary]]]);
      
    }
  }];
  
  NSLog(@"Pretending to create an event  at ");
  
//===================================== initiating chats=================================================
}
/**
 * Open chats
 *
 **/
RCT_EXPORT_METHOD(openChat)
{
  
  ALChatManager * chatManger = [[ALChatManager alloc] init];
  ALPushAssist* pushAssistant = [[ALPushAssist alloc] init];
  dispatch_async(dispatch_get_main_queue(), ^{
    [chatManger launchChat:pushAssistant.topViewController];
    
  });

}
/**
 * Open chat with Users
 *
 **/
RCT_EXPORT_METHOD(openChatWithUser:(NSString*)userId)
{
  
  ALChatManager * chatManger = [[ALChatManager alloc] init];
  ALChatLauncher * chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:chatManger.getApplicationKey];
  ALPushAssist* pushAssistant = [[ALPushAssist alloc] init];

  dispatch_async(dispatch_get_main_queue(), ^{
    
    [chatLauncher launchIndividualChat:userId withGroupId:nil andViewControllerObject:pushAssistant.topViewController andWithText:nil ];
    
  });
  
}
/**
 * Open chat with Group
 *
 **/
RCT_EXPORT_METHOD(openChatWithGroup:(nonnull NSNumber*)groupId)
{
  
  ALChatManager * chatManger = [[ALChatManager alloc] init];
  ALChatLauncher * chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:chatManger.getApplicationKey];
  ALPushAssist* pushAssistant = [[ALPushAssist alloc] init];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    [chatLauncher launchIndividualChat:nil withGroupId:groupId andViewControllerObject:pushAssistant.topViewController andWithText:nil ];
    
  });
}

/**
 * Open chat with ClientGroupId
 *
 **/
RCT_EXPORT_METHOD(openChatWithClientGroupId:(nonnull NSString*) clientGroupId andCallback:(RCTResponseSenderBlock)callback)
{
  
  ALChatManager * chatManger = [[ALChatManager alloc] init];
  ALPushAssist* pushAssistant = [[ALPushAssist alloc] init];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    
    ALChannelService *service = [ALChannelService new];
    ALChatLauncher * chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:chatManger.getApplicationKey];
    
    [service getChannelInformation:nil orClientChannelKey:clientGroupId withCompletion:^(ALChannel *alChannel) {
      
      if(alChannel){
        
         [chatLauncher launchIndividualChat:nil withGroupId:alChannel.key andViewControllerObject:pushAssistant.topViewController andWithText:nil ];
         return callback(@[ [NSNull null],@"success"]);
        
    }else{
      return callback(@[@"channel not found", [NSNull null] ]);
    }
              
    }] ;
  });
}

//========================= Group Methods ================================================================

RCT_EXPORT_METHOD(createGroup:(NSDictionary *)channelDetails andCallback:(RCTResponseSenderBlock)callback )
{
  
  NSString* channelName = [channelDetails valueForKey:@"groupName"];
  NSString* clientChannelKey = [channelDetails valueForKey:@"clientGroupId"];
  NSString* imageLink = [channelDetails valueForKey:@"imageUrl"];
  NSMutableArray * groupMemberList= [channelDetails objectForKey:@"groupMemberList"];
  NSMutableDictionary * groupMetaData= [channelDetails objectForKey:@"metadata"];
  NSNumber * parentChannelKey= [channelDetails objectForKey:@"parentChannelKey"];
  NSString * adminUserId= [channelDetails objectForKey:@"adminUserId"];

  
  [ALChannelClientService createChannel:channelName andParentChannelKey:parentChannelKey orClientChannelKey:clientChannelKey
                         andMembersList:groupMemberList andImageLink:imageLink channelType:(short)PUBLIC
                            andMetaData:groupMetaData adminUser:adminUserId withCompletion:^(NSError *error, ALChannelCreateResponse *response) {
                              
                              if(!error && response.alChannel)
                              {
                                response.alChannel.adminKey = [ALUserDefaultsHandler getUserId];
                                ALChannelDBService *channelDBService = [[ALChannelDBService alloc] init];
                                [channelDBService createChannel:response.alChannel];
                                return callback(@[[NSNull null],response.alChannel.key]);
                              }else if(response){
                                return callback(@[[NSNull null],[self getJsonString:response.response]]);
                              }
                              else
                              {
                                NSLog(@"ERROR_IN_CHANNEL_CREATING :: %@",error);
                               return callback(@[error.description,[NSNull null]]);

                              }
                            }];
  

}

RCT_EXPORT_METHOD(addMemberToGroup:(NSDictionary *)requestData andCallback:(RCTResponseSenderBlock)callback )
{
  
  ALChannelService * alChannelService = [ALChannelService new];
  
  NSNumber * groupId = [requestData valueForKey:@"groupId"];
  NSString * clientGroupId = [requestData valueForKey:@"clientGroupId"];
  NSString * userId = [requestData valueForKey:@"userId"];

  [alChannelService addMemberToChannel:userId
                         andChannelKey:groupId
                    orClientChannelKey:clientGroupId
                        withCompletion:^(NSError *error, ALAPIResponse *response) {
                          if(error){
                            NSLog(@"error description %@", error.description);
                            return callback(@[ error.description ,[NSNull null]]);
                          }else if([ response.status isEqualToString:RESPONSE_SUCCESS]){
                            return callback(@[ [NSNull null],[self getJsonString:response.actualresponse]]);
                          }else{
                            return callback(@[ [self getJsonString:response.actualresponse], [NSNull null]]);

                          }
    
  }];

}

RCT_EXPORT_METHOD(removeMemberFromGroup:(NSDictionary *)requestData andCallback:(RCTResponseSenderBlock)callback )
{
  
  ALChannelService * alChannelService = [ALChannelService new];
  
  NSNumber * groupId = [requestData valueForKey:@"groupId"];
  NSString * clientGroupId = [requestData valueForKey:@"clientGroupId"];
  NSString * userId = [requestData valueForKey:@"userId"];
  
  [alChannelService removeMemberFromChannel:userId
                              andChannelKey:groupId
                         orClientChannelKey:clientGroupId
                             withCompletion:^(NSError *error, ALAPIResponse *response) {
                               
                               if(error){
                                 NSLog(@"error description %@", error.description);
                                 return callback(@[ error.description ,[NSNull null]]);
                               }else{
                                 return callback(@[ [NSNull null],[self getJsonString:response.dictionary]]);
                               }
                               
                             }];
  
}

RCT_EXPORT_METHOD(removeMemberFromGroup:(NSDictionary *)requestData andCallback:(RCTResponseSenderBlock)callback )
{
  
  ALChannelService * alChannelService = [ALChannelService new];
  
  NSNumber * groupId = [requestData valueForKey:@"groupId"];
  NSString * clientGroupId = [requestData valueForKey:@"clientGroupId"];
  NSString * userId = [requestData valueForKey:@"userId"];
  
  [alChannelService removeMemberFromChannel:userId
                              andChannelKey:groupId
                         orClientChannelKey:clientGroupId
                             withCompletion:^(NSError *error, ALAPIResponse *response) {
                               
                               if(error){
                                 NSLog(@"error description %@", error.description);
                                 return callback(@[ error.description ,[NSNull null]]);
                               }else{
                                 return callback(@[ [NSNull null],[self getJsonString:response.dictionary]]);
                               }
                               
                             }];
  
}


//======================================Unreadcounts ==============================================


RCT_EXPORT_METHOD(getUnreadCountForUser:(NSString*)userId andCallback:(RCTResponseSenderBlock)callback )
{
  
  ALContactService* contactService = [ALContactService new];
  ALContact *contact = [contactService loadContactByKey:@"userId" value:userId];
  NSNumber *unreadCount = [contact unreadCount];
  return callback(@[[NSNull null], unreadCount]);
  
}

RCT_EXPORT_METHOD(getUnreadCountForChannel:(NSDictionary *)requestData andCallback:(RCTResponseSenderBlock)callback )
{
  
  ALChannelService *channelService = [ALChannelService new];
  NSNumber * groupId = [requestData valueForKey:@"groupId"];
  NSString * clientGroupId = [requestData valueForKey:@"clientGroupId"];
  
  if(clientGroupId){
    [channelService getChannelInformation:nil orClientChannelKey:clientGroupId withCompletion:^(ALChannel *alChannel) {
      
      if(alChannel){
        NSNumber *unreadCount = [alChannel unreadCount];
        return callback(@[[NSNull null], unreadCount]);
        
      }else{
        return callback(@[@"channel not found", [NSNull null] ]);
      }
      
    }] ;
    
  } else {
    
    ALChannel *alChannel = [channelService getChannelByKey:groupId];
    NSNumber *unreadCount = [alChannel unreadCount];
    return callback(@[[NSNull null], unreadCount]);
  }
}

RCT_EXPORT_METHOD(totalUnreadCount:(RCTResponseSenderBlock)callback )
{
  
  ALUserService * alUserService = [[ALUserService alloc] init];
  NSNumber * totalUnreadCount = [alUserService getTotalUnreadCount];
  return callback(@[[NSNull null], totalUnreadCount]);
  
}

//===================================== Log Out ===================================================
/**
 *  Logout users
 *
 */


RCT_EXPORT_METHOD(logoutUser:(RCTResponseSenderBlock)callback )
{
  ALRegisterUserClientService * alRegisterUserClientService = [[ALRegisterUserClientService alloc]init];
  
  [alRegisterUserClientService logoutWithCompletionHandler:^(ALAPIResponse *response, NSError *error) {
    if(error){
      
      NSString* errorResponse = error.description;
      return callback(@[errorResponse, [NSNull null]]);
      
    }else if (response ){
      
      return callback(@[[NSNull null],[self getJsonString:[response dictionary]]]);
      
    }
  }];
  
}




-(NSString *)getJsonString:(id) Object{

  NSError *error;
  NSString *jsonString;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:Object
                                                     options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                       error:&error];
  
  if (! jsonData) {
    
    NSLog(@"Got an error: %@", error);
    
  } else {
    
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
  }
  return jsonString;
}
                        

@end
