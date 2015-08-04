function setupColumnHover() {
    jQuery(document).on("mouseenter", "td.wl-balance-vertical", function () {
        var index = jQuery(this).index() + 1;
        jQuery("table").find("tr td:nth-of-type(" + index + ")").addClass("wl-hover-color");

    });

    jQuery(document).on("mouseleave", "td.wl-balance-vertical", function () {
        var index = jQuery(this).index() + 1;
        jQuery("table").find("tr td:nth-of-type(" + index + ")").removeClass("wl-hover-color");
    });
}
