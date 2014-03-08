//
//  AZRGUIConstants.h
//  Realmz
//
//  Created by Ankh on 28.02.14.
//  Copyright (c) 2014 Ankh. All rights reserved.
//

#ifndef Realmz_AZRGUIConstants_h
#define Realmz_AZRGUIConstants_h

#define DESIGNED_FOR_RESOLUTION 768.f
#define ZINDEX_GUICOMMON 101000
#define ZINDEX_SELECTION 100000
#define ZINDEX_GUITOPLAYER 102000
#define ACTIONS_OUTSET 12.f
#define ACTIONS_IN_COLLUMN 3
#define GUI_MARGIN 16.f

static inline float scaleToFit(CGSize size, CGSize constraint, float partial) {
	size.width /= constraint.width;
	size.height /= constraint.height;
	return partial / MIN(size.width, size.height);
}

#endif
