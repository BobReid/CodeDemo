//
//  CDPhotoSearchController.m
//  CodeDemo
//
//  Created by Bob Reid on 10/30/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDPhotoSearchController.h"
#import "CDPhotoDescription.h"
#import "CDProgressIndicatorCell.h"
#import "CDLoadingIndicatorCell.h"
#import "CDPhotoHandle.h"
#import "UIKit+AFNetworking.h"
#import "CDAppDelegate.h"

@interface CDPhotoSearchController ()

@property (nonatomic) NSUInteger pageToSearch;
@property (strong, nonatomic) UIImage* placeholderImage;
@property (strong, nonatomic) NSMutableDictionary* inprogressDownloads;
@property (strong, nonatomic) NSIndexPath* lastDownload;
@property (nonatomic) BOOL searching;
@property (nonatomic) BOOL hasMoreResults;

@end

@implementation CDPhotoSearchController

- (id)initWithSearchDisplayController:(UISearchDisplayController *)searchDisplayController
{
    if(self = [super init])
    {
        _searchDisplayController = searchDisplayController;
        [self.searchDisplayController setDelegate:self];
        [self.searchDisplayController.searchBar setDelegate:self];
        [self.searchDisplayController setSearchResultsDataSource:self];
        [self.searchDisplayController setSearchResultsDelegate:self];

        _inprogressDownloads = [NSMutableDictionary dictionary];
        _searchResults = [NSMutableArray array];
        
        [self resetSearch];
        
        //I should really just have an image asset as a placeholder
        //This is an incode work around for that
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
        [view setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
        
        UIGraphicsBeginImageContext(view.bounds.size);
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

    }
    
    return self;
}

- (void)searchForBatch
{
    if([self searching])
        return;

    if(![self hasMoreResults])
        return;
    
    if([self.searchResults count] >= 300)
        return;

    [self.searchDisplayController.searchResultsTableView beginUpdates];
    [self.searchDisplayController.searchResultsTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.searchResults count] inSection:0]]
                                                               withRowAnimation:UITableViewRowAnimationAutomatic];
    [self setSearching:YES];
    [self.searchDisplayController.searchResultsTableView endUpdates];
    
    [CDPhotoDescription searchForPhotosWithTerm:self.searchDisplayController.searchBar.text page:self.pageToSearch++ completion:^(NSArray *photos, NSError *error) {
        
        [self setSearching:NO];
    
        if(error)
        {
            NSLog(@"Search Error: %@", error);
        }
        else
        {
            [self.searchResults addObjectsFromArray:photos];
            [self setHasMoreResults:[photos count] == 30];
        }
        
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

- (void)resetSearch
{
    [self.inprogressDownloads removeAllObjects];
    [self setLastDownload:nil];
    [self setPageToSearch:1];
    [self setSearching:NO];
    [self setHasMoreResults:YES];
    
    if([self.searchResults count] > 0)
    {
        [self.searchResults removeAllObjects];
        [self.searchDisplayController.searchResultsTableView reloadData];
    }
}

#pragma mark - Search Bar Delegate


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self resetSearch];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if([searchBar.text isEqualToString:@""])
        return;
    
    [self searchForBatch];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self searching])
        return [self.searchResults count] + 1;
    
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Progress";
    static NSString *LoadingIdentifier = @"Loading";
    
    if(indexPath.row == [self.searchResults count])
    {
        CDLoadingIndicatorCell* cell = [tableView dequeueReusableCellWithIdentifier:LoadingIdentifier];
        [cell.activityIndicator startAnimating];
        return cell;
    }

    CDPhotoDescription* photo = [self.searchResults objectAtIndex:indexPath.row];
    CDProgressIndicatorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.textLabel setText:photo.title];
    [cell.imageView setImageWithURL:[NSURL URLWithString:photo.thumbnailHandle.url] placeholderImage:self.placeholderImage];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if([self.inprogressDownloads objectForKey:indexPath])
    {
        NSURLSessionDownloadTask* task = [self.inprogressDownloads objectForKey:indexPath];
        [cell.progressView setHidden:NO];
        [cell.progressView setProgressWithDownloadProgressOfTask:task animated:YES];
    }
    else
    {
        [cell.progressView setHidden:YES];
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)downloadFileForIndexPath:(NSIndexPath*)indexPath
{
    CDPhotoDescription* photo = [self.searchResults objectAtIndex:indexPath.row];
    CDPhotoHandle* handle = [photo largestHandle];
    
    NSURLSessionDownloadTask* task = [handle downloadTaskForPhoto:^(NSError *error) {
        
        [self.inprogressDownloads removeObjectForKey:indexPath];
    
        if([self.lastDownload isEqual:indexPath])
            [self setLastDownload:nil];
            
        [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if(!error)
            [self.delegate photoSearchController:self didSelectPhoto:photo];
        
    }];
    
    [UIAlertView showAlertViewForTaskWithErrorOnCompletion:task delegate:nil];
    [self.inprogressDownloads setObject:task forKey:indexPath];
    [self setLastDownload:indexPath];
    
    CDProgressIndicatorCell* cell = (CDProgressIndicatorCell*)[self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
    [cell.progressView setHidden:NO];
    [cell.progressView setProgressWithDownloadProgressOfTask:task animated:YES];
    [task resume];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDPhotoDescription* photo = [self.searchResults objectAtIndex:indexPath.row];
    CDPhotoHandle* handle = [photo largestHandle];
    
    if([handle filePath])
    {
        [self.delegate photoSearchController:self didSelectPhoto:photo];
        return;
    }

    [self downloadFileForIndexPath:indexPath];
    
    return;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![self hasMoreResults])
        return;
    
    if([self.searchDisplayController.searchBar isFirstResponder])
        return;
    
    CGFloat loadPoint = scrollView.contentSize.height - scrollView.bounds.size.height - scrollView.contentInset.top - 150;
    if(scrollView.contentOffset.y > loadPoint)
    {
        [self searchForBatch];
    }
}

#pragma mark - UISearchDisplayController Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    [tableView registerClass:[CDProgressIndicatorCell class] forCellReuseIdentifier:@"Progress"];
    [tableView registerClass:[CDLoadingIndicatorCell class] forCellReuseIdentifier:@"Loading"];
}

@end
