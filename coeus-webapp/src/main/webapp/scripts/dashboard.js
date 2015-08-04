function setupTabRetrieval() {
    jQuery(".uif-lightTable").addClass("table table-condensed table-bordered uif-tableCollectionLayout");

    jQuery(document).on("shown.bs.tab", "[data-type='Uif-TabGroup']", function (event) {
        var tabId = jQuery(event.target).attr("id").replace("_tab", "_tabPanel");
        var placeholder = jQuery("#" + tabId).find("> ." + kradVariables.CLASSES.PLACEHOLDER);
        if (placeholder.length) {
            retrieveComponent(placeholder.attr("id"), null, function () {
                jQuery(".uif-lightTable").addClass("table table-condensed table-bordered uif-tableCollectionLayout");
            });
        }
    });
}

function setupGraph(data) {
    Morris.Area({
        element: 'Dashboard-ExpendituresGraph',
        data: data,
        xkey: 'fiscalYear',
        ykeys: ['directExpenditures', 'subawardExpenditures', 'faExpenditures'],
        labels: ['Direct Expenditures', 'Subaward Expenditures', 'F&A Expenditures'],
        pointSize: 2,
        hideHover: 'auto',
        resize: true
    });
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