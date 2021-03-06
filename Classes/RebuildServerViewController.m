//
//  RebuildServerViewController.m
//  RackspaceCloud
//
//  Created by Michael Mayo on 2/9/10.
//  Copyright Rackspace Hosting 2010. All rights reserved.
//

#import "RebuildServerViewController.h"
#import "ASICloudServersImage.h"
#import "ASICloudServersImageRequest.h"
#import "ASICloudServersServer.h"
#import "ASICloudServersServerRequest.h"
#import "ServerDetailViewController.h"
#import "UIViewController+SpinnerView.h"


@implementation RebuildServerViewController

@synthesize serverDetailViewController;

#pragma mark -
#pragma mark HTTP Response Handlers

-(void)rebuildRequestFinished:(ASICloudServersServerRequest *)request {
	[self hideSpinnerView];
	if ([request isSuccess]) {
		[self.serverDetailViewController loadServer];
		[self dismissModalViewControllerAnimated:YES];
	} else {
		[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"rebuilding your server"];
	}
}

-(void)rebuildRequestFailed:(ASICloudServersServerRequest *)request {
	[self alertForCloudServersResponseStatusCode:[request responseStatusCode] behavior:@"rebuilding your server"];
}


#pragma mark -
#pragma mark Button Handlers

-(void)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

-(void)saveButtonPressed:(id)sender {
	[self showSpinnerView];	
	ASICloudServersServerRequest *request = [ASICloudServersServerRequest rebuildServerRequest:self.serverDetailViewController.server.serverId imageId:selectedImageId];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(rebuildRequestFinished:)];
	[request setDidFailSelector:@selector(rebuildRequestFailed:)];
	[request startAsynchronous];	
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	selectedImageId = self.serverDetailViewController.server.imageId;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 0;
	} else {
		return [[ASICloudServersImageRequest images] count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return @"Choose an Image";
	} else {
		return @"";
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 0) {
		return @"Rebuilding this Cloud Server will destroy all data and reinstall the image you select.";
	} else {
		return @"";
	}	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
	cell.textLabel.text = image.name;
	cell.detailTextLabel.text = @"";
    cell.imageView.image = [ASICloudServersImage iconForImageId:image.imageId];
	
	if (selectedImageId == image.imageId) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ASICloudServersImage *image = [[ASICloudServersImageRequest images] objectAtIndex:indexPath.row];
	selectedImageId = image.imageId;
	[tableView reloadData];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[serverDetailViewController release];
    [super dealloc];
}


@end

