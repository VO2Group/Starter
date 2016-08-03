window.platform = window.platform || {
  name: function () {
    return 'www';
  },

  foo: function (message) {
    alert(message);
  },

  bar: function (message, callback) {
    callback(null, confirm(message));
  },
};
