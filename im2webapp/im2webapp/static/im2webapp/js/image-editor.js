$(document).ready(function() {
  $("#range_brightness").blur(function() {
    var amount = $(this).val();
    amount = amount / 10;
    $("#brightness_value").text(amount);
    var img = document.getElementById('output_image');
    img.setAttribute('style',
      'filter:brightness(' +
      amount +
      '); -webkit-filter:brightness(' +
      amount +
      '); -moz-filter:brightness(' +
      amount +
      ')'
    );
  });
  $("#range_contrast").blur(function() {
    var amount = $(this).val();
    amount = amount / 10;
    $("#contrast_value").text(amount);
    var img = document.getElementById('output_image');
    img.setAttribute('style',
      'filter:contrast(' +
      amount +
      '); -webkit-filter:contrast(' +
      amount +
      '); -moz-filter:contrast(' +
      amount +
      ')'
    );
  });
});
