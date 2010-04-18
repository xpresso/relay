//
//  HONetwork.m
//  Handoff
//
//  Created by Barry Burton on 4/17/10.
//  Copyright 2010 Gravity Mobile. All rights reserved.
//

#import "HONetwork.h"
#import "BLIP.h"


@implementation HONetwork

@synthesize string, delegate;

- (id) initWithDelegate:(id <HONetworkDelegate>)theDelegate
{
	self = [super init];
    if (self != nil) {
		self.string = @"Opening listener socket...";
		
		_listener = [[BLIPListener alloc] initWithPort: 12345];
		_listener.delegate = self;
		_listener.pickAvailablePort = YES;
		_listener.bonjourServiceType = @"_blipecho._tcp";
		[_listener open];
		
		self.delegate = theDelegate;
	}
	return self;
}

- (BOOL) sendMessage:(NSString*)message {

	[_listener ];
	return YES;
}

#pragma mark BLIP Listener Delegate:


- (void) listenerDidOpen: (TCPListener*)listener
{
    self.string = [NSString stringWithFormat: @"Listening on port %i",listener.port];
}

- (void) listener: (TCPListener*)listener failedToOpen: (NSError*)error
{
    self.string = [NSString stringWithFormat: @"Failed to open listener on port %i: %@",
                  listener.port,error];
}

- (void) listener: (TCPListener*)listener didAcceptConnection: (TCPConnection*)connection
{
    self.string = [NSString stringWithFormat: @"Accepted connection from %@",
                  connection.address];
    connection.delegate = self;
}

- (void) connection: (TCPConnection*)connection failedToOpen: (NSError*)error
{
    self.string = [NSString stringWithFormat: @"Failed to open connection from %@: %@",
                  connection.address,error];
}

- (BOOL) connection: (BLIPConnection*)connection receivedRequest: (BLIPRequest*)request
{
    NSString *message = [[NSString alloc] initWithData: request.body encoding: NSUTF8StringEncoding];
    self.string = [NSString stringWithFormat: @"Echoed:\n“%@”",message];
	if ( self.delegate ) {
		[self.delegate messageReceived: self.string];
	}
    [request respondWithData: request.body contentType: request.contentType];
	[message release];
	return YES;
}

- (void) connectionDidClose: (TCPConnection*)connection;
{
    self.string = [NSString stringWithFormat: @"Connection closed from %@",
                  connection.address];
}

@end
