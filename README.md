# Starter

Starter is a starter kit for building hybrid apps, it contains:

* An HTML5 application
* Two native projects
* And a set of tools files

## Platforms

Starter focuses to two platforms:

* iOS 9+
* Android 6.0+ (API level 23)

> If you need more backward compatibility or more exotic platforms like Windows Phone or BlackBerry, use something else!

## Tools

Following tools are mandatory for a full use of Starter:

* [XCode][1]: Even if you don't feel right with it, there is no other choice for iOS.
* [Android Studio][2]: The best IDE for building Android apps.
* [GNU make][3]: After more than 25 years, the old `make` build tool still rule them all!
* [Jenkins][4]: The king of continuous integration.
* [fastlane][5]: The game changer for stores submission.

## Concepts

### Platform projects are not generated!

If you use Starter you have to modify manually the platform projects, they are located in `platforms` directory and they are both named `AppShell`.

### Platform projects use WebKit

Both projects are *Single View Applications* with a *Fullscreen WebView*:
* Starter uses [android.webkit.WebView][6] class on Android.
* Starter uses the new [WKWebView][7] class on iOS (introduced in iOS 8).

> More precisely Starter uses the method [loadFileURL][8] of [WKWebView][7] class introduced in iOS 9!

### Platform projects dispatch events to DOM Document Object

Android and iOS are multitasking platforms, applications can be paused and can be resumed. To handle these features Starter sends some events from native code to Javascript. The events are named `pause` and `resume`.

