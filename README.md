# Starter

Write smart hybrid apps!

## Motivation

1. [WebKit][1]  
   The goal of Starter project is to use [WebKit][1] on every platforms to ensure behaviors and performances.

2. Simple  
   Starter is simple! Take a look at [Tim Peters's ode to programming][2].

3. Unbreakable  
   None of tim's rules can be broken (see 8th rule).

## Platforms

Starter focus two platforms:

* iOS 9+
* Android 6.0+ (API level 23)

> If you need more backward compatibility or more exotic platforms like Windows Phone or BlackBerry, use something else!

## Tools

Following tools are mandatory for a full use of Starter:

* [XCode][3]: Even if you don't feel right with it, there is no other choice for iOS.
* [Android Studio][4]: The best IDE for building Android apps.
* [GNU make][5]: After more than 25 years, the old `make` build tool still rule them all!
* [Jenkins][6]: The king of continuous integration.
* [fastlane][7]: The game changer for stores submission.

## Concepts

### Platform projects are not generated!

If you use Starter you have to modify manually the platform projects, they are located in `platforms` directory and they are both named `AppShell`.

### Platform projects use [WebKit][1]

Both projects are *Single View Applications* with a *Fullscreen WebView*:
* Starter uses [android.webkit.WebView][8] class on Android.
* Starter uses the new [WKWebView][9] class on iOS (introduced in iOS 8).

> More precisely Starter uses the method [loadFileURL][10] of [WKWebView][9] class introduced in iOS 9!

### Platform projects dispatch events to DOM Document Object

Android and iOS are multitasking platforms, applications can be paused and can be resumed. To handle these features Starter send some events from native code to Javascript. The events are named `pause` and `resume`.

On Android events are dispatched by the [com.starter.appshell.MainActivity][11] like this:

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('pause'));", null);
```

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('resume'));", null);
```

And on iOS by the [ViewController][12] like this:

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

> The `android` object is introduced by the [addJavascriptInterface][13] method of [android.webkit.WebView][8] class. Also `android.foo()` and `android.bar(...)` functions are defined by the methods of [com.starter.appshell.JavascriptInterface][14] class (see [android.webkit.JavascriptInterface][15] annotation). Last but not the least, `_callbacks`, `_uuid` and `_invoke` are private properties, they are used to support async function callback.

And [com.starter.appshell.MainActivity][11] inject it like this:

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

> Here `webkit.messageHandlers.handler` object, it is introduced by the [addScriptMessageHandler][16] method of [WKUserContentController][17] class and posted messages are received by [ScriptMessageHandler][18] class.

And it is injected by [ViewController][12] like this:

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

> The callback is not invoked on the UI thread (see [post][19] method).

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

> As you can see the object is defined only if it not exist (see [index.html][20]).

### Platform projects supports *viewer* mode

Each project can define in his own application manifest a property named `StartURL`, if this property is defined, the application start in *viewer* update mode. That's means the application will load this url in the WebView.

> See [AndroidManifest.xml][21] and [Info.plist][22]

The WebView is initialized like this on Android:

```java
String url = "file:///android_asset/www/index.html";
try {
    ApplicationInfo ai = getPackageManager().getApplicationInfo(getPackageName(), PackageManager.GET_META_DATA);
    url = (String) ai.metaData.get("StartURL");
}
catch (Exception ex) {
}

this.mWebView.loadUrl(url);
```

> More information on `assets` directory can be found here [Project Structure][23].

Once again, things are equivalent on iOS:

```swift
if let url = NSBundle.mainBundle().objectForInfoDictionaryKey("StartURL") as? String {
    self.webView!.loadRequest(NSURLRequest(URL: NSURL(string: url)!))
}
else {
    let index = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "www")!)
    self.webView!.loadFileURL(index, allowingReadAccessToURL: index.URLByDeletingLastPathComponent!)
}
```

## Goals

### [GNU make][5]

[GNU make][5] goals are defined in [Makefile][24] file, his main purpose is to copy the HTML5 application located in `src` directory to platform projects:

* On Android the application is copied to `platforms/android/app/src/main/assets/www`
* And on iOS to `platforms/ios/www`

> If the HTML5 application need to be bundled with tools like [browserify][25] or [webpack][26], it must be done here! Let's say that the [Makefile][24] know both worlds (native and Javascript).

### [fastlane][7]

FIXME

### [Jenkins][6]

FIXME

[1]: https://webkit.org/ "WebKit"
[2]: https://www.python.org/dev/peps/pep-0020/ "The zen of python"
[3]: https://itunes.apple.com/en/app/xcode/id497799835?mt=12 "XCode"
[4]: https://developer.android.com/studio/index.html "Android Studio"
[5]: https://www.gnu.org/software/make/manual/make.html "GNU make"
[6]: https://jenkins.io/ "Jenkins"
[7]: https://fastlane.tools/ "fastlane"
[8]: https://developer.android.com/reference/android/webkit/WebView.html "android.webkit.WebView"
[9]: https://developer.apple.com/library/mac/documentation/WebKit/Reference/WKWebView_Ref/ "WKWebView"
[10]: https://developer.apple.com/library/mac/documentation/WebKit/Reference/WKWebView_Ref/#//apple_ref/occ/instm/WKWebView/loadFileURL:allowingReadAccessToURL: "loadFileURL"
[11]: platforms/android/app/src/main/java/com/starter/appshell/MainActivity.java "com.starter.appshell.MainActivity"
[12]: platforms/ios/AppShell/ViewController.swift "ViewController"
[13]: https://developer.android.com/reference/android/webkit/WebView.html#addJavascriptInterface(java.lang.Object,%20java.lang.String) "addJavascriptInterface"
[14]: platforms/android/app/src/main/java/com/starter/appshell/JavascriptInterface.java "com.starter.appshell.JavascriptInterface"
[15]: https://developer.android.com/reference/android/webkit/JavascriptInterface.html "android.webkit.JavascriptInterface"
[16]: https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKUserContentController_Ref/#//apple_ref/occ/instm/WKUserContentController/addScriptMessageHandler:name: "addScriptMessageHandler"
[17]: https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKUserContentController_Ref/ "WKUserContentController"
[18]: platforms/ios/AppShell/ScriptMessageHandler.swift "ScriptMessageHandler"
[19]: https://developer.android.com/reference/android/view/View.html#post(java.lang.Runnable) "post"
[20]: src/index.html "index.html"
[21]: platforms/android/app/src/main/AndroidManifest.xml "AndroidManifest.xml"
[22]: platforms/ios/AppShell/Info.plist "Info.plist"
[23]: http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Project-Structure "Project Structure"
[24]: Makefile "Makefile"
[25]: http://browserify.org/ "browserify"
[26]: https://webpack.github.io/ "webpack"
