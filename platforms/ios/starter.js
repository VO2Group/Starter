window.starter = {
  platform: function () {
    return 'ios';
  },

  alert: function (message) {
    window.webkit.messageHandlers.handler.postMessage({
      method: 'alert',
      message: message,
    });
  },

  yesOrNo: function (message) {
    var self = this;
    return new Promise(function (resolve, reject) {
      var index = self._callbacks.length;
      self._callbacks.push(resolve);
      self._callbacks.push(reject);
      window.webkit.messageHandlers.handler.postMessage({
        method: 'yesOrNo',
        message: message,
        resolve: index,
        reject: index + 1,
      });
    });
  },

  _callbacks: [],

  _invoke: function (index, obj) {
    this._callbacks[index](obj);
  },
};
