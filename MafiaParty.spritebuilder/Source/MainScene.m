//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"

@implementation MainScene{
    Firebase *_myRootRef;
    FirebaseSimpleLogin *_authClient;
    Firebase *_authRef;
}

-(void)didLoadFromCCB{
    _myRootRef = [[Firebase alloc] initWithUrl:@"https://mafiagame.firebaseio.com/"];
    _authClient = [[FirebaseSimpleLogin alloc] initWithRef:_myRootRef];
    
    
}

-(void)onEnter{
    [super onEnter];
    [_authClient checkAuthStatusWithBlock:^(NSError* error, FAUser* user) {
        if (error != nil) {
            // an error occurred while attempting login
            NSLog(@"%@", error);
        } else if (user == nil) {
            // No user is logged in
        } else {
            // user authenticated with Firebase
            NSLog(@"%@", user);
        }
    }];
}
-(void)startGame
{
    
}

-(void)logInWithFacebook{
    [_authClient loginToFacebookAppWithId:@"750925491636225" permissions:@[@"email"]
                                audience:ACFacebookAudienceOnlyMe
                     withCompletionBlock:^(NSError *error, FAUser *user) {
                         
                         if (error != nil) {
                             // There was an error logging in
                         } else {
                             // We have a logged in Facebook user
                         }
                     }];
    _authRef = [_myRootRef.root childByAppendingPath:@".info/authenticated"];
    [_authRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot* snapshot) {
        BOOL isAuthenticated = [snapshot.value boolValue];
    }];
}

-(void) toTheLobby {
    CCScene *lobby = [CCBReader loadAsScene:@"Lobby"];
    [[CCDirector sharedDirector] replaceScene:lobby];
}

@end
