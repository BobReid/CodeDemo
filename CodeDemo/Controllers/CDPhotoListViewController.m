//
//  CDPhotoListViewController.m
//  CodeDemo
//
//  Created by Bob Reid on 10/24/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDPhotoListViewController.h"
#import "UIKit+AFNetworking.h"
#import <CoreGraphics/CoreGraphics.h>
#import "CDFlickrObjectContext.h"
#import "CDAppDelegate.h"
#import "NSManagedObjectContext+Async.h"
#import "CDPhotoDescription.h"
#import "CDPhotoHandle.h"
#import "CDProgressIndicatorCell.h"
#import "CDPhotoSearchController.h"
#import "CDPhotoViewController.h"
#import "CDFavouritePhotos.h"

@interface CDPhotoListViewController () <CDPhotoSearchControllerDelegate, UIDocumentInteractionControllerDelegate, CDPhotoViewControllerDelegate>

//@property (strong, nonatomic) NSMutableArray* favourites;
@property (strong, nonatomic) CDFavouritePhotos* album;
@property (strong, nonatomic) CDPhotoSearchController* photoSearchController;
@property (strong, nonatomic) UIImage* placeholderImage;

@end

@implementation CDPhotoListViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self.navigationItem setTitle:NSLocalizedString(@"Favourites", @"Favourites title")];
        [self.tabBarItem setTitle:NSLocalizedString(@"Photos", @"Photos Tab Title")];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _album = [CDFavouritePhotos album];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumLoaded:) name:CDFavouritePhotosLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUnloaded:) name:CDFavouritePhotosUnloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoAdded:) name:CDFavouritePhotoAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoRemoved:) name:CDFavouritePhotoRemoved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoMoved:) name:CDFavouritePhotoRepositioned object:nil];
    
    _photoSearchController = [[CDPhotoSearchController alloc] initWithSearchDisplayController:self.searchDisplayController];
    [self.photoSearchController setDelegate:self];
    
    [self.tableView registerClass:[CDProgressIndicatorCell class] forCellReuseIdentifier:@"Progress"];
    
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    [editButton setPossibleTitles:[NSSet setWithObjects:NSLocalizedString(@"Edit", @"Edit button"),
                                                        NSLocalizedString(@"Done", @"Done button"), nil]];
    [self.navigationItem setRightBarButtonItem:editButton];
    
    
    
    //I should really just have an image asset as a placeholder
    //This is an incode work around for that
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 75)];
    [view setBackgroundColor:[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.0f]];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.placeholderImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.photoSearchController.searchResults removeAllObjects];
}

- (void)showPhoto:(CDPhotoDescription*)photo
{
    CDPhotoViewController* vc = [[CDPhotoViewController alloc] init];
    [vc setDelegate:self];
    [vc setPhoto:photo];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Favourites Observers

- (void)albumLoaded:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)albumUnloaded:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)photoAdded:(NSNotification*)notification
{
    [self.tableView reloadData];
}

- (void)photoRemoved:(NSNotification*)notification
{
    NSUInteger fromIndex = [[notification.userInfo objectForKey:CDFavouritePhotoFromIndexKey] unsignedIntegerValue];
    NSIndexPath* path = [NSIndexPath indexPathForRow:fromIndex inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)photoMoved:(NSNotification*)notification
{
    if([self.tabBarController selectedViewController] == self)
        return;
    
    [self.tableView reloadData];
}

#pragma mark - UIActions

- (void)editPressed:(id)sender
{
    if([self.tableView isEditing])
    {
        [UIView animateWithDuration:0.2f animations:^{
            [self.tableView setEditing:NO];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2f animations:^{
            [self.tableView setEditing:YES];
        }];
    }
}

#pragma mark - Photo View Controller Delegate

- (BOOL)photoViewController:(CDPhotoViewController *)photoViewController shouldShowSaveButtonForPhoto:(CDPhotoDescription *)photo
{
    return ![self.album isInFavourites:photo];
}

- (void)savePressedForPhotoViewController:(CDPhotoViewController *)photoViewController photo:(CDPhotoDescription *)photo
{
    CDPhotoDescription* savedPhoto = [self.album addFavourite:photo];
    
    if(savedPhoto)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Save Complete", @"Save complete message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Label") otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Error During Save", @"Save failed message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"OK Button Label") otherButtonTitles:nil];
        [alert show];
        return;
    }
    
}

- (BOOL)photoViewController:(CDPhotoViewController *)photoViewController shouldShowDeleteButtonForPhoto:(CDPhotoDescription *)photo
{
    return [self.album isInFavourites:photo];
}

- (void)deletePressedForPhotoViewController:(CDPhotoViewController *)photoViewController photo:(CDPhotoDescription *)photo
{
    [self.album removeFavourite:photo];
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([self.album count] == 0)
        return 1;
    
    return [self.album count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    if([self.album count] == 0)
    {
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [cell.textLabel setText:NSLocalizedString(@"Add photos by searching Flickr", @"Add photos message")];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell.imageView setImage:nil];
        
        return cell;
    }
    
    CDPhotoDescription* photo = [self.album photoAtIndex:indexPath.row];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.textLabel setText:photo.title];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    [[cell.imageView imageResponseSerializer] setImageScale:1.0f];
    [cell.imageView setImageWithURL:[NSURL URLWithString:photo.thumbnailHandle.url] placeholderImage:self.placeholderImage];
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDPhotoDescription* photo = [self.album photoAtIndex:indexPath.row];
    [self showPhoto:photo];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [self.album moveFavouriteFromIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self.album removeFavouriteAtIndex:indexPath.row];
    }
}

#pragma mark - CDPhotoSearchController Delegate

- (void)photoSearchController:(CDPhotoSearchController *)photoSearchController didSelectPhoto:(CDPhotoDescription *)photo
{
    [self showPhoto:photo];
}

                                      
@end
