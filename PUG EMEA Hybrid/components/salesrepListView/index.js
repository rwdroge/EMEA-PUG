'use strict';

app.salesrepListView = kendo.observable({
	onShow: function () {},
	afterShow: function () {}
});

// START_CUSTOM_CODE_salesrepListView
// END_CUSTOM_CODE_salesrepListView
(function (parent) {
	var dataProvider = app.data.sports2000New,
		jsdoOptions = {
			name: 'salesrep',
			autoFill: false
		},
		dataSourceOptions = {
			type: 'jsdo',
			transport: {},

			change: function (e) {
				var data = this.data();
				for (var i = 0; i < data.length; i++) {
					var dataItem = data[i];

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
			jsdoOptions: jsdoOptions,
			itemClick: function (e) {
				app.mobileApp.navigate('#components/salesrepListView/details.html?uid=' + e.dataItem.uid);
			},
			photoAs64: function (e) {
				return "data:image/jpeg;base64," + this.get(e);
			},
			detailsShow: function (e) {
				var item = e.view.params.uid,
					dataSource = salesrepListViewModel.get('dataSource'),
					itemModel = dataSource.getByUid(item);
				console.log(itemModel.Image);
				itemModel.ImageUrl = "data:image/png;base64," + itemModel.Image;
				if (!itemModel.RepName) {
					itemModel.RepName = String.fromCharCode(160);
				}
				salesrepListViewModel.set('currentItem', itemModel);
			},
			currentItem: null,
			getSelectedImageSrc: function () {
				return "data:image/jpeg;base64," + this.get('currentItem.Image');
			},
			takePicture() {
				alert("piiiiiiccccccaaaacchoooooo");

				//call camera here
				//camera.takePicture( function(res) { salesrepListViewModel.set('currentItem.Image', imgVal); } );

			}
		});

	parent.set('salesrepListViewModel', salesrepListViewModel);
	parent.set('onShow', function () {
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