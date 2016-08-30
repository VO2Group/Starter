# Starter

Write smart hybrid apps!

## Motivation

1. Webkit  
   The goal of Starter project is to use [WebKit][WebKit] on every platforms to ensure behaviors and performances.

2. Simple  
   Starter is simple! Take a look at [Tim Peters's ode to programming][Tim Peters's ode to programming].

3. Unbreakable  
   None of tim's rules can be broken (see 8th rule).

## Platforms

Starter focus two platforms:

* iOS 9+
* Android 6.0 (API level 23)

> If you need more backward compatibility or more exotic platforms like Windows Phone or BlackBerry, use something else!

## Tools

Following tools are mandatory for a full use of Starter:

* [XCode][XCode]: Even if you don't feel right with it, there is no other choice for iOS.
* [Android Studio][Android Studio]: The best IDE for building Android apps.
* [GNU make][GNU make]: After more than 25 years, the old `make` build tool still rule them all!
* [Jenkins][Jenkins]: The king of continuous integration.
* [fastlane][fastlane]: The game changer for stores submission.

## Concepts

### Platform projects are not generated!

If you use Starter you have to modify manually the platform projects, they are located in `platforms` directory and they are both named `AppShell`.

### Platform projects use [WebKit][WebKit]!

Both projects are *Single View Applications* with a *Fullscreen WebView*:
* Starter uses [android.webkit.WebView][android.webkit.WebView] class on Android.
* Starter uses the new [WKWebView][WKWebView] class on iOS (introduced in iOS 8).

> More precisely Starter uses the method [loadFileURL][loadFileURL] of [WKWebView][WKWebView] class introduced in iOS 9!

### Platform projects dispatch events to DOM Document Object

Android and iOS are multitasking platforms, applications can be paused and can be resumed. To handle these features Starter send some events from native code to Javascript. The events are named `pause` and `resume`.

On Android events are dispatched like this:

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('pause'));", null);
```

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('resume'));", null);
```

And on iOS like this:

```swift
self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('pause'));", completionHandler: nil)
```

```swift
self.webView!.evaluateJavaScript("document.dispatchEvent(new Event('resume'));", completionHandler: nil)
```

Finally events are handled in Javascript like this:

```javascript
document.addEventListener('pause', function (e) {...});
```

```javascript
document.addEventListener('resume', function (e) {...});
```

### Platform projects expose native to Javascript bridge




[WebKit]: https://webkit.org/ "WebKit"
[Tim Peters's ode to programming]: https://www.python.org/dev/peps/pep-0020/ "The zen of python"
[XCode]: https://itunes.apple.com/en/app/xcode/id497799835?mt=12 "XCode"
[Android Studio]: https://developer.android.com/studio/index.html "Android Studio"
[GNU make]: https://www.gnu.org/software/make/manual/make.html "GNU make"
[Jenkins]: https://jenkins.io/ "Jenkins"
[fastlane]: https://fastlane.tools/ "fastlane"
[android.webkit.WebView]: https://developer.android.com/reference/android/webkit/WebView.html "android.webkit.WebView"
[WKWebView]: https://developer.apple.com/library/mac/documentation/WebKit/Reference/WKWebView_Ref/ "WKWebView"
[loadFileURL]: https://developer.apple.com/library/mac/documentation/WebKit/Reference/WKWebView_Ref/#//apple_ref/occ/instm/WKWebView/loadFileURL:allowingReadAccessToURL: "loadFileURL"
