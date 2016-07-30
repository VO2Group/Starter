package com.lajule.starter;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;

/**
 * Created by julienrouzieres on 29/07/2016.
 */
public class StarterJavascriptInterface {

    private Context mContext;

    private WebView mWebView;

    public StarterJavascriptInterface(Context context, WebView webView) {
        this.mContext = context;
        this.mWebView = webView;
    }

    @JavascriptInterface
    public void alert(String message) {
        new AlertDialog.Builder(this.mContext)
                .setTitle("Alert")
                .setMessage(message)
                .setPositiveButton(android.R.string.ok, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }

    @JavascriptInterface
    public void yesOrNo(String message, final int resolve, final int reject) {
        new AlertDialog.Builder(this.mContext)
                .setTitle("Question")
                .setMessage(message)
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        StarterJavascriptInterface.this.mWebView.post(new Runnable() {
                            @Override
                            public void run() {
                                StarterJavascriptInterface.this.mWebView.evaluateJavascript("window.starter._invoke(" + resolve + ", true);", null);
                            }
                        });
                    }
                })
                .setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        StarterJavascriptInterface.this.mWebView.post(new Runnable() {
                            @Override
                            public void run() {
                                StarterJavascriptInterface.this.mWebView.evaluateJavascript("window.starter._invoke(" + resolve + ", false);", null);
                            }
                        });
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
    }
}
