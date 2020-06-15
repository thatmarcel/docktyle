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
