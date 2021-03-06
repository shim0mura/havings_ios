// Generated by Apple Swift version 2.2 (swiftlang-703.0.18.8 clang-703.0.31)
#pragma clang diagnostic push

#if defined(__has_include) && __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if defined(__has_include) && __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif

#if defined(__has_attribute) && __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if defined(__has_attribute) && __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if defined(__has_attribute) && __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if defined(__has_attribute) && __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_EXTRA _name : _type
# if defined(__has_feature) && __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import CoreGraphics;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
@class UIColor;
enum Alignment : NSInteger;
@class UIFont;
@class TagView;
@protocol TagListViewDelegate;
@class NSCoder;

SWIFT_CLASS("_TtC11TagListView11TagListView")
@interface TagListView : UIView
@property (nonatomic, strong) UIColor * _Nonnull textColor;
@property (nonatomic, strong) UIColor * _Nonnull selectedTextColor;
@property (nonatomic, strong) UIColor * _Nonnull tagBackgroundColor;
@property (nonatomic, strong) UIColor * _Nullable tagHighlightedBackgroundColor;
@property (nonatomic, strong) UIColor * _Nullable tagSelectedBackgroundColor;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor * _Nullable borderColor;
@property (nonatomic, strong) UIColor * _Nullable selectedBorderColor;
@property (nonatomic) CGFloat paddingY;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic) CGFloat marginY;
@property (nonatomic) CGFloat marginX;
@property (nonatomic) enum Alignment alignment;
@property (nonatomic, strong) UIColor * _Nonnull shadowColor;
@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) float shadowOpacity;
@property (nonatomic) BOOL enableRemoveButton;
@property (nonatomic) CGFloat removeButtonIconSize;
@property (nonatomic) CGFloat removeIconLineWidth;
@property (nonatomic, strong) UIColor * _Nonnull removeIconLineColor;
@property (nonatomic, strong) UIFont * _Nonnull textFont;
@property (nonatomic, weak) IBOutlet id <TagListViewDelegate> _Nullable delegate;
@property (nonatomic, readonly, copy) NSArray<TagView *> * _Nonnull tagViews;
- (void)prepareForInterfaceBuilder;
- (void)layoutSubviews;
- (CGSize)intrinsicContentSize;
- (TagView * _Nonnull)addTag:(NSString * _Nonnull)title;
- (TagView * _Nonnull)addTagView:(TagView * _Nonnull)tagView;
- (void)removeTag:(NSString * _Nonnull)title;
- (void)removeTagView:(TagView * _Nonnull)tagView;
- (void)removeAllTags;
- (NSArray<TagView *> * _Nonnull)selectedTags;
- (nonnull instancetype)initWithFrame:(CGRect)frame OBJC_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
@end

typedef SWIFT_ENUM(NSInteger, Alignment) {
  AlignmentLeft = 0,
  AlignmentCenter = 1,
  AlignmentRight = 2,
};


SWIFT_PROTOCOL("_TtP11TagListView19TagListViewDelegate_")
@protocol TagListViewDelegate
@optional
- (void)tagPressed:(NSString * _Nonnull)title tagView:(TagView * _Nonnull)tagView sender:(TagListView * _Nonnull)sender;
- (void)tagRemoveButtonPressed:(NSString * _Nonnull)title tagView:(TagView * _Nonnull)tagView sender:(TagListView * _Nonnull)sender;
@end


SWIFT_CLASS("_TtC11TagListView7TagView")
@interface TagView : UIButton
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic, strong) UIColor * _Nullable borderColor;
@property (nonatomic, strong) UIColor * _Nonnull textColor;
@property (nonatomic, strong) UIColor * _Nonnull selectedTextColor;
@property (nonatomic) CGFloat paddingY;
@property (nonatomic) CGFloat paddingX;
@property (nonatomic, strong) UIColor * _Nonnull tagBackgroundColor;
@property (nonatomic, strong) UIColor * _Nullable highlightedBackgroundColor;
@property (nonatomic, strong) UIColor * _Nullable selectedBorderColor;
@property (nonatomic, strong) UIColor * _Nullable selectedBackgroundColor;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) BOOL enableRemoveButton;
@property (nonatomic) CGFloat removeButtonIconSize;
@property (nonatomic) CGFloat removeIconLineWidth;
@property (nonatomic, strong) UIColor * _Nonnull removeIconLineColor;

/// Handles Tap (TouchUpInside)
@property (nonatomic, copy) void (^ _Nullable onTap)(TagView * _Nonnull);
- (nullable instancetype)initWithCoder:(NSCoder * _Nonnull)aDecoder OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithTitle:(NSString * _Nonnull)title OBJC_DESIGNATED_INITIALIZER;
- (CGSize)intrinsicContentSize;
- (void)layoutSubviews;
@end

#pragma clang diagnostic pop
