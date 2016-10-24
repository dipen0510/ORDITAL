//
//  AuditImageCollectionViewCell.m
//  Ordital
//
//  Created by Dipen Sekhsaria on 07/09/15.
//  Copyright (c) 2015 Home. All rights reserved.
//

#import "AuditImageCollectionViewCell.h"

@implementation AuditImageCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        NSString *cellNibName = @"AuditImageCollectionViewCell";
        NSArray *resultantNibs = [[NSBundle mainBundle] loadNibNamed:cellNibName owner:nil options:nil];
        
        if ([resultantNibs count] < 1) {
            return nil;
        }
        
        if (![[resultantNibs objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        self = [resultantNibs objectAtIndex:0];
    }
    
    return self;    
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // reset image property of imageView for reuse
    self.imgView.image = nil;
    
    // update frame position of subviews
    self.imgView.frame = self.contentView.bounds;
}

@end
