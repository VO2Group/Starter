function debounce(fn, timeout) {
  var timeoutId;
  return function () {
    var _this = this;
    var _arguments = arguments;
    clearTimeout(timeoutId);
    timeoutId = setTimeout(function () {
      fn.apply(_this, _arguments);
    }, timeout);
  };
}

function poll(fn, timeout, interval) {
  var end = Date.now() + (timeout || 2000);
  interval = interval || 100;
  return new Promise(function (resolve, reject) {
    (function p() {
      if (fn()) {
        resolve();
      } else if (Date.now() < end) {
        setTimeout(p, interval);
      } else {
        reject();
      }
    })();
  });
}
