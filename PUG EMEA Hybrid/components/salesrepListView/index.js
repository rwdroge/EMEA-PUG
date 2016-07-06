'use strict';

app.salesrepListView = kendo.observable({
    onShow: function() {},
    afterShow: function() {}
});

// START_CUSTOM_CODE_salesrepListView

(function(parent) {
    var dataProvider = app.data.sports2000New,
        fetchFilteredData = function(paramFilter, searchFilter) {
            var model = parent.get('salesrepListViewModel'),
                dataSource = model.get('dataSource');

            if (paramFilter) {
                model.set('paramFilter', paramFilter);
            } else {
                model.set('paramFilter', undefined);
            }

            if (paramFilter && searchFilter) {
                dataSource.filter({
                    logic: 'and',
                    filters: [paramFilter, searchFilter]
                });
            } else if (paramFilter || searchFilter) {
                dataSource.filter(paramFilter || searchFilter);
            } else {
                dataSource.filter({});
            }
        },
        processImage = function(img) {

            if (!img) {
                var empty1x1png = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQI12NgYAAAAAMAASDVlMcAAAAASUVORK5CYII=';
                img = 'data:image/png;base64,' + empty1x1png;
            }
			img = 'data:image/png;base64,' + img;
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

                    dataItem['ImageUrl'] =
                        processImage(dataItem['Image']);

                }
            },
            error: function(e) {

                if (e.xhr) {
                    alert(JSON.stringify(e.xhr));
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
                        'Image': {
                            field: 'Image',
                            defaultValue: ''
                        },
                    }
                }
            },
            serverFiltering: true,
        },
        dataSource = new kendo.data.DataSource({
            pageSize: 50
        }),
        salesrepListViewModel = kendo.observable({
            dataSource: dataSource,
            _dataSourceOptions: dataSourceOptions,
            _jsdoOptions: jsdoOptions,
            fixHierarchicalData: function(data) {
                var result = {},
                    layout = {};

                $.extend(true, result, data);

                (function removeNulls(obj) {
                    var i, name,
                        names = Object.getOwnPropertyNames(obj);

                    for (i = 0; i < names.length; i++) {
                        name = names[i];

                        if (obj[name] === null) {
                            delete obj[name];
                        } else if ($.type(obj[name]) === 'object') {
                            removeNulls(obj[name]);
                        }
                    }
                })(result);

                (function fix(source, layout) {
                    var i, j, name, srcObj, ltObj, type,
                        names = Object.getOwnPropertyNames(layout);

                    for (i = 0; i < names.length; i++) {
                        name = names[i];
                        srcObj = source[name];
                        ltObj = layout[name];
                        type = $.type(srcObj);

                        if (type === 'undefined' || type === 'null') {
                            source[name] = ltObj;
                        } else {
                            if (srcObj.length > 0) {
                                for (j = 0; j < srcObj.length; j++) {
                                    fix(srcObj[j], ltObj[0]);
                                }
                            } else {
                                fix(srcObj, ltObj);
                            }
                        }
                    }
                })(result, layout);

                return result;
            },
            itemClick: function(e) {
                var dataItem = e.dataItem || salesrepListViewModel.originalItem;

                app.mobileApp.navigate('#components/salesrepListView/details.html?uid=' + dataItem.uid);

            },
            editClick: function() {
                var uid = this.originalItem.uid;
                app.mobileApp.navigate('#components/salesrepListView/edit.html?uid=' + uid);
            },
            detailsShow: function(e) {
                salesrepListViewModel.setCurrentItemByUid(e.view.params.uid);
            },
            setCurrentItemByUid: function(uid) {
                var item = uid,
                    dataSource = salesrepListViewModel.get('dataSource'),
                    itemModel = dataSource.getByUid(item);
                itemModel.ImageUrl = processImage(itemModel.Image);

                if (!itemModel.RepName) {
                    itemModel.RepName = String.fromCharCode(160);
                }

                salesrepListViewModel.set('originalItem', itemModel);
                salesrepListViewModel.set('currentItem',
                    salesrepListViewModel.fixHierarchicalData(itemModel));

                return itemModel;
            },
            linkBind: function(linkString) {
                var linkChunks = linkString.split('|');
                if (linkChunks[0].length === 0) {
                    return this.get("currentItem." + linkChunks[1]);
                }
                return linkChunks[0] + this.get("currentItem." + linkChunks[1]);
            },
            imageBind: function(imageField) {
                if (imageField.indexOf("|") > -1) {
                    return processImage(this.get("currentItem." + imageField.split("|")[0]));
                }
                return processImage(imageField);
            },
            currentItem: {}
        });

    parent.set('editItemViewModel', kendo.observable({
        editFormData: {},
        onShow: function(e) {
            var itemUid = e.view.params.uid,
                dataSource = salesrepListViewModel.get('dataSource'),
                itemData = dataSource.getByUid(itemUid),
                fixedData = salesrepListViewModel.fixHierarchicalData(itemData);

            this.set('itemData', itemData);
            this.set('editFormData', {
                textField: itemData.RepName,
                image: itemData.ImageUrl,
            });
        },
        linkBind: function(linkString) {
            var linkChunks = linkString.split(':');
            return linkChunks[0] + ':' + this.get("itemData." + linkChunks[1]);
        },
        onSaveClick: function(e) {
            var editFormData = this.get('editFormData'),
                itemData = this.get('itemData'),
                dataSource = salesrepListViewModel.get('dataSource');
			// prepare edit
            itemData.set('RepName', editFormData.textField);
            
            dataSource.one('sync', function(e) {
                app.mobileApp.navigate('#:back');
            });

            dataSource.one('error', function() {
                dataSource.cancelChanges(itemData);
            });

            dataSource.sync();
        },
        takePicture: function(e) {
            var editFormData = this.get('editFormData'),
            itemData = this.get('itemData');
            console.log(editFormData);
            //call the camera plugin to take picture
            navigator.camera.getPicture(function (result) {
                itemData.set('Image', result);
                var result2 = processImage(result);
            	//on success update the Image of the current item
            	editFormData.set('image', result2);
    		}, function (error) {
     			//on fail print out an error message
     			alert("Failed to take picture:" + error);
    		}, {
     		quality: 50,
     		destinationType: navigator.camera.DestinationType.DATA_URL,
            targetWidth: 250,
            targetHeight: 250
    		});
    	}
    }));

    if (typeof dataProvider.sbProviderReady === 'function') {
        dataProvider.sbProviderReady(function dl_sbProviderReady() {
            parent.set('salesrepListViewModel', salesrepListViewModel);
        });
    } else {
        parent.set('salesrepListViewModel', salesrepListViewModel);
    }

    parent.set('onShow', function(e) {
        var param = e.view.params.filter ? JSON.parse(e.view.params.filter) : null,
            isListmenu = false,
            backbutton = e.view.element && e.view.element.find('header [data-role="navbar"] .backButtonWrapper');

        if (param || isListmenu) {
            backbutton.show();
            backbutton.css('visibility', 'visible');
        } else {
            if (e.view.element.find('header [data-role="navbar"] [data-role="button"]').length) {
                backbutton.hide();
            } else {
                backbutton.css('visibility', 'hidden');
            }
        }

        dataProvider.loadCatalogs().then(function _catalogsLoaded() {
            var jsdoOptions = salesrepListViewModel.get('_jsdoOptions'),
                jsdo = new progress.data.JSDO(jsdoOptions),
                dataSourceOptions = salesrepListViewModel.get('_dataSourceOptions'),
                dataSource;

            dataSourceOptions.transport.jsdo = jsdo;
            dataSource = new kendo.data.DataSource(dataSourceOptions);
            salesrepListViewModel.set('dataSource', dataSource);

            fetchFilteredData(param);
        });
    });

})(app.salesrepListView);
// END_CUSTOM_CODE_salesrepListView

// START_CUSTOM_CODE_salesrepListViewModel
// Add custom code here. For more information about custom code, see http://docs.telerik.com/platform/screenbuilder/troubleshooting/how-to-keep-custom-code-changes

// you can handle the beforeFill / afterFill events here. For example:
/*
app.salesrepListView.salesrepListViewModel.get('_jsdoOptions').events = {
    'beforeFill' : [ {
        scope : app.salesrepListView.salesrepListViewModel,
        fn : function (jsdo, success, request) {
            // beforeFill event handler statements ...
        }
    } ]
};
*/
// END_CUSTOM_CODE_salesrepListViewModel