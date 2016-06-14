'use strict';

app.orderLists = kendo.observable({
    onShow: function() {},
    afterShow: function() {}
});

// START_CUSTOM_CODE_orderLists
// Add custom code here. For more information about custom code, see http://docs.telerik.com/platform/screenbuilder/troubleshooting/how-to-keep-custom-code-changes

// END_CUSTOM_CODE_orderLists
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
                        'Ordernum': {
                            field: 'Ordernum',
                            defaultValue: ''
                        },
                        'OrderStatus': {
                            field: 'OrderStatus',
                            defaultValue: ''
                        },
                    }
                }
            },
        },
        dataSource = new kendo.data.DataSource({
            pageSize: 50
        }),
        orderListsModel = kendo.observable({
            dataSource: dataSource,
            _dataSourceOptions: dataSourceOptions,
            _jsdoOptions: jsdoOptions,
            itemClick: function(e) {
                app.mobileApp.navigate('#components/orderLists/details.html?uid=' + e.dataItem.uid);
            },
            detailsShow: function(e) {
                var item = e.view.params.uid,
                    dataSource = orderListsModel.get('dataSource'),
                    itemModel = dataSource.getByUid(item);
                if (!itemModel.Ordernum) {
                    itemModel.Ordernum = String.fromCharCode(160);
                }
                orderListsModel.set('currentItem', itemModel);
            },
            currentItem: null
        });

    if (typeof dataProvider.sbProviderReady === 'function') {
        dataProvider.sbProviderReady(function dl_sbProviderReady() {
            parent.set('orderListsModel', orderListsModel);
        });
    } else {
        parent.set('orderListsModel', orderListsModel);
    }
    parent.set('onShow', function() {
        dataProvider.loadCatalogs().then(function _catalogsLoaded() {
            var jsdoOptions = orderListsModel.get('_jsdoOptions'),
                jsdo = new progress.data.JSDO(jsdoOptions),
                dataSourceOptions = orderListsModel.get('_dataSourceOptions'),
                dataSource;

            dataSourceOptions.transport.jsdo = jsdo;
            dataSource = new kendo.data.DataSource(dataSourceOptions);
            orderListsModel.set('dataSource', dataSource);
        });
    });

})(app.orderLists);

// START_CUSTOM_CODE_orderListsModel
// Add custom code here. For more information about custom code, see http://docs.telerik.com/platform/screenbuilder/troubleshooting/how-to-keep-custom-code-changes

// you can handle the beforeFill / afterFill events here. For example:
/*
app.orderLists.orderListsModel.get('_jsdoOptions').events = {
    'beforeFill' : [ {
        scope : app.orderLists.orderListsModel,
        fn : function (jsdo, success, request) {
            // beforeFill event handler statements ...
        }
    } ]
};
*/
// END_CUSTOM_CODE_orderListsModel