window.Starter = {
  getPlatform: function () {
    return 'ios';
  },

  alert: function (message) {
    window.webkit.messageHandlers.handler.postMessage({
      method: 'alert',
      message: message,
    });
  },
};
