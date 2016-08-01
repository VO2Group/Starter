document.onreadystatechange = function () {
  if (document.readyState == 'interactive') {
    var test = document.getElementById('test');
    var answer = document.getElementById('answer');
    test.addEventListener('click', function (event) {
      platform
        .confirm('Are you ... ?')
        .then(function (b) {
          answer.innerHTML = b ? 'Yes!' : 'No!';
        });
    });
  }
};
