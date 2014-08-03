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
    
    UITextField *_noun1TextField;
    UITextField *_noun2TextField;
    UITextField *_verb1TextField;
    UITextField *_verb2TextField;
    UITextField *_adjective1TextField;
    UITextField *_adjective2TextField;
}

-(void)mafiaChat{
    
}

-(void)next{
    CCScene *results = [CCBReader loadAsScene:@"Results"];
    [[CCDirector sharedDirector] replaceScene:results];
}

@end
