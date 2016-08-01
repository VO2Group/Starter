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

  confirm: function (message, resolve, reject) {
    var uuid = this._uuid();
    this._callbacks[uuid] = {
      resolve: resolve,
      reject: reject,
    };
    webkit.messageHandlers.handler.postMessage({
      method: 'confirm',
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

  _invoke: function (uuid, success, obj) {
    var callback = success ? 'resolve' : 'reject';
    this._callbacks[uuid][callback](obj);
    delete this._callbacks[uuid];
  },
};
