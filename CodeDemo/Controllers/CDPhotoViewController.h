//
//  CDPhotoViewController.h
//  CodeDemo
//
//  Created by Bob Reid on 10/31/2013.
//  Copyright (c) 2013 Bob Reid. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDPhotoDescription.h"
#import "CDPhotoHandle.h"

@class CDPhotoViewController;

@protocol CDPhotoViewControllerDelegate <NSObject>

- (BOOL)photoViewController:(CDPhotoViewController*)photoViewController shouldShowSaveButtonForPhoto:(CDPhotoDescription*)photo;
- (BOOL)photoViewController:(CDPhotoViewController*)photoViewController shouldShowDeleteButtonForPhoto:(CDPhotoDescription*)photo;
- (void)savePressedForPhotoViewController:(CDPhotoViewController*)photoViewController photo:(CDPhotoDescription*)photo;
- (void)deletePressedForPhotoViewController:(CDPhotoViewController*)photoViewController photo:(CDPhotoDescription*)photo;

@end

@interface CDPhotoViewController : UIViewController

@property (strong, nonatomic) CDPhotoDescription* photo;
@property (weak, nonatomic) id <CDPhotoViewControllerDelegate> delegate;

@end
