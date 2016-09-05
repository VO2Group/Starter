# Starter

Write smart hybrid apps!

## Motivation

1. [WebKit][WebKit]  
   The goal of Starter project is to use [WebKit][WebKit] on every platforms to ensure behaviors and performances.

2. Simple  
   Starter is simple! Take a look at [Tim Peters's ode to programming][Tim Peters's ode to programming].

3. Unbreakable  
   None of tim's rules can be broken (see 8th rule).

## Platforms

Starter focus two platforms:

* iOS 9+
* Android 6.0+ (API level 23)

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

### Platform projects use [WebKit][WebKit]

Both projects are *Single View Applications* with a *Fullscreen WebView*:
* Starter uses [android.webkit.WebView][android.webkit.WebView] class on Android.
* Starter uses the new [WKWebView][WKWebView] class on iOS (introduced in iOS 8).

> More precisely Starter uses the method [loadFileURL][loadFileURL] of [WKWebView][WKWebView] class introduced in iOS 9!

### Platform projects dispatch events to DOM Document Object

Android and iOS are multitasking platforms, applications can be paused and can be resumed. To handle these features Starter send some events from native code to Javascript. The events are named `pause` and `resume`.

On Android events are dispatched by the [com.starter.appshell.MainActivity][com.starter.appshell.MainActivity] like this:

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('pause'));", null);
```

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('resume'));", null);
```

And on iOS by the [ViewController][ViewController] like this:

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

In hybrid applications Javascript need to call some native code, to do this, the platform projects inject an object called `platform` in Window object before loading HTML.

On Android `platform` object look like this:

```javascript
window.platform = {
  name: function () {
    return 'andoid';
  },

  foo: function (message) {
    android.foo(message);
  },

  bar: function (message, callback) {
    var uuid = this._uuid();
    this._callbacks[uuid] = callback;
    android.bar(message, uuid);
  },

  _callbacks: {},

  _uuid: function () {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = Math.random() * 16 | 0;
      var v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  },

  _invoke: function (uuid, err, data) {
    this._callbacks[uuid](err, data);
    delete this._callbacks[uuid];
  },
};
```

> The `android` object is introduced by the [addJavascriptInterface][addJavascriptInterface] method of [android.webkit.WebView][android.webkit.WebView] class. Also `android.foo()` and `android.bar(...)` functions are defined by the methods of [com.starter.appshell.JavascriptInterface][com.starter.appshell.JavascriptInterface] class (see [android.webkit.JavascriptInterface][android.webkit.JavascriptInterface] annotation). Last but not the least, `_callbacks`, `_uuid` and `_invoke` are private properties, they are used to support async function callback.

And [com.starter.appshell.MainActivity][com.starter.appshell.MainActivity] inject it like this:

```java
try (InputStream stream = this.getAssets().open("platform.js")) {
    byte[] buffer = new byte[stream.available()];
    stream.read(buffer);
    this.mWebView.evaluateJavascript(new String(buffer), null);
}
catch (IOException ex) {
}
```

On iOS, things are quite the same, `platform` object look like this:

```javascript
window.platform = {
  name: function () {
    return 'ios';
  },

  foo: function (message) {
    webkit.messageHandlers.handler.postMessage({
      method: 'foo',
      message: message,
    });
  },

  bar: function (message, callback) {
    var uuid = this._uuid();
    this._callbacks[uuid] = callback;
    webkit.messageHandlers.handler.postMessage({
      method: 'bar',
      message: message,
      callback: uuid,
    });
  },

  _callbacks: {},

  _uuid: function () {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
      var r = Math.random() * 16 | 0;
      var v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  },

  _invoke: function (uuid, err, data) {
    this._callbacks[uuid](err, data);
    delete this._callbacks[uuid];
  },
};
```

> Here `webkit.messageHandlers.handler` object, it is introduced by the [addScriptMessageHandler][addScriptMessageHandler] method of [WKUserContentController][WKUserContentController] class and posted messages are received by [ScriptMessageHandler][ScriptMessageHandler] class.

