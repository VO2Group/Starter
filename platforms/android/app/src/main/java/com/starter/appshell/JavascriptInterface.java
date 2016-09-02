package com.starter.appshell;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.webkit.WebView;

/**
 * Created by julienrouzieres on 03/08/2016.
 */
public class JavascriptInterface {

    private Context mContext;

    private WebView mWebView;

    public JavascriptInterface(Context context, WebView webView) {
        this.mContext = context;
        this.mWebView = webView;
    }

    @android.webkit.JavascriptInterface
    public void foo(String message) {
        new AlertDialog.Builder(this.mContext)
                .setTitle("Foo")
                .setMessage(message)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }

    @android.webkit.JavascriptInterface
    public void bar(String message, final String callback) {
        new AlertDialog.Builder(this.mContext)
                .setTitle("Bar")
                .setMessage(message)
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        JavascriptInterface.this.mWebView.post(new Runnable() {
                            @Override
                            public void run() {
                                JavascriptInterface.this.mWebView.evaluateJavascript("platform._invoke('" + callback + "', null, true);", null);
                            }
                        });
                    }
                })
                .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        JavascriptInterface.this.mWebView.post(new Runnable() {
                            @Override
                            public void run() {
                                JavascriptInterface.this.mWebView.evaluateJavascript("platform._invoke('" + callback + "', null, false);", null);
                            }
                        });
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }
}
