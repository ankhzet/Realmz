//
//  AZRRealmRenderer.h
//  Realmz
//
//  Created by Ankh on 08.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

@class AZRRealm, AZRObject;

@protocol AZRRealmRendererControlDelegate <NSObject>

- (void) rightClicked:(NSArray *)underClickObjects atCoordinates:(CGPoint)coordinates;

@end

@interface AZRRealmRenderer : UIView

@property (nonatomic) NSMutableArray *selection;
@property (nonatomic) id<AZRRealmRendererControlDelegate> delegate;

- (void) attachToRealm:(AZRRealm *)realm;

@end
