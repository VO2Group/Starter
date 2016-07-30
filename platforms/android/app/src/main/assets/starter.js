window.Starter = {
  getPlatform: function () {
    return 'android';
  },

  alert: function (message) {
    StarterJavascriptInterface.alert(message);
  },
};
