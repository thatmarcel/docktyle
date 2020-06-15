#import <Cephei/HBPreferences.h>
#import <UIKit/UIKit.h>

@interface SparkColourPickerUtils : NSObject
    +(NSString*) hexStringFromColour:(UIColor*) colour;
    +(NSString*) rgbStringFromColour:(UIColor*) colour;
    +(UIColor*) inverseColour:(UIColor*) colour;
    +(UIColor*) colour:(UIColor*) colour withBrightness:(float) newBrightness;
    +(BOOL) colourIsBlack:(UIColor*) colour;
    +(BOOL) colourIsWhite:(UIColor*) colour;
    +(UIColor*) colourWithString: (NSString*) colourString;
    +(UIColor *)colourWithString:(NSString *)stringToConvert withFallback:(NSString*) fallback;
    +(UIColor *)colourWithString:(NSString *)stringToConvert withFallbackColour:(UIColor*) fallback;
    +(UIColor*) colourWithRGBString:(NSString*) stringToConvert;
    +(UIColor *) colourWithHexString:(NSString *)stringToConvert;
    +(BOOL) colourIsLight :(UIColor*) colour;   
    +(UIColor*)interpolateFrom:(UIColor*)startColour toColour:(UIColor*)endColour withPercentage:(float)percentage;
@end

@interface CALayerDelegate : NSObject
@end

@interface MTMaterialLayer
    -(void)setBlurEnabled:(BOOL)arg1;
    -(void)setHidden:(BOOL)arg1;
    -(void)setMasksToBounds:(BOOL)arg1;
    @property (assign) double cornerRadius;
@end

@interface MTMaterialView : UIView
    -(void)setRecipe:(NSInteger)arg1;

    @property (getter=_materialLayer,nonatomic,readonly) MTMaterialLayer * materialLayer; 
@end

@interface SBDockView : UIView
    @property (nonatomic,retain) MTMaterialView * backgroundView; 
@end

@interface SBFloatingDockPlatterView : UIView
@end

@interface SBFloatingDockView : UIView
    @property (nonatomic,retain) MTMaterialView * backgroundView; 
    @property (nonatomic,retain) SBFloatingDockPlatterView * mainPlatterView; 
@end

@interface SBIconListPageControl : UIView
@end

CAGradientLayer *gradient = [CAGradientLayer layer];
BOOL layerAdded  = NO;
BOOL layerAddedFloating  = NO;

NSInteger layoutCount = 0;
NSInteger layoutCountFloating = 0;

// Hide page control
%hook SBIconListPageControl

- (void) layoutSubviews {
    %orig;

    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.docktyle.hbprefs"];
    [preferences registerDefaults:@{
        @"style": @1,
        @"iosblurenabled": @YES,
        @"enabled": @YES,
        @"styletype": @0,
        @"alpha": @1.0,
        @"hidepagedots": @NO
	}];

    if ([preferences boolForKey:@"hidepagedots"] == YES) {
        [self setHidden:YES];
    }
}

-(void) setHidden:(BOOL)arg1 {
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.docktyle.hbprefs"];
    [preferences registerDefaults:@{
        @"style": @1,
        @"iosblurenabled": @YES,
        @"enabled": @YES,
        @"styletype": @0,
        @"alpha": @1.0,
        @"hidepagedots": @NO
	}];

    if ([preferences boolForKey:@"hidepagedots"] == NO) {
        %orig(arg1);
        return;
    }

    %orig(YES);
}

%end

%hook MTMaterialView

-(void)setAlpha:(double)arg1 {
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.docktyle.hbprefs"];
    [preferences registerDefaults:@{
        @"style": @1,
        @"iosblurenabled": @YES,
        @"enabled": @YES,
        @"styletype": @0,
        @"alpha": @1.0
	}];
    if ([self.superview isKindOfClass:%c(SBDockView)] || [self.superview isKindOfClass:%c(SBFloatingDockView)]) {
        %orig([preferences doubleForKey:@"alpha"]);
    } else {
        %orig(arg1);
    }
}

%end

%hook SBFloatingDockView

