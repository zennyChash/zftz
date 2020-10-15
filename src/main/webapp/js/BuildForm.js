function buildForm(fid,config,form2Build,fn){
	Ext.Ajax.request({
		url: '../xmgl/getFormInfo?fid='+fid,
		method : 'get',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		success : function(response, options) {
		   	var fo = Ext.util.JSON.decode(response.responseText);
			if(fo){
				var flds = fo.retData.items;
				config = config || {};
				config = Ext.apply({
					id: fid,
					frame: true,
					labelWidth: 80,
					width :120,
					labelAlign: 'right'
				},config);
				var tmpFlds = new Array();
				for(var i=0;i<fitems.length;i++){
					if(typeof fitems[i] == "string"){
						tmpFlds.push(eval(fitems[i]));
					}else{
						if(fitems[i].layout&&fitems[i].layout=="column"){
							var citems = fitems[i].items;
							for(var j=0;j<citems.length;j++){
								var col = citems[j];
								var cis = col.items;
								var tmpColItems = new Array();
								for(var k=0;k<cis.length;k++){
									if(typeof cis[k] == "string"){
										tmpColItems.push(eval(cis[k]));
									}else{
										tmpColItems.push(cis[k]);
									}
								}
								col.items=tmpColItems;
							}
							tmpFlds.push(fitems[i]);
						}else{
							tmpFlds.push(fitems[i]);
						}
					}
				}
				config.items = tmpFlds;
			}
			window[form2Build] = new Ext.FormPanel(config);
			if(Ext.isFunction(fn)){
				//fn(this.edtForm);
				fn(window[form2Build]);
			}
		}
	});
}