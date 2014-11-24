![LTInfiniteScrollView](https://raw.githubusercontent.com/ltebean/LTInfiniteScrollView/master/demo.gif)

## Usage
Implement `LTInfiniteScrollViewDataSource` and `LTInfiniteScrollViewDelegate` protocol 

```objective-c
@protocol LTInfiniteScrollViewDataSource <NSObject>
-(UIView*) viewAtIndex:(int)index reusingView:(UIView *)view;
-(int) totalViewCount;
-(int) visibleViewCount;
@end

@protocol LTInfiniteScrollViewDelegate <NSObject>
-(void) updateView:(UIView*) view withDistanceToCenter:(CGFloat)distance scrollDirection:(ScrollDirection)direction;
@end
```

In the delegate method, you can apply various view transform during scrolling.

See the example for details~ 