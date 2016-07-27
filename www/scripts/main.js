document.onreadystatechange = function () {
  var hello = document.getElementById('hello');
  hello.addEventListener('click', function () {
    var placeholder = document.getElementById('placeholder');
    placeholder.innerHTML = 'hello';
  });
};
