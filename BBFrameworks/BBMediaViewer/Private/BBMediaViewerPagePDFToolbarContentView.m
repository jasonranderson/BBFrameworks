//
//  BBMediaViewerPagePDFToolbarContentView.m
//  BBFrameworks
//
//  Created by William Towe on 3/1/16.
//  Copyright © 2016 Bion Bilateral, LLC. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "BBMediaViewerPagePDFToolbarContentView.h"
#import "BBMediaViewerPagePDFModel.h"
#import "BBMediaViewerPagePDFCollectionViewCell.h"
#import "BBFrameworksMacros.h"
#import "BBFrameworksFunctions.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface BBMediaViewerPagePDFToolbarContentView () <UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong,nonatomic) UILabel *selectedPageLabel;
@property (strong,nonatomic) UICollectionView *collectionView;

@property (strong,nonatomic) BBMediaViewerPagePDFModel *model;
@end

@implementation BBMediaViewerPagePDFToolbarContentView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.numberOfPages;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBMediaViewerPagePDFCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([BBMediaViewerPagePDFCollectionViewCell class]) forIndexPath:indexPath];
    
    [cell setModel:[self.model pagePDFDetailForPage:indexPath.item]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BBMediaViewerPagePDFCollectionViewCell *cell = (BBMediaViewerPagePDFCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self.model selectPagePDFDetail:cell.model];
}

- (instancetype)initWithModel:(BBMediaViewerPagePDFModel *)model; {
    if (!(self = [super initWithFrame:CGRectZero]))
        return nil;
    
    NSParameterAssert(model);
    
    _model = model;
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setMinimumInteritemSpacing:8.0];
    [layout setSectionInset:UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)];
    [layout setItemSize:_model.thumbnailSize];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView registerClass:[BBMediaViewerPagePDFCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([BBMediaViewerPagePDFCollectionViewCell class])];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [self addSubview:_collectionView];
    
    _selectedPageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_selectedPageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_selectedPageLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self addSubview:_selectedPageLabel];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[view]" options:0 metrics:nil views:@{@"view": _selectedPageLabel}]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_selectedPageLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view": _collectionView}]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label][view(height)]|" options:0 metrics:@{@"height": @(layout.sectionInset.top + _model.thumbnailSize.height + layout.sectionInset.bottom)} views:@{@"view": _collectionView, @"label": _selectedPageLabel}]];
    
    BBWeakify(self);
    
    RACSignal *numberOfPagesSignal =
    RACObserve(self.model, numberOfPages);
    RACSignal *selectedPageSignal =
    RACObserve(self.model, selectedPage);
    
    RAC(self.selectedPageLabel,text) =
    [[RACSignal combineLatest:@[numberOfPagesSignal,selectedPageSignal] reduce:^id(NSNumber *numberOfPages, NSNumber *selectedPage){
        if (numberOfPages.longValue == 0) {
            return [[[NSNumberFormatter alloc] init] nilSymbol];
        }
        else {
            return [NSString stringWithFormat:NSLocalizedStringWithDefaultValue(@"MEDIA_VIEWER_PDF_SELECTED_PAGE_LABEL_FORMAT", @"MediaViewer", BBFrameworksResourcesBundle(), @"%@ of %@", @"media viewer pdf selected page label format"),[NSNumberFormatter localizedStringFromNumber:@(selectedPage.longValue + 1) numberStyle:NSNumberFormatterDecimalStyle],[NSNumberFormatter localizedStringFromNumber:numberOfPages numberStyle:NSNumberFormatterDecimalStyle]];
        }
    }]
     deliverOnMainThread];
    
    [[[[[RACSignal combineLatest:@[numberOfPagesSignal,selectedPageSignal]]
       filter:^BOOL(RACTuple *value) {
           return [value.first longValue] > 0;
       }]
       reduceEach:^id(NSNumber *numberOfPages, NSNumber *selectedPage){
           return selectedPage;
       }]
     deliverOnMainThread]
     subscribeNext:^(NSNumber *value) {
         BBStrongify(self);
         NSIndexPath *indexPath = [NSIndexPath indexPathForItem:value.integerValue inSection:0];
         CGRect frame = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath].frame;
         
         if (!CGRectContainsRect(self.collectionView.frame, frame)) {
             [self.collectionView scrollRectToVisible:frame animated:NO];
         }
         [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
     }];
    
    [[numberOfPagesSignal
     deliverOnMainThread]
     subscribeNext:^(id _) {
         BBStrongify(self);
         [self.collectionView reloadData];
     }];
    
    return self;
}

@end
