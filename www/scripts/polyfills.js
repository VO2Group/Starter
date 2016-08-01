window.platform = window.platform || {
  name: function () {
    return 'www';
  },

  alert: function (message) {
    alert(message);
  },

  confirm: function (message) {
    return new Promise(function (resolve, reject) {
      resolve(confirm(message));
    });
  },
};