On Android events are dispatched by the [com.starter.appshell.MainActivity][9] like this:

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('pause'));", null);
```

```java
this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('resume'));", null);
```

And on iOS by the [ViewController][10] like this:

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

In hybrid applications, Javascript needs to call some native code. To do this, the platform projects inject an object called `platform` in Window object before loading HTML.

On Android `platform` object look like this:

```javascript
window.platform = {
  name: function () {
    return 'android';
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

> The `android` object is introduced by the [addJavascriptInterface][11] method of [android.webkit.WebView][6] class. Also `android.foo()` and `android.bar(...)` functions are defined by the methods of [com.starter.appshell.JavascriptInterface][12] class (see [android.webkit.JavascriptInterface][13] annotation). Last but not the least, `_callbacks`, `_uuid` and `_invoke` are private properties, they are used to support async function callback.

And [com.starter.appshell.MainActivity][9] injects it like this:

```java
try (InputStream stream = this.getAssets().open("platform.js")) {
    byte[] buffer = new byte[stream.available()];
    stream.read(buffer);
    this.mWebView.evaluateJavascript(new String(buffer), null);
}
catch (IOException ex) {
}
```

On iOS, things are quite the same, `platform` object looks like this:

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

> Here `webkit.messageHandlers.handler` object is introduced by [addScriptMessageHandler][14] method of [WKUserContentController][15] class and posted messages are received by [ScriptMessageHandler][16] class.

And it is injected by [ViewController][10] like this:

```swift
let platform = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("platform", ofType: "js")!)
self.webView!.evaluateJavaScript(try! String(contentsOfURL: platform), completionHandler: nil)
```

#### How callbacks works?

Starter uses the same callback model as node.js, a function with two arguments: `err` and `data`. They are typically used like this:

```javascript
function (err, data) {
  if (err)
    throw err;
  // data is available here
}
```

As Starter can't provide the function directly to the native code, a unique identifier is generated by the `_uuid` function of `platform` object. When native code needs to invoke this callback, it simply calls the `_invoke` function with the given identifier.

On Android:

```java
this.mWebView.post(new Runnable() {
    @Override
    public void run() {
        JavascriptInterface.this.mWebView.evaluateJavascript("platform._invoke('" + callback + "', null, true);", null);
    }
});
```

> The callback is not invoked on the UI thread (see [post][17] method).

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

> As you can see the object is defined only if it doesn't exist (see [index.html][18]).

### Platform projects supports *viewer* mode

Each project can define in its own application manifest a property named `StartURL`. If this property is defined, the application starts in *viewer* mode. That allows the application to load this url in the WebView.

> See [AndroidManifest.xml][19] and [Info.plist][20]

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

> More information on `assets` directory can be found [here][21].

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

### [GNU make][3]

[GNU make][3] goals are defined in [Makefile][22] file. Its main purpose is to copy the HTML5 application located in `src` directory to platform projects:

* On Android the application is copied to `platforms/android/app/src/main/assets/www`
* And on iOS to `platforms/ios/www`

> If the HTML5 application needs to be bundled with tools like [browserify][23] or [webpack][24], it must be done here! Let's say that the [Makefile][22] knows both worlds (native and Javascript).

### [fastlane][5]

[fastlane][5] handles following lifecycle tasks of platform projects:

* Run units tests and UI tests
* Build application
* Submit application to store

> Good tool or bad tool ? [fastlane][5] allows you to manipulate platform projects in a uniform way!

Starter provides following lanes for both platforms:

* `test`: Runs all the tests
* `compile`: Compile the application
* `store`: Submit the application

> For example to build iOS platform project, use `fastlane ios compile`

Check [fastlane][5] files for more information: [Appfile][25], [Fastfile][26].

### [Jenkins][4]

[Jenkins][4] pipeline is defined in [Jenkinsfile][27] file. Normally Jenkins pipeline should execute:

* [GUN make][22] rules
* [fastlane][5] lanes

[1]: https://itunes.apple.com/en/app/xcode/id497799835?mt=12 "XCode"
[2]: https://developer.android.com/studio/index.html "Android Studio"
[3]: https://www.gnu.org/software/make/manual/make.html "GNU make"
[4]: https://jenkins.io/ "Jenkins"
[5]: https://fastlane.tools/ "fastlane"
[6]: https://developer.android.com/reference/android/webkit/WebView.html "android.webkit.WebView"
[7]: https://developer.apple.com/library/mac/documentation/WebKit/Reference/WKWebView_Ref/ "WKWebView"
[8]: https://developer.apple.com/library/mac/documentation/WebKit/Reference/WKWebView_Ref/#//apple_ref/occ/instm/WKWebView/loadFileURL:allowingReadAccessToURL: "loadFileURL"
[9]: platforms/android/app/src/main/java/com/starter/appshell/MainActivity.java "com.starter.appshell.MainActivity"
[10]: platforms/ios/AppShell/ViewController.swift "ViewController"
[11]: https://developer.android.com/reference/android/webkit/WebView.html#addJavascriptInterface(java.lang.Object,%20java.lang.String) "addJavascriptInterface"
[12]: platforms/android/app/src/main/java/com/starter/appshell/JavascriptInterface.java "com.starter.appshell.JavascriptInterface"
[13]: https://developer.android.com/reference/android/webkit/JavascriptInterface.html "android.webkit.JavascriptInterface"
[14]: https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKUserContentController_Ref/#//apple_ref/occ/instm/WKUserContentController/addScriptMessageHandler:name: "addScriptMessageHandler"
[15]: https://developer.apple.com/library/ios/documentation/WebKit/Reference/WKUserContentController_Ref/ "WKUserContentController"
[16]: platforms/ios/AppShell/ScriptMessageHandler.swift "ScriptMessageHandler"
[17]: https://developer.android.com/reference/android/view/View.html#post(java.lang.Runnable) "post"
[18]: src/index.html "index.html"
[19]: platforms/android/app/src/main/AndroidManifest.xml "AndroidManifest.xml"
[20]: platforms/ios/AppShell/Info.plist "Info.plist"
[21]: http://tools.android.com/tech-docs/new-build-system/user-guide#TOC-Project-Structure "Project Structure"
[22]: Makefile "Makefile"
[23]: http://browserify.org/ "browserify"
[24]: https://webpack.github.io/ "webpack"
[25]: fastlane/Appfile "Appfile"
[26]: fastlane/Fastfile "Fastfile"
[27]: Jenkinsfile "Jenkinsfile"