- (void) layoutSubviews {
    %orig;

    if (self.backgroundView == NULL || self.backgroundView.layer == NULL) {
        return;
    }

    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.docktyle.hbprefs"];
    [preferences registerDefaults:@{
        @"style": @1,
        @"iosblurenabled": @YES,
        @"enabled": @YES,
        @"styletype": @0,
        @"alpha": @1.0
	}];

    if ([preferences boolForKey:@"enabled"] == NO) {
        return;
    }

    if ([preferences integerForKey:@"styletype"] == 0) {
        if ([self.backgroundView respondsToSelector:@selector(setRecipe:)] == NO || self.backgroundView.materialLayer == NULL) {
            return;
        }

        [self.backgroundView setRecipe:[preferences integerForKey:@"style"]];

        [self.backgroundView.materialLayer setBlurEnabled:[preferences boolForKey:@"iosblurenabled"]];
        [self.backgroundView setAlpha:[preferences doubleForKey:@"alpha"]];

        return;
    }

    if (layoutCountFloating != 2) {
        layoutCountFloating = layoutCountFloating + 1;
        return;
    }

    if ([preferences integerForKey:@"styletype"] == 1) {
        NSString* solidcolorString = NULL;
        NSDictionary* preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.thatmarcel.tweaks.docktyle.scprefs.plist"];
        if(preferencesDictionary) {
            solidcolorString = [preferencesDictionary objectForKey: @"solidcolor"];
        }
        UIColor* solidcolor = [SparkColourPickerUtils colourWithString:solidcolorString withFallback:@"#f5bd07"];

        gradient.frame = self.mainPlatterView.frame;
        gradient.colors = @[(id)solidcolor.CGColor, (id)solidcolor.CGColor];

        [gradient setCornerRadius:self.backgroundView.layer.cornerRadius];
        [gradient setMasksToBounds:YES];

        [gradient setOpacity:[preferences doubleForKey:@"alpha"]];

        [self.layer insertSublayer:gradient atIndex:0];

        [self.backgroundView.layer setHidden:YES];

        return;
    }

    if ([preferences integerForKey:@"styletype"] ==  2) {
        NSString* gradientcoloroneString = NULL;
        NSString* gradientcolortwoString = NULL;
        NSDictionary* preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.thatmarcel.tweaks.docktyle.scprefs.plist"];
        if(preferencesDictionary) {
            gradientcoloroneString = [preferencesDictionary objectForKey: @"gradientcolorone"];
            gradientcolortwoString = [preferencesDictionary objectForKey: @"gradientcolortwo"];
        }
        UIColor* gradientcolorone = [SparkColourPickerUtils colourWithString:gradientcoloroneString withFallback:@"#FF416C"];
        UIColor* gradientcolortwo = [SparkColourPickerUtils colourWithString:gradientcolortwoString withFallback:@"#FF4B2B"];

        gradient.frame = self.mainPlatterView.frame;
        gradient.colors = @[(id)gradientcolorone.CGColor, (id)gradientcolortwo.CGColor];

        gradient.startPoint = CGPointMake(0.0, 0.5);
        gradient.endPoint = CGPointMake(1.0, 0.5);

        [gradient setCornerRadius:self.backgroundView.layer.cornerRadius];
        [gradient setMasksToBounds:YES];

        [gradient setOpacity:[preferences doubleForKey:@"alpha"]];

        [self.layer insertSublayer:gradient atIndex:0];

        [self.backgroundView.layer setHidden:YES];

        return;
    }

    if ([preferences integerForKey:@"styletype"] ==  3) {
        // [self.backgroundView setHidden:YES];
    }
}

%end

%hook SBDockView

- (void) layoutSubviews {
    %orig;

    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"com.thatmarcel.tweaks.docktyle.hbprefs"];
    [preferences registerDefaults:@{
        @"style": @1,
        @"iosblurenabled": @YES,
        @"enabled": @YES,
        @"styletype": @0,
        @"alpha": @1.0
	}];

    if ([preferences boolForKey:@"enabled"] == NO) {
        return;
    }

    if ([preferences integerForKey:@"styletype"] == 0) {
        [self.backgroundView setRecipe:[preferences integerForKey:@"style"]];

        [self.backgroundView.materialLayer setBlurEnabled:[preferences boolForKey:@"iosblurenabled"]];
        [self.backgroundView setAlpha:[preferences doubleForKey:@"alpha"]];

        return;
    }

    if (layoutCount != 3) {
        layoutCount = layoutCount + 1;
        return;
    }

    if ([preferences integerForKey:@"styletype"] == 1 && !layerAdded) {
        NSString* solidcolorString = NULL;
        NSDictionary* preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.thatmarcel.tweaks.docktyle.scprefs.plist"];
        if(preferencesDictionary) {
            solidcolorString = [preferencesDictionary objectForKey: @"solidcolor"];
        }
        UIColor* solidcolor = [SparkColourPickerUtils colourWithString:solidcolorString withFallback:@"#f5bd07"];

        gradient.frame = self.backgroundView.frame;
        gradient.colors = @[(id)solidcolor.CGColor, (id)solidcolor.CGColor];

        [gradient setCornerRadius:self.backgroundView.layer.cornerRadius];
        [gradient setMasksToBounds:YES];

        [gradient setOpacity:[preferences doubleForKey:@"alpha"]];

        [self.layer insertSublayer:gradient atIndex:0];

        [self.backgroundView setHidden:YES];
    
        layerAdded = YES;

        return;
    }

    if ([preferences integerForKey:@"styletype"] ==  2 && !layerAdded) {
        NSString* gradientcoloroneString = NULL;
        NSString* gradientcolortwoString = NULL;
        NSDictionary* preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.thatmarcel.tweaks.docktyle.scprefs.plist"];
        if(preferencesDictionary) {
            gradientcoloroneString = [preferencesDictionary objectForKey: @"gradientcolorone"];
            gradientcolortwoString = [preferencesDictionary objectForKey: @"gradientcolortwo"];
        }
        UIColor* gradientcolorone = [SparkColourPickerUtils colourWithString:gradientcoloroneString withFallback:@"#FF416C"];
        UIColor* gradientcolortwo = [SparkColourPickerUtils colourWithString:gradientcolortwoString withFallback:@"#FF4B2B"];

        gradient.frame = self.backgroundView.frame;
        gradient.colors = @[(id)gradientcolorone.CGColor, (id)gradientcolortwo.CGColor];

        gradient.startPoint = CGPointMake(0.0, 0.5);
        gradient.endPoint = CGPointMake(1.0, 0.5);

        [gradient setCornerRadius:self.backgroundView.layer.cornerRadius];
        [gradient setMasksToBounds:YES];

        [gradient setOpacity:[preferences doubleForKey:@"alpha"]];

        [self.layer insertSublayer:gradient atIndex:0];

        [self.backgroundView setHidden:YES];

        layerAdded = YES;

        return;
    }

    if ([preferences integerForKey:@"styletype"] ==  3) {
        [self.backgroundView setHidden:YES];
    }
}

%end