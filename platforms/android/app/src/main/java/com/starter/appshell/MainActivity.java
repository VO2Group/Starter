package com.starter.appshell;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;

import java.io.IOException;
import java.io.InputStream;

public class MainActivity extends AppCompatActivity {

    private WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        this.mWebView = (WebView) findViewById(R.id.activity_main_webview);
        WebSettings webSettings = this.mWebView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);

        this.mWebView.setWebViewClient(new WebViewClient());
        this.mWebView.addJavascriptInterface(new JavascriptInterface(this, this.mWebView), "android");

        try (InputStream stream = this.getAssets().open("platform.js")) {
            byte[] buffer = new byte[stream.available()];
            stream.read(buffer);
            this.mWebView.evaluateJavascript(new String(buffer), null);
        }
        catch (IOException ex) {
        }

        this.mWebView.loadUrl("file:///android_asset/www/index.html");
    }

    @Override
    protected void onPause() {
        super.onPause();

        this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('pause'));", null);
    }

    @Override
    protected void onResume() {
        super.onResume();

        this.mWebView.evaluateJavascript("document.dispatchEvent(new Event('resume'));", null);
    }

    @Override
    public void onBackPressed() {
        if (mWebView.canGoBack()) {
            mWebView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
