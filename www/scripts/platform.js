window.platform = window.platform || {
  name: function () {
    return 'www';
  },

  alert: function (message) {
    alert(message);
  },

  confirm: function (message, callback) {
    callback(null, confirm(message));
  },
};
