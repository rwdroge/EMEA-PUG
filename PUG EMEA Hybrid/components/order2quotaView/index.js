'use strict';

app.order2quoteView= kendo.observable({
    onShow: function() {},
    afterShow: function() {}
});

(function(parent) {
    var dataProvider = app.data.sports2000New,
        jsdoOptions = {
            name: 'salesrep',
            autoFill: false
        },
        dataSourceOptions = {
            type: 'jsdo',
            transport: {},
            schema: {
                model: {
                    fields: {
                        'RepName': {
                            field: 'RepName',
                            defaultValue: ''
                        },
                        'Email': {
                            field: 'Email',
                            defaultValue: ''
                        },
                        'SalesRep': {
                            field: 'SalesRep',
                            defaultValue: ''
                        },
                    }
                }
            },
        },
        dataSource = new kendo.data.DataSource({
            pageSize: 50
        }),
        order2quoteViewModel = kendo.observable({
            dataSource: dataSource,
            dataSourceOptions: dataSourceOptions,
            jsdoOptions: jsdoOptions,
            itemClick: function(e) {
                app.mobileApp.navigate('#components/salesrepListView/details.html?uid=' + e.dataItem.uid);
            },
            detailsShow: function(e) {
                var item = e.view.params.uid,
                    dataSource = salesrepListViewModel.get('dataSource'),
                    itemModel = dataSource.getByUid(item);
                itemModel.ImageUrl = processImage(itemModel.Image);
                if (!itemModel.RepName) {
                    itemModel.RepName = String.fromCharCode(160);
                }
                salesrepListViewModel.set('currentItem', itemModel);
            },
            currentItem: null
        });

    parent.set('salesrepListViewModel', salesrepListViewModel);
    parent.set('onShow', function() {
        dataProvider.loadCatalogs().then(function _catalogsLoaded() {
            var jsdoOptions = salesrepListViewModel.get('jsdoOptions').toJSON(),
                jsdo = new progress.data.JSDO(jsdoOptions),
                dataSourceOptions = salesrepListViewModel.get('dataSourceOptions').toJSON(),
                dataSource;

            dataSourceOptions.transport.jsdo = jsdo;
            dataSource = new kendo.data.DataSource(dataSourceOptions);
            salesrepListViewModel.set('dataSource', dataSource);
        });
    });

})(app.order2quoteView);

