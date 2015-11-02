'use strict';

app.salesrepListView = kendo.observable({
    onShow: function() {},
    afterShow: function() {}
});

// START_CUSTOM_CODE_salesrepListView
// END_CUSTOM_CODE_salesrepListView
(function(parent) {
    var dataProvider = app.data.sports2000New,
        processImage = function(img) {
            if (!img) {
                var empty1x1png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQI12NgYAAAAAMAASDVlMcAAAAASUVORK5CYII=';
                img = 'data:image/png;base64,' + empty1x1png;
            } else if (img.slice(0, 4) !== 'http' &&
                img.slice(0, 2) !== '//' &&
                img.slice(0, 5) !== 'data:') {
                var setup = dataProvider.setup;
                img = setup.scheme + ':' + setup.url + setup.apiKey + '/Files/' + img + '/Download';
            }

            return img;
        },
        jsdoOptions = {
            name: 'salesrep',
            autoFill: false
        },
        dataSourceOptions = {
            type: 'jsdo',
            transport: {},

            change: function(e) {
                var data = this.data();
                for (var i = 0; i < data.length; i++) {
                    var dataItem = data[i];

                    dataItem['SalesRepUrl'] =
                        processImage(dataItem['SalesRep']);

                    flattenLocationProperties(dataItem);
                }
            },
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
        salesrepListViewModel = kendo.observable({
            dataSource: dataSource,
            dataSourceOptions: dataSourceOptions,
            jsdoOptions: jsdoOptions
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

})(app.salesrepListView);

// START_CUSTOM_CODE_salesrepListViewModel
// you can handle the beforeFill / afterFill events here. For example:
/*
app.salesrepListView.salesrepListViewModel.jsdoOptions.events = {
    'beforeFill' : [ {
        scope : app.salesrepListView.salesrepListViewModel,
        fn : function (jsdo, success, request) {
            // beforeFill event handler statements ...
        }
    } ]
};
*/
// END_CUSTOM_CODE_salesrepListViewModel