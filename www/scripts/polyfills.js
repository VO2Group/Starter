window.platform = window.platform || {
  name: function () {
    return 'www';
  },

  alert: function (message) {
    alert(message);
  },

  confirm: function (message, resolve, reject) {
    resolve(confirm(message));
  },
};
