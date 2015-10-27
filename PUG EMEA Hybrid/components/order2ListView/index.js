'use strict';

app.order2ListView = kendo.observable({
    onShow: function() {},
    afterShow: function() {}
});

// START_CUSTOM_CODE_order2ListView
// END_CUSTOM_CODE_order2ListView
(function(parent) {
    var dataProvider = app.data.sports2000,
        jsdoOptions = {
            name: 'order',
            autoFill: false
        },
        dataSourceOptions = {
            type: 'jsdo',
            transport: {},

            schema: {
                model: {
                    fields: {
                        'SalesRep': {
                            field: 'SalesRep',
                            defaultValue: ''
                        },
                        'CustNum': {
                            field: 'CustNum',
                            defaultValue: ''
                        },
                    }
                }
            },
            serverFiltering: true,
            serverSorting: true,
            serverPaging: true,
            pageSize: 50
        },
        dataSource = new kendo.data.DataSource({
            pageSize: 50
        }),
        order2ListViewModel = kendo.observable({
            dataSource: dataSource,
            dataSourceOptions: dataSourceOptions,
            jsdoOptions: jsdoOptions,
            itemClick: function(e) {
                app.mobileApp.navigate('#components/order2ListView/details.html?uid=' + e.dataItem.uid);
            },
            detailsShow: function(e) {
                var item = e.view.params.uid,
                    dataSource = order2ListViewModel.get('dataSource'),
                    itemModel = dataSource.getByUid(item);
                if (!itemModel.SalesRep) {
                    itemModel.SalesRep = String.fromCharCode(160);
                }
                order2ListViewModel.set('currentItem', itemModel);
            },
            currentItem: null
        });

    parent.set('order2ListViewModel', order2ListViewModel);
    parent.set('onShow', function() {
        dataProvider.loadCatalogs().then(function _catalogsLoaded() {
            var jsdoOptions = order2ListViewModel.get('jsdoOptions').toJSON(),
                jsdo = new progress.data.JSDO(jsdoOptions),
                dataSourceOptions = order2ListViewModel.get('dataSourceOptions').toJSON(),
                dataSource;

            dataSourceOptions.transport.jsdo = jsdo;
            dataSource = new kendo.data.DataSource(dataSourceOptions);
            order2ListViewModel.set('dataSource', dataSource);
        });
    });

})(app.order2ListView);

// START_CUSTOM_CODE_order2ListViewModel
// you can handle the beforeFill / afterFill events here. For example:
/*
app.order2ListView.order2ListViewModel.jsdoOptions.events = {
    'beforeFill' : [ {
        scope : app.order2ListView.order2ListViewModel,
        fn : function (jsdo, success, request) {
            // beforeFill event handler statements ...
        }
    } ]
};
*/
// END_CUSTOM_CODE_order2ListViewModel