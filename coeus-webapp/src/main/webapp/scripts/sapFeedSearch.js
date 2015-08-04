function rejectFeed(action) {
    var data = {};
    data.feedId = jQuery(action).closest("tr").find(".feedId").text();
    ajaxSubmitForm("rejectFeed", data);
}

function restoreFeed(action) {
    var data = {};
    data.feedId = jQuery(action).closest("tr").find(".feedId").text();
    ajaxSubmitForm("restoreFeed", data);
}

function cancelFeed(action) {
    var data = {};
    data.feedId = jQuery(action).closest("tr").find(".feedId").text();
    ajaxSubmitForm("cancelFeed", data);
}

function setupLightTableCss() {
    jQuery(".uif-lightTable").addClass("table table-condensed table-bordered uif-tableCollectionLayout");
}

// KRAD override
function _handleColData(rowObject, type, colName, newVal) {
    var colObj = rowObject[colName];

    if (!colObj) {
        return "";
    }

    if (type === "set" && newVal && newVal != colObj.val) {
        colObj.render = jQuery(newVal).html();
        colObj.val = coerceTableCellValue(newVal);
        return;
    } else if (type === "display") {
        return colObj.render;
    } else if (type === "sort") {
        var sortValue = colObj.val;
        if (sortValue == null) {
            sortValue = colObj.render;
        }

        if (colObj.render) {
            var field = jQuery(colObj.render);
            var isInput = field.is("[data-role='InputField']");

            if (isInput) {
                var id = field.attr("id");
                var control = field.find("[data-control_for='" + id + "']");
                if (control.length) {
                    sortValue = coerceValue(control.attr("name"));
                }
            } else {
                sortValue = field.text();
            }
        }

        return sortValue;
    }

    return colObj.val;

}