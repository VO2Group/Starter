window.platform = {
  name: function () {
    return 'ios';
  },

  alert: function (message) {
    webkit.messageHandlers.handler.postMessage({
      method: 'alert',
      message: message,
    });
  },

  yesOrNo: function (message) {
    var _this = this;
    return new Promise(function (resolve, reject) {
      var index = _this._callbacks.length;
      _this._callbacks.push(resolve);
      _this._callbacks.push(reject);
      webkit.messageHandlers.handler.postMessage({
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
