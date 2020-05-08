function initializeCollapsible() {
  document.querySelectorAll('.collapsible').forEach(function(element) {
    var link = document.querySelector('a[href="#' + element.id + '"]');
    link.addEventListener('click', function (e) {
      e.preventDefault();
      if (element.style.display === 'block') {
        element.style.display = 'none';
        link.textContent = link.textContent.replace('Hide', 'Show');
      } else {
        element.style.display = 'block';
        link.textContent = link.textContent.replace('Show', 'Hide');
      }
      var newDisplay = element.style.display === 'block' ? 'none' : 'block';
    });
  });
}


window.addEventListener('load', function () {
  initializeCollapsible();
});
