document.onreadystatechange = function () {
  if (document.readyState == 'interactive') {
    var n = Number(window.localStorage.getItem('counter') || 0) + 1;
    window.localStorage.setItem('counter', n);

    var counter = document.getElementById('counter');
    counter.innerHTML = n;

    var hello = document.getElementById('hello');
    hello.addEventListener('click', function () {
      var placeholder = document.getElementById('placeholder');
      placeholder.innerHTML = 'world!';
    });
  }
};
