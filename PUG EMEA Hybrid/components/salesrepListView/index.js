'use strict';

app.salesrepListView = kendo.observable({
	onShow: function () {},
	afterShow: function () {}
});

// START_CUSTOM_CODE_salesrepListView
// END_CUSTOM_CODE_salesrepListView
(function (parent) {
	var dataProvider = app.data.sports2000,
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
			detailsShow: function (e) {
				var item = e.view.params.uid,
					dataSource = salesrepListViewModel.get('dataSource'),
					itemModel = dataSource.getByUid(item);
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
				//call the camera plugin to take picture
				navigator.camera.getPicture(function (result) {
					//on success update the Image of the current item
					salesrepListViewModel.set('currentItem.Image', result);
				}, function (error) {
					//on fail print out an error message
					alert("Failed to take picture:" + error);
				}, {
					quality: 50,
					destinationType: navigator.camera.DestinationType.DATA_URL
				});
			},
			
			saveCurrentItem(event) {
				debugger;
				event.preventDefault();
				this.dataSource.sync();
			},
			cancelCurrentItemChanges() {
				
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

