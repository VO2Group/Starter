package com.starter.appshell;

import android.content.Intent;
import android.net.Uri;
import android.webkit.WebView;

/**
 * Created by julienrouzieres on 03/08/2016.
 */
public class WebViewClient extends android.webkit.WebViewClient {

    @Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
        if (Uri.parse(url).getHost().length() == 0) {
            return false;
        }

        Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        view.getContext().startActivity(intent);
        return true;
    }

}
