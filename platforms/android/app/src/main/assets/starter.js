window.starter = {
  platform: function () {
    return 'andoid';
  },

  alert: function (message) {
    StarterJavascriptInterface.alert(message);
  },

  yesOrNo: function (message) {
    var self = this;
    return new Promise(function (resolve, reject) {
      var index = self._callbacks.length;
      self._callbacks.push(resolve);
      self._callbacks.push(reject);
      window.StarterJavascriptInterface.yesOrNo(message, index, index + 1);
    });
  },

  _callbacks: [],

  _invoke: function (index, obj) {
    this._callbacks[index](obj);
  },
};
