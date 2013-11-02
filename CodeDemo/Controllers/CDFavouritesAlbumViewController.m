    //
//  CDFavouritesAlbumViewController.m
//  CodeDemo
//
//  Created by Bob Reid on 10/30/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDFavouritesAlbumViewController.h"
#import "CDPhotoDescription.h"
#import "CDPhotoHandle.h"
#import "CDImageViewCell.h"
#import "UIKit+AFNetworking.h"
#import "CDPhotoViewController.h"
#import "CDFavouritePhotos.h"

@interface CDFavouritesAlbumViewController () <CDPhotoViewControllerDelegate>

//@property (strong, nonatomic) NSMutableArray* favourites;
@property (strong, nonatomic) CDFavouritePhotos* album;

@end

@implementation CDFavouritesAlbumViewController


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self.tabBarItem setTitle:NSLocalizedString(@"Album", @"Album tab bar title")];
        [self setAutomaticallyAdjustsScrollViewInsets:YES];
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
    
    [self.collectionView registerClass:[CDImageViewCell class] forCellWithReuseIdentifier:@"Image"];
    
    _album = [CDFavouritePhotos album];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumLoaded:) name:CDFavouritePhotosLoaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumUnloaded:) name:CDFavouritePhotosUnloaded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoAdded:) name:CDFavouritePhotoAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoRemoved:) name:CDFavouritePhotoRemoved object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoMoved:) name:CDFavouritePhotoRepositioned object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Favourites Observers

- (void)albumLoaded:(NSNotification*)notification
{
    [self.collectionView reloadData];
}

- (void)albumUnloaded:(NSNotification*)notification
{
    [self.collectionView reloadData];
}

- (void)photoAdded:(NSNotification*)notification
{
    NSIndexPath* path = [NSIndexPath indexPathForRow:self.album.count-1 inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[path]];
}

- (void)photoRemoved:(NSNotification*)notification
{
    NSUInteger fromIndex = [[notification.userInfo objectForKey:CDFavouritePhotoFromIndexKey] unsignedIntegerValue];
    NSIndexPath* path = [NSIndexPath indexPathForRow:fromIndex inSection:0];
    [self.collectionView deleteItemsAtIndexPaths:@[path]];
}

- (void)photoMoved:(NSNotification*)notification
{
    if([self.tabBarController selectedViewController] == self)
        return;
    
    [self.collectionView reloadData];
}


#pragma mark - CollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.album count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CDPhotoDescription* photo = [self.album photoAtIndex:indexPath.row];
    CDImageViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Image" forIndexPath:indexPath];

    [cell.imageView setImageWithURL:[NSURL URLWithString:photo.thumbnailHandle.url]];
    [cell setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CDPhotoDescription* photo = [self.album photoAtIndex:indexPath.row];
    
    CDPhotoViewController* vc = [[CDPhotoViewController alloc] init];
    [vc setPhoto:photo];
    [vc setDelegate:self];
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Layout Delegate

- (CGSize)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Add a random variation to the image sizes
    //This is a cheap trick to give the view a little visual diversity
    //The problem is that images will change size if the view is reloaded
    
    CGFloat baseDim = 75.0f / [[UIScreen mainScreen] scale];
    int variationFactor = (int)(50 / [[UIScreen mainScreen] scale]);
    
    CGFloat variation = (float)(rand()%variationFactor);
    return CGSizeMake(baseDim + variation, baseDim+ variation);
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

#pragma mark - PhotoViewController Delegate

- (BOOL)photoViewController:(CDPhotoViewController *)photoViewController shouldShowDeleteButtonForPhoto:(CDPhotoDescription *)photo
{
    return YES;
}

- (BOOL)photoViewController:(CDPhotoViewController *)photoViewController shouldShowSaveButtonForPhoto:(CDPhotoDescription *)photo
{
    return NO;
}

- (void)savePressedForPhotoViewController:(CDPhotoViewController *)photoViewController photo:(CDPhotoDescription *)photo
{
    
}

- (void)deletePressedForPhotoViewController:(CDPhotoViewController *)photoViewController photo:(CDPhotoDescription *)photo
{
    [self.album removeFavourite:photo];
    [self.navigationController popToViewController:self animated:YES];
}

@end
