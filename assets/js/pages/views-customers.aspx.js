"use strict";

const createTable = function () {
    // Create a new Tabulator object. 
    var table = new Tabulator("#customers-table", {
        height: 418, // setting height enables Tabulator's Virtual DOM which improves render speed dramatically.
        layout: "fitDataFill",
        ajaxURL: "/api/customers",
        pagination: "local",
        paginationSize: 12,
        columns: [ 
            { title: "Number", field: "CMCustNo", align: "left", width: 80 },
            { title: "Name", field: "CMName", width: 550 },
            { title: "Address", field: "CMAddr1", align: "left", width: 448 }
        ],
        rowClick: function (e, row) { 
            alert("Customer number " + row.getData().CMCustNo + " clicked");
            // Do something here when a row is clicked. 
        },
    });

    const updateFilter = function(value) {
        const filterField = document.getElementById('filter-field').value;

        table.setFilter(filterField, 'like', value);
    }

    // Clear filter when 'filter-clear' button clicked.
    document.getElementById('filter-clear').
        addEventListener('click', function () {
            filterValue.value = '';
        });

    // Filter data when 'filter-value' changes. 
    document.getElementById('filter-value').
        addEventListener('keyup', function () {
            // Pass current filter value to updateFilter.
            updateFilter(this.value);
        });
}

asna.dom.documentReady(function () {
    createTable();
});
