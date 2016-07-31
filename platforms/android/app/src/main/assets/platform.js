window.platform = {
  name: function () {
    return 'andoid';
  },

  alert: function (message) {
    android.alert(message);
  },

  confirm: function (message) {
    var _this = this;
    return new Promise(function (resolve, reject) {
      var uuid = _this._uuid();
      _this._callbacks[uuid] = {
        resolve: resolve,
        reject: reject,
      };
      android.confirm(message, uuid);
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
