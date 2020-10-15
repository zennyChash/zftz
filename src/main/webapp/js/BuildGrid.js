function buildGrid(gid,ds,ssm,rowid,fn){
	Ext.Ajax.request({
		url: '../xmgl/getGridInfo?gid='+gid,
		method : 'get',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		success : function(response, options) {
		   	var go = Ext.util.JSON.decode(response.responseText);
			if(go){
				var cstore, ccm;
				ds.removeAll();
				var rRd = Ext.data.Record.create(go.retData.records);
				ds.reader = new Ext.data.JsonReader({
					idProperty: rowid,
					root: 'retData.rows',
					totalProperty: 'retData.totalCount'
				}, rRd);
				ds.reader.recordType = rRd;
				ds.fields = rRd.prototype.fields;
				var cols = go.retData.columns;
				for(var i = 0;i<cols.length;i++){
					var col = cols[i];
					if(typeof col.renderer == "string"){
						col.renderer = eval(col.renderer);
					}
					if(col.hasOwnProperty("editorType")){
						var edtCb = null;
						if(col.editorType==1){//numberfield
							var commontIntFld = new Ext.form.NumberField({selectOnFocus:true,maxLength:9,decimalPrecision:0});
							edtCb = new Ext.grid.GridEditor(commontIntFld);
						}else if(col.editorType==2){
							var commontDoubleFld = new Ext.form.NumberField({selectOnFocus:true,maxLength:16,decimalPrecision:4});
							edtCb = new Ext.grid.GridEditor(commontDoubleFld);
						}else if(col.editorType==9){//datefield
							var df = col.dtFormat;
							var commonDateFld = new Ext.form.DateField({
								format: df?df:'Y-m-d'
							});
							edtCb = new Ext.grid.GridEditor(commonDateFld);
						}else{
							var commonTextFld = new Ext.form.TextField({selectOnFocus : true,maxLength : 200});
							edtCb = new Ext.grid.GridEditor(commonTextFld);
						}
						col.editor=edtCb; 
					}
				}
				if(ssm){
					if(go.retData.isLockView){
						ccm = new Ext.ux.grid.LockingColumnModel({
							columns: [ssm].concat(cols)
						});
					}else{
						ccm = new Ext.grid.ColumnModel({
							columns: [ssm].concat(cols)
						});
					}
				}else{
					if(go.retData.isLockView){
						ccm = new Ext.ux.grid.LockingColumnModel({
							columns: cols
						});
					}else{
						ccm = new Ext.grid.ColumnModel({
							columns: cols
						});
					}
				}
				cstore= ds;
				Ext.getCmp(gid).reconfigure(cstore,ccm);
				if(Ext.isFunction(fn)){
					fn();
				}
			}
		},
	  	failure : function() {
	  	}
	});
}
function buildNopagingGrid(gid,ds,ssm,rowid,fn){	
	Ext.Ajax.request({
		url: '../xmgl/getGridInfo?gid='+gid,
		method : 'get',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		success : function(response, options) {
			var go = Ext.decode(data);
			if(go){
				var cstore, ccm;
				ds.removeAll();
				var rRd = Ext.data.Record.create(go.retData.records);
				ds.reader = new Ext.data.JsonReader({
				}, rRd);
				var cols = go.retData.columns;
				for(var i = 0;i<cols.length;i++){
					var col = cols[i];
					if(typeof col.renderer == "string"){
						col.renderer = eval(col.renderer);
					}
					if(col.editorType){
						var edtCb = null;
						if(col.editorType==1){//numberfield
							var commontIntFld = new Ext.form.NumberField({selectOnFocus:true,maxLength:9,decimalPrecision:0});
							edtCb = new Ext.grid.GridEditor(commontIntFld);
						}else if(col.editorType==2){
							var commontDoubleFld = new Ext.form.NumberField({selectOnFocus:true,maxLength:16,decimalPrecision:4});
							edtCb = new Ext.grid.GridEditor(commontDoubleFld);
						}else if(col.editorType==9){//datefield
							var df = col.dtFormat;
							var commonDateFld = new Ext.form.DateField({
								format: df
							});
							edtCb = new Ext.grid.GridEditor(commonDateFld);
						}else{
							var commonTextFld = new Ext.form.TextField({selectOnFocus : true,maxLength : 200});
							edtCb = new Ext.grid.GridEditor(commonTextFld);
						}
						col.editor=edtCb; 
					}
				}
				if(ssm){
					if(go.retData.isLockView){
						ccm = new Ext.ux.grid.LockingColumnModel({
							columns: [ssm].concat(cols)
						});
					}else{
						ccm = new Ext.grid.ColumnModel({
							columns: [ssm].concat(cols)
						});
					}
				}else{
					if(go.retData.isLockView){
						ccm = new Ext.ux.grid.LockingColumnModel({
							columns: cols
						});
					}else{
						ccm = new Ext.grid.ColumnModel({
							columns: cols
						});
					}
				}
				cstore= ds;
				Ext.getCmp(gid).reconfigure(cstore,ccm);
				if(Ext.isFunction(fn)){
					fn();
				}
			}
		}
	});
}