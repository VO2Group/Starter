document.onreadystatechange = function () {
  if (document.readyState == 'interactive') {
    moment.locale('fr');
    var date = document.getElementById('date');
    date.innerHTML = moment().format('dddd');

    var n = Number(window.localStorage.getItem('counter') || 0) + 1;
    window.localStorage.setItem('counter', n);

    var counter = document.getElementById('counter');
    counter.innerHTML = n;
  }
};
