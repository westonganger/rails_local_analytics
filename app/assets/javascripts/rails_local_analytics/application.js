$(function(){
  $('table.table-sortable').tablesorter();

  $(document).on("click", "tr[data-url]", function(){
    window.location = $(this).data("url");
  });
});
