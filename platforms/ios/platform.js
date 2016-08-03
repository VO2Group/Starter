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
