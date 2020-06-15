@interface DCKGradientView : UIView

@property (nonatomic, retain) CAGradientLayer* gradientLayer;

- (void) loadWithPrefs:(HBPreferences*)preferences;

- (void) loadGradientWithPrefs:(HBPreferences*)preferences;
- (void) addGradientLayerWithColor1:(UIColor*)color1 andColor2:(UIColor*)color2 andOpacity:(double)opacity;

@end
