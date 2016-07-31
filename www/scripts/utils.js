function debounce(callback, timeout) {
  var timeoutId;
  return function () {
    var _this = this;
    var _arguments = arguments;
    clearTimeout(timeoutId);
    timeoutId = setTimeout(function () {
      callback.apply(_this, _arguments);
    }, timeout);
  };
}
