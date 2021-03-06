//
//  HandItem.m
//  Handoff
//
//  Created by Zac White on 4/17/10.
//  Copyright 2010 Gravity Mobile. All rights reserved.
//

#import "HOItem.h"

#import "Base64.h"

NSString *const HOItemPropertyKeyCommand = @"command";
NSString *const HOItemPropertyKeyTitle = @"title";
NSString *const HOItemPropertyKeyDescription = @"description";
NSString *const HOItemPropertyKeyIconData = @"icon";

NSString *const HOItemCommandTypeSong = @"song";
NSString *const HOItemCommandTypeWebpage = @"webpage";
NSString *const HOItemCommandTypeClipboard = @"clipboard";
NSString *const HOItemCommandTypeDocument = @"document";

@implementation HOItem

@synthesize command, itemIconData, itemTitle, itemDescription, properties, body;

- (id)initWithBLIPRequest:(BLIPRequest *)message
{
	if (!(self = [super init])) return nil;
	
	BLIPProperties *props = [message properties];
	
	self.body = message.body;
	
	self.command = [props valueOfProperty:HOItemPropertyKeyCommand];
	
	NSString *iconDataString = [props valueOfProperty:HOItemPropertyKeyIconData];
	NSData *decodedData = [Base64 decode:iconDataString];
	self.itemIconData = decodedData;
	
	self.itemTitle = [props valueOfProperty:HOItemPropertyKeyTitle];
	self.itemDescription = [props valueOfProperty:HOItemPropertyKeyDescription];
	
	NSMutableDictionary *restOfProperties = [[NSMutableDictionary alloc] initWithDictionary:[props allProperties]];
	
	[restOfProperties removeObjectsForKeys:[NSArray arrayWithObjects:HOItemPropertyKeyCommand,
											HOItemPropertyKeyTitle,
											HOItemPropertyKeyDescription,
											HOItemPropertyKeyIconData,
											nil]];
	
	self.properties = restOfProperties;
	
	return self;
}

+ (NSArray *)itemsWithBLIPRequest:(BLIPRequest *)request {
	
	NSMutableArray *allItems = [[NSMutableArray alloc] init];
	
	NSDictionary *props = [[request properties] allProperties];
	NSArray *propKeys = [props allKeys];
	int tabCounter = 1;
	for (int i = 0; i < [propKeys count]; i++) {
		if ([[propKeys objectAtIndex:i] rangeOfString:@"actionURL"].location != NSNotFound) {
			if ([[propKeys objectAtIndex:i] length] == 9) continue;
			HOItem *newItem = [[HOItem alloc] init];
			newItem.command = HOItemCommandTypeWebpage;
			newItem.itemTitle = [NSString stringWithFormat:@"Tab %d", tabCounter];
			newItem.itemDescription = [props objectForKey:[propKeys objectAtIndex:i]];
			newItem.properties = [NSDictionary dictionaryWithObject:newItem.itemDescription forKey:@"actionURL"];
			
			[allItems addObject:newItem];
			[newItem release];
			tabCounter++;
		}
	}
	return [allItems autorelease];
}

- (BLIPRequest *)blipRequest {
	
	NSMutableDictionary *requestProperties = [NSMutableDictionary dictionary];
	if (self.command) [requestProperties setObject:self.command forKey:HOItemPropertyKeyCommand];
	if (self.itemTitle) [requestProperties setObject:self.itemTitle forKey:HOItemPropertyKeyTitle];
	if (self.itemDescription) [requestProperties setObject:self.itemDescription forKey:HOItemPropertyKeyDescription];
	
	NSString *iconString = [Base64 encode:self.itemIconData];
	if (self.itemIconData) [requestProperties setObject:iconString forKey:HOItemPropertyKeyIconData];
	
	if (self.properties) [requestProperties addEntriesFromDictionary:self.properties];
		
	BLIPRequest *message = [BLIPRequest requestWithBody:self.body properties:requestProperties];
	
	return message;
}

- (void)dealloc {
	
	self.command = nil;
	self.itemIconData = nil;
	self.itemTitle = nil;
	self.itemDescription = nil;
	self.properties = nil;
	self.body = nil;
	
	[super dealloc];
}

@end
