'use strict';

app.order2quotaView= kendo.observable({
    onShow: function() {},
    afterShow: function() {}
});

(function(parent) {
    var dataProvider = app.data.sports2000,
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
        order2quotaViewModel = kendo.observable({
            dataSource: dataSource,
            dataSourceOptions: dataSourceOptions,
            jsdoOptions: jsdoOptions,
            isVisible: true,
            onSeriesHover: function(e) {
                 kendoConsole.log(kendo.format("event :: seriesHover ({0} : {1})", e.series.name, e.value));
            },
            electricity: new kendo.data.DataSource({
                transport: {
                    read: {
                        url: "../content/dataviz/js/spain-electricity.json",
                        dataType: "json"
                    }
                },
                sort: {
                    field: "year",
                    dir: "asc"
                }
            })
        });
        kendo.bind($("#example"), order2quotaViewModel);
    }
	parent.set('order2quotaViewModel', order2quotaViewModel);
    parent.set('onShow', function() {
        dataProvider.loadCatalogs().then(function _catalogsLoaded() {
            var jsdoOptions = order2quotaViewModel.get('jsdoOptions').toJSON(),
                jsdo = new progress.data.JSDO(jsdoOptions),
                dataSourceOptions = order2quotaViewModel.get('dataSourceOptions').toJSON(),
                dataSource;

            dataSourceOptions.transport.jsdo = jsdo;
            dataSource = new kendo.data.DataSource(dataSourceOptions);
            order2quotaViewModel.set('dataSource', dataSource);
        });
    });

})(app.order2quotaView);

