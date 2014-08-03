//
//  RoleSelection.m
//  MafiaParty
//
//  Created by Samantha Jimenez on 8/2/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "RoleSelection.h"

@implementation RoleSelection
{
    CCLabelTTF *_jobDescription;
    CCLabelTTF *_roleDisplay;
    
    CCNode *_mafiaNode;
    CCNode *_playerNode;
    CCLabelTTF *_roleLabel;
    CCLabelTTF *_RoleTaskLabel;
    
    CCTextField *_noun1TextField;
    CCTextField *_noun2TextField;
    CCTextField *_verb1TextField;
    CCTextField *_verb2TextField;
    CCTextField *_adjective1TextField;
    CCTextField *_adjective2TextField;
}

-(void)mafiaChat{
    
}

-(void)next{
    CCScene *results = [CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

@end
