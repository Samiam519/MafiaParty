//
//  Player.m
//  MafiaParty
//
//  Created by Teresa Ibarra on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Player.h"
#import "Lobby.h"

@implementation Player
{
    // NSString *name;
    NSString *typeOfDeath;
    NSMutableArray *lynchStrings;
    NSMutableArray *murderStrings;
    NSMutableArray *saveStrings;
    NSNumber *me;
    
    // CCSprite *icon;
    Player *selectedPlayer;
}

- (void)dealloc{
    //empty method just in case
}

- (id)init
{
    // Initialize
    self = [super init];
    
    
    // If intialized,
    if (self){
        me = [Lobby sharedInstance].playerIndex;
        _alreadyPicked = FALSE;
        _role = @"Citizen";
        _numVotes = 0;
    }
    return self;
}

-(void)didLoadFromCCB
{
    //
    if ([_role isEqualToString:@"mafia"]) {
        _canKill = TRUE;
        _canSave = FALSE;
        _canSuspect = FALSE;
    }
    if ([_role isEqualToString:@"doctor"]) {
        _canKill = FALSE;
        _canSave = TRUE;
        _canSuspect = FALSE;
    }
    if ([_role isEqualToString:@"police"]) {
        _canKill = FALSE;
        _canSave = FALSE;
        _canSuspect = TRUE;
    }
    if ([_role isEqualToString:@"citizen"]) {
        _canKill = FALSE;
        _canSave = FALSE;
        _canSuspect = FALSE;
    }
    //
}

- (void)setMe:(NSString*)myName andMyPicture:(CCSprite*)myPicture
{
    // Set facebook name and picture for current user
    _FBname = myName;
    _icon = myPicture;
}

- (void)performNightAction: (Player*)actionWithPlayer
{
    //Add code for getting strings
    
    if ([_role isEqualToString:@"Mafia"]) {
        [self setDead:actionWithPlayer];
        // Kill player
    }
    else if ([_role isEqualToString:@"Doctor"]) {
        // Save player
        [self savePlayer:actionWithPlayer];
    }
    else if ([_role isEqualToString:@"Police"]) {
        // Suspect player
        [self suspectPlayer:actionWithPlayer];
    }
    else if ([_role isEqualToString:@"Citizen"]) {
        
    }
    _turnEnded = TRUE;
}

- (void)setDead: (Player*)player
{
    // Die
    player.isDead = true;
}

- (void)savePlayer: (Player*)player
{
    // Save
    player.isSaved = true;
}

- (void)suspectPlayer: (Player*)player
{
    //Suspect
    if ([player.role isEqualToString:@"mafia"]) {
        CCLOG(@"Player is mafia!");
    }
    else
    {
        CCLOG(@"Player is innocent");
    }
}

-(void)voteForPlayer:(Player *)chosenPlayer
{
    chosenPlayer.numVotes++;
    _hasVoted = true;
}

@end
