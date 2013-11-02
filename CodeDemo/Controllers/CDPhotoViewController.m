//
//  CDPhotoViewController.m
//  CodeDemo
//
//  Created by Bob Reid on 10/31/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import "CDPhotoViewController.h"
#import "CDZoomView.h"

@interface CDPhotoViewController () <UIScrollViewDelegate, UIPopoverControllerDelegate>


@property (strong, nonatomic) UIImageView* imageView;
@property (strong, nonatomic, readonly) CDZoomView* zoomView;
@property (strong, nonatomic) UIPopoverController* popover;
@property (strong, nonatomic) UIBarButtonItem* save;
@property (strong, nonatomic) UIBarButtonItem* delete;

@end

@implementation CDPhotoViewController


- (void)loadView
{
    CDZoomView* zoomView = [[CDZoomView alloc] initWithFrame:CGRectZero];
    [zoomView setBackgroundColor:[UIColor blackColor]];
    [zoomView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self setView:zoomView];
}

- (CDZoomView*)zoomView
{
    return (CDZoomView*)[self view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                           target:self
                                                                           action:@selector(sharePressed:)];
    [self.navigationItem setRightBarButtonItem:share];
    [self setHidesBottomBarWhenPushed:YES];
    
    self.save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                              target:self
                                                              action:@selector(savePressed:)];
    
    self.delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                target:self
                                                                action:@selector(deletePressed:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![self photo])
        return;
    
    NSMutableArray* items = [NSMutableArray array];
    [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];

    if([self.delegate photoViewController:self shouldShowSaveButtonForPhoto:self.photo])
    {
        [self.save setEnabled:YES];
        [items addObject:self.save];
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }
    
    if([self.delegate photoViewController:self shouldShowDeleteButtonForPhoto:self.photo])
    {
        [items addObject:self.delete];
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    }
    
    if([items count] > 1)
    {
        [self setToolbarItems:items];
        [self.navigationController setToolbarHidden:NO];
    }
    else
    {
        [self.navigationController setToolbarHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setPhoto:(CDPhotoDescription *)photo
{
    [self willChangeValueForKey:@"photo"];
    _photo = photo;
    [self didChangeValueForKey:@"photo"];
    
    [self setTitle:photo.title];
    [self loadPhoto];
}


- (void)loadPhoto
{
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.photo.largestHandle.filePath]];
    UIImage* image = [UIImage imageWithData:data];
    
    self.imageView = [[UIImageView alloc] initWithImage:image];
    [self.zoomView setViewToZoom:self.imageView];
}

- (void)sharePressed:(id)sender
{
    UIActivityViewController* vc = [[UIActivityViewController alloc] initWithActivityItems:@[ [NSURL URLWithString:self.photo.largestHandle.filePath] ] applicationActivities:nil];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [self.popover setDelegate:self];
        [self.popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else
    {
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)savePressed:(id)sender
{
    [self.delegate savePressedForPhotoViewController:self photo:self.photo];
    [self.save setEnabled:NO];
}

- (void)deletePressed:(id)sender
{
    [self.delegate deletePressedForPhotoViewController:self photo:self.photo];
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self setPopover:nil];
}


@end
