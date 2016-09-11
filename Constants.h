/*
 *  Constants.h
 *  GPS Body Paint
 *
 *  Created by François Lamboley on 7/17/09.
 *  Copyright 2009 VSO-Software. All rights reserved.
 *
 */

typedef enum VSOGameShapeType: NSUInteger {
	VSOGameShapeTypeSquare = 0,
	VSOGameShapeTypeHexagon,
	VSOGameShapeTypeTriangle
} VSOGameShapeType;

typedef enum VSOPlayingMode: NSUInteger {
	VSOPlayingModeFillIn = 0,
	VSOPlayingModeTimeLimit,
} VSOPlayingMode;

#define VSO_UDK_FIRST_LAUNCH @"First Launch"
#define VSO_UDK_GAME_SHAPE @"VSO Saved Game Shape"
#define VSO_UDK_LEVEL_PAINTING_SIZE @"VSO Level Painting Size"
#define VSO_UDK_LEVEL_SIZE @"VSO Level Size"
#define VSO_UDK_PLAYING_MODE @"VSO Playing Mode"
#define VSO_UDK_PLAYING_FILL_PERCENTAGE @"VSO Playing Mode Fill In - Chosen Percentage"
#define VSO_UDK_PLAYING_TIME @"VSO Playing Mode Time Limit - Time Chosen"
#define VSO_WARN_ON_MAP_LOADING_FAILURE @"VSO Warn On Map Loading Failure"

#define VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP 0.30
#define VSO_ANIM_TIME_SHOW_ARROWS 0.5
#define VSO_ANIM_TIME_HIDE_GETTING_LOC_MSG 0.65  /* More or less (more less than more) the animation time of the map animation */
#define VSO_ANIM_TIME_SHOW_GAME_OVER 0.75
#define VSO_TIME_BEFORE_SHOWING_GETTING_LOC_MSG 5

#define VSO_MAX_MAP_SPAN_FOR_PLAYGROUND 500 /* Meters */