And it is injected by [ViewController][ViewController] like this:

```swift
let platform = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("platform", ofType: "js")!)
self.webView!.evaluateJavaScript(try! String(contentsOfURL: platform), completionHandler: nil)
```

#### How callbacks works?

Starter use the same callback model as node.js, a function with two arguments: `err` and `data`. They are typically used like this:

```javascript
function (err, data) {
  if (err)
    throw err;
  // data is available here
}
```

As Starter can't provide the function directly to the native code, a unique identifier is generated by the `_uuid` function of `platform` object. Once the native code need to invoke this callback, it simply call the `_invoke` function with the given identifier.

On Android:

```java
this.mWebView.post(new Runnable() {
    @Override
    public void run() {
        JavascriptInterface.this.mWebView.evaluateJavascript("platform._invoke('" + callback + "', null, true);", null);
    }
});
```

> The callback is not invoked on the UI thread (see [post][post] method).

And on iOS:

```swift
self.viewController.webView!.evaluateJavaScript("platform._invoke('" + callback + "', null, true);", completionHandler: nil)
```

#### Mock `platform` object for development

You have to mock the `platform` object during development phase in the browser, you can do something like this:

```javascript
window.platform = window.platform || {
  name: function () {
    return 'www';
  },

  foo: function (message) {
    alert(message);
  },

  bar: function (message, callback) {
    callback(null, confirm(message));
  },
};
```

> As you can see the object is defined only if it not exist (see [index.html][index.html]).

### Platform projects supports *viewer* mode

Each project can define in his own application manifest a property named `StartURL`, if this property is defined, the application start in *viewer* update mode. That's means the application will load this url in the WebView.

> See [AndroidManifest.xml][AndroidManifest.xml] and [Info.plist][Info.plist]

## Goals

### [GNU make][GNU make]

[GNU make][GNU make] goals are defined in [Makefile][Makefile] file, his main purpose is to copy the HTML5 application located in `src` directory to platform projects:

* On Android the application is copied to `platforms/android/app/src/main/assets/www`
* And on iOS to `platforms/ios/www`

> If the HTML5 application need to be bundled with tools like [browserify][browserify] or [webpack][webpack] it must be done here! Let's say that the [Makefile][Makefile] know both worlds (native and HTML).

### [fastlane][fastlane]

FIXME

### [Jenkins][Jenkins]

FIXME

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
[com.starter.appshell.MainActivity]: platforms/android/app/src/main/java/com/starter/appshell/MainActivity.java "com.starter.appshell.MainActivity"
[ViewController]: platforms/ios/AppShell/ViewController.swift "ViewController"
[addJavascriptInterface]: https://developer.android.com/reference/android/webkit/WebView.html#addJavascriptInterface(java.lang.Object,%20java.lang.String) "addJavascriptInterface"
[com.starter.appshell.JavascriptInterface]: platforms/android/app/src/main/java/com/starter/appshell/JavascriptInterface.java "com.starter.appshell.JavascriptInterface"
[android.webkit.JavascriptInterface]: https://developer.android.com/reference/android/webkit/JavascriptInterface.html "android.webkit.JavascriptInterface"
[addScriptMessageHandler]: https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKUserContentController_Ref/#//apple_ref/occ/instm/WKUserContentController/addScriptMessageHandler:name: "addScriptMessageHandler"
[WKUserContentController]: https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKUserContentController_Ref/ "WKUserContentController"
[ScriptMessageHandler]: platforms/ios/AppShell/ScriptMessageHandler.swift "ScriptMessageHandler"
[post]: https://developer.android.com/reference/android/view/View.html#post(java.lang.Runnable) "post"
[index.html]: src/index.html "index.html"
[AndroidManifest.xml]: platforms/android/app/src/main/AndroidManifest.xml "AndroidManifest.xml"
[Info.plist]: platforms/ios/AppShell/Info.plist "Info.plist"
[Makefile]: Makefile "Makefile"
[browserify]: http://browserify.org/ "browserify"
[webpack]: https://webpack.github.io/ "webpack"
