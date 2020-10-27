<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.fwiz.utils.*"%>
<%
	Configuration cg = (Configuration)ContextUtil.getBean("config");
%>
<html>
<head>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate">
<META HTTP-EQUIV="expires" CONTENT="Wed, 26 Feb 1997 08:21:57 GMT">
<META HTTP-EQUIV="expires" CONTENT="0">
<title>项目基础信息维护</title>
<style type="text/css">
.x-grid3-cell-text-visible .x-grid3-cell-inner{overflow:visible;padding:3px 3px 3px 5px;white-space:normal;}
</style>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/libs/ext-3.4.0/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/dfCommon.css" />
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/ext-all-debug.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/src/locale/ext-lang-zh_CN.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/Ext.ux.tree.TreeCheckNodeUI.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/GridExporter.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/ExportGridPanel.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/BuildGrid.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/BuildForm.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/dfCommon.js"></script>
<script type="text/javascript"> 
/*
 * Ext JS Library 3.4.0
 * Copyright(c) 2006-2008, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */
var PAGE_SIZE = <%=cg.getString("pageSize", "40")%>;
var cProRd ,cTzms,cFld,RemovedEns = new Array();
var LockInfo = new Object();
var ssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
ssm.handleMouseDown = Ext.emptyFn;
var ccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var proRd = Ext.data.Record.create([]);
var ds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryListPaging',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows',
		totalProperty: 'retData.totalCount'
	}, proRd)
});
ds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var pname = Ext.getCmp('fltPname').getValue();
	var p = {pname: pname?pname:""};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	ds.baseParams={
		jsonData: Ext.encode({
			dataID : 'projectsMaintain',
			queryParams : jparams
		})
	};
});
var grid = new Ext.grid.GridPanel({
	id:'projectsMaintain',
	title:'',
	store: ds,
	cm: ccm,
	selModel: ssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	tbar:[
	{
		xtype: 'label',
		text :'项目名称：'
	},{
		xtype:'textfield',
		fieldLabel:'名称',
		width:150,
		enableKeyEvent:true,
		id: 'fltPname',
		hideLabel:true
	},{
		text: '搜索',
		iconCls: 'filter',
		handler : function(){
			ds.load({params:{start:0,limit:PAGE_SIZE}});
		}
	},new Ext.Toolbar.Separator(),{
		text: '详情',
		iconCls: 'details',
		handler : function(){
			var rds = grid.getSelectionModel().getSelections();
			if(!rds||rds.length<1){
				Ext.Msg.alert("提示","请先选择项目！");
				return;
			}
			cProRd = rds[0];
			cTzms = rds[0].get("tzmode")?rds[0].get("tzmode"):"01";
			proWin.show();
		}
	}],
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: ds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});

var entypeRd = Ext.data.Record.create([
    {name : 'bm',type : 'string'}, 
    {name : 'mc',type : 'string'}
]);

var etypeDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, entypeRd)
});
etypeDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_ENTYPE'}
	}
	etypeDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
etypeDs.load({});

var etypeCb = new Ext.form.ComboBox({
	displayField : 'mc',
	valueField : 'bm',
	typeAhead : true,
	mode : 'local',
	triggerAction : 'all',
	emptyText : '单位类型',
	selectOnFocus : true,
	editable : false,
	store : etypeDs
});
//项目相关企业grid
var essm = new Ext.grid.CheckboxSelectionModel({singleSelect: false}); 
essm.handleMouseDown = Ext.emptyFn;
var eccm = new Ext.grid.ColumnModel({
	columns:[
	essm,
   	{
   		header: "单位类型",
   		dataIndex: 'entype',
   		width: 150,
   		align: 'left',
   		editor : etypeCb,
   		renderer : function(v, p, r) {
			var index = etypeDs.find('bm', v);
			var cbRec = etypeDs.getAt(index);
			var newval= v;
			if (cbRec) {
				newval= cbRec.data.mc;
			} 
			return renderFoo(newval,p,r);
		}
   	},{
   	    header: "单位名称",
   	    dataIndex: 'ename',
   	    width: 200,
   	    align:'left',
   	 	editor: new Ext.form.TextField({selectOnFocus:true,maxLength:190})  
   	},{
   	    header: "备注",
   	    dataIndex: 'remark',
   	    width: 300,
   	    align:'left',
   	 	editor: new Ext.form.TextField({selectOnFocus:true,maxLength:240})  
   	}],
	defaultSortable: true
});
var eRd = Ext.data.Record.create([
    {name: 'id', type: 'int'},
	{name: 'entype', type: 'string'},
	{name: 'ename', type: 'string'},
	{name: 'remark', type: 'string'}
]);
var eds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	pruneModifiedRecords:true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows'
	}, eRd)
});
eds.on("beforeload",function(store,options){
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("id");
	var p = {proid: proid};
	var jparams = {
		qParams: p
	}
	eds.baseParams={
		jsonData: Ext.encode({
			dataID : 'proRltEns',
			queryParams : jparams
		})
	};
});
var engrid = new Ext.grid.EditorGridPanel({
	id:'proRltEns',
	title:'项目相关单位',
	store: eds,
	cm: eccm,
	selModel: essm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	clicksToEdit:1,
	enableColumnMove: false,
	tbar:[{
		text: '添加行',
		id:'btn_proEn_add',
		iconCls: 'add',
		handler : function(){
			if(LockInfo.proRltEns=="1"){
				return;
			}
		    var en = new eRd({
		    	id: -1,
		    	entype: '01',
		    	ename: '',
		    	remark: ''
		    });
		    engrid.stopEditing();
		    eds.insert(eds.getCount(), en);
		}
	},{
		text: '删除',
		id:'btn_proEn_remove',
		iconCls: 'remove',
		handler :function(){
			if(LockInfo.proRltEns=="1"){
				return;
			}
		    var records = engrid.getSelectionModel().getSelections();
		    if(!records||records.length<1){
				Ext.Msg.alert("提示","请先选择要删除的行!");
				return;
			}	
			if(records){
				for(var rc=0;rc<records.length;rc++){						    	    	
					eds.remove(records[rc]);
					//只记录非本次新增行的删除
					if(records[rc].get("id")!=-1){
						RemovedEns.push(records[rc].get("id"));
					}
				}
				
		    }
		}
	},{
		text: '保存',
		iconCls: 'Save',
		id: 'btn_proEn_save',
		handler : function(){
			if(LockInfo.proRltEns=="1"){
				return;
			}
			saveRltEns(false);
		}
	}]
});
engrid.on('beforeedit',function(e){ 
	//如果是已经锁定的，不能修改
	if(LockInfo.proRltEns=="1"){
		e.cancel = true;
	}
});

function saveRltEns(silent){
	var cEns = buildRltEnsInfo();
	if(!cEns.removedEns&&!cEns.modifiedEns&&!cEns.newEns){
		return;
	}
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("id");
	Ext.getBody().mask('正在保存……');
	Ext.Ajax.request({
		url: '../xmgl/saveRltEns',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			proid : proid,
			rowsInfo: Ext.encode(cEns)
		}),
		success : function(response, options) {
			Ext.getBody().unmask();
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		if(!silent){
		   			Ext.Msg.show({
			   		   title:'信息',
			   		   msg: "项目关联企业已保存！",
			   		   buttons: Ext.Msg.OK
			   		});
		   		}
		   		RemovedEns = new Array();
				eds.commitChanges();
				eds.load({});
		   	}else if(o&&o.retCode!="0"){
		   		Ext.Msg.alert('错误',"保存项目关联企业时发生错误！"+o&&o.retMsg?o.retMsg:"");
		   	}else{
		   		Ext.Msg.alert('错误',"保存项目关联企业时发生错误！");
		   	}
		},
		failure : function(response,options) {
			Ext.Msg.alert('错误',"保存项目关联企业时发生错误，详细错误请咨询管理员！");
			Ext.getBody().unmask();
	  	}
	});
}
function buildRltEnsInfo(){
	var mEns = new Array();
	var newEns = new Array();
	//修改
	for(var i=0;i<eds.getModifiedRecords().length;i++){
		var r = eds.getModifiedRecords()[i];
		//只记录非本次新增行、发生变动的字段，名值对形式的object
		if(r.get("id")!=-1){
			var o = r.getChanges();
			o.id = r.get("id");
			mEns.push(o);
		}
	}
	//新增
	for(var i=0;i<eds.getCount();i++){
		var r = eds.getAt(i);
		//记录本次新增行
		if(r.get("id")==-1){
			newEns.push(r.data);
		}
	}
	var changedEns ={
		removedEns : RemovedEns.length>0?Ext.encode(RemovedEns):"",
		modifiedEns: mEns.length>0?Ext.encode(mEns):"",
		newEns: newEns.length>0?Ext.encode(newEns):""
	};
	return changedEns;
}
//概算
//概算form
var gsform = new Ext.FormPanel({    
	frame: true,
	labelWidth: 140,
	border: false,
	trackResetOnLoad:true,
	buttonAlign: 'center',
	items:[
	{
		xtype:'textfield',
		name:'gspf_filename',
		fieldLabel: '概算批复文件名称',
		width:200,
		maxLength :300
	},{
		xtype:'textfield',
		name: 'gspf_fileno',
		fieldLabel: '概算批复文件文号',
		width:200,
		maxLength :200
	}]
});

//概算grid
var gssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
gssm.handleMouseDown = Ext.emptyFn;
var gccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var gRd = Ext.data.Record.create([]);
var gds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty: 'iid',
		root: 'retData.rows'
	}, gRd)
});
gds.on("beforeload",function(store,options){
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("id");
	var p = {proid: proid};
	var jparams = {
		qParams: p
	}
	gds.baseParams={
		jsonData: Ext.encode({
			dataID : 'proGaisuan',
			queryParams : jparams
		})
	};
});
gds.on("load",function(){
	var sum=0,cc = gds?gds.getCount():0;
	for(var i=0;i<cc;i++){
		var rd = gds.getAt(i);
		if(rd.get("isleaf")==1){
			sum = sum + (rd.get("je")?rd.get("je"):0);
		}
	}
	var dt = new gRd({
		id: -100,
		piid: '',
		iid:'-100',
		iname: '合计',
		je: sum,
		remark: ''
    });
	gsgrid.stopEditing();
    gds.insert(0, dt);
    gds.commitChanges();
})
var gsgrid = new Ext.grid.EditorGridPanel({
	id:'proGaisuan',
	title:'',
	store: gds,
	cm: gccm,
	selModel: gssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	clicksToEdit:1,
	enableColumnMove: false,
	tbar:[
	{
		text: '保存',
		iconCls: 'Save',
		id:'btn_gaisuan_save',
		handler : function(){
			if(LockInfo.proGaisuan=="1"){
				return;
			}
			saveGaisuan(false);
		}
	}]
});
gsgrid.on('beforeedit',function(e){ 
	//如果是已经锁定的，不能修改
	if(LockInfo.proGaisuan=="1"){
		e.cancel = true;
	}
	var rd = e.record;
	var fld = e.field;
	if(rd.get("id")==-100||rd.get("isleaf")!=1){//合计行、非底级行不可编辑
		e.cancel = true;  
	}
});
gsgrid.on("afteredit", function(e){	
	var rd = e.record;
	if(e.field=="je"){
		var nv=	Number(e.value?e.value:0); 
		var ov=	Number(e.originalValue?e.originalValue:0);
		var delta = nv-ov;
		calMoney(delta,rd);
	}
});
function calMoney(delta,rd){
	var newid = rd.get("piid");
	var newrd ;
	if(!newid||newid==""){
		return;
	}else if(newid=='-100'){
		newrd = gds.getAt(0);
	}else{
		newrd = gds.getById(newid);
	}
	newrd.set("je",newrd.get("je")+delta);
	calMoney(delta,newrd);
}
function saveGaisuan(silent){
	var gsRows = buildGsInfo();
	if(gsRows.modified==0){
		return;
	}
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("id");
	Ext.getBody().mask('正在保存……');
	Ext.Ajax.request({
		url: '../xmgl/saveGaisuan',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			proid : proid,
			rowsInfo: Ext.encode(gsRows)
		}),
		success : function(response, options) {
			Ext.getBody().unmask();
			var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		if(!silent){
			   		Ext.Msg.show({
			   		   title:'信息',
			   		   msg: "项目概算信息已保存！",
			   		   buttons: Ext.Msg.OK
			   		});
		   		}
				gds.commitChanges();
				gds.load({});
		   	}else if(o&&o.retCode!="0"){
		   		Ext.Msg.alert('错误',"保存项目概算信息时发生错误！"+o&&o.retMsg?o.retMsg:"");
		   	}else{
		   		Ext.Msg.alert('错误',"保存项目概算信息时发生错误！");
		   	}
		},
		failure : function(response,options) {
			Ext.Msg.alert('错误',"保存项目概算信息时发生错误，详细错误请咨询管理员！");
			Ext.getBody().unmask();
	  	}
	});
}
function buildGsInfo(){
	var rds = new Array();
	//var cc = gds.getModifiedRecords();//取修改过的，后台检查id，-1的是之前没有的
	var cc = gds.getCount(); //全取，后台整批先删后增
	for(var i=0;i<cc;i++){
		var rd = gds.getAt(i);
		//合计行不提交
		if(rd.get("id")==-100){
			continue;
		}
		rds.push(rd.data);
	}
	var rows = {
		rows: rds.length>0?Ext.encode(rds):"",
		modified: gds.getModifiedRecords().length		
	}
	return rows;
}
//近期汇报材料
var jqzlform = new Ext.FormPanel({    
	frame: true,
	labelWidth: 40,
	border: false,
	fileUpload : true,
	layout:'column',
	items:[
	{
		columnWidth:.5,
		layout: 'form',
		items:[
		{
			name:'uploadFld',
			xtype:'hidden',
			value: 'jqhbcl'
		},{
			fieldLabel: '文件',
			inputType:'file',
			width:200,
			xtype: 'textfield',
			name: 'filepath',
			id: 'jqclfp'
		}]
	},{
		columnWidth:.5,
		layout: 'form',
		items:[{
			xtype:'button',
			id: 'btn_jqhbcl',
			text:"上传",
			handler:function(){
				var x=Ext.getCmp('jqclfp').getValue();
				var x = document.getElementById("jqclfp").value;
			    if(!x||x==''){
			      	Ext.Msg.alert("提示","请选择要导入的文件!");
			      	return;
			    }
			    uploadFile(jqzlform, 'jqhbcl',function(){
			    	//加载数据
					jds.load({params:{start:0, limit:PAGE_SIZE}});
					Ext.getCmp("jqclfp").setRawValue('');
			    });
			}
		}]
	}]
});
	
//汇报材料grid
var jssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
jssm.handleMouseDown = Ext.emptyFn;
var jccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var jRd = Ext.data.Record.create([]);
var jds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryListPaging',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows',
		totalProperty: 'retData.totalCount'
	}, jRd)
});
jds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("id");
	var p = {proid: proid,fld: 'jqhbcl'};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	jds.baseParams={
		jsonData: Ext.encode({
			dataID : 'proAttachFiles',
			queryParams : jparams
		})
	};
});
var jqzlgrid = new Ext.grid.GridPanel({
	id:'jqhbcl',
	title:'',
	store: jds,
	cm: jccm,
	selModel: jssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: jds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});

//各个项目字段的附件
//上部form
var uploadForm = new Ext.FormPanel({    
	frame: true,
	labelWidth: 40,
	border: false,
	fileUpload : true,
	layout:'column',
	items:[
	{
		columnWidth:.5,
		layout: 'form',
		items:[
		{
			fieldLabel: '文件',
			inputType:'file',
			width:200,
			xtype: 'textfield',
			name: 'filepath',
			id: 'attachFilePath'
		}]
	},{
		columnWidth:.5,
		layout: 'form',
		items:[{
			xtype:'button',
			id:'btn_commonUpload',
			text:"上传",
			handler:function(){
				var x=Ext.getCmp('attachFilePath').getValue();
				var x = document.getElementById("attachFilePath").value;
			    if(!x||x==''){
			      	Ext.Msg.alert("提示","请选择要导入的文件!");
			      	return;
			    }
			    uploadFile(uploadForm, cFld,function(){
			    	//加载数据
					ads.load({params:{start:0, limit:PAGE_SIZE}});
					Ext.getCmp("attachFilePath").setRawValue('');
			    });
			}
		}]
	}]
});
function uploadFile(ufm,rltFld,fn){
	Ext.Msg.wait("正在导入...");
    ufm.getForm().submit({
    	timeout: 10*60*1000,
    	url :'../xmgl/uploadAttachment',
		params:{
			uaParams: Ext.encode({module:'0', mkey :cProRd.get("id"), fld: rltFld})
		},
	    success: function(form, action) {
		    Ext.Msg.hide();
		    var obj = action.result;
		    Ext.Msg.hide();
		    if(obj&&obj.infos){
		       	Ext.Msg.alert('提示',obj.infos.msg);
			}else if(obj&&obj.errors){
				Ext.Msg.alert('提示',obj.errors.msg);
			}
		    if(Ext.isFunction(fn)){
				fn();
			}
	    },
		failure: function(form,action){
		    Ext.Msg.hide();
			var obj = action.result;
			if(obj&&obj.errors){
				Ext.Msg.hide();
				Ext.Msg.alert('提示',obj.errors.msg);
			}
		},
		exceptionHandler : function(msg){
			Ext.Msg.hide();
			Ext.Msg.alert('提示',msg);
			return ; 
		}
    });
}
//下部的grid
var accm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var aRd = Ext.data.Record.create([]);
var ads = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryListPaging',
        headers: { 
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows',
		totalProperty: 'retData.totalCount'
	}, aRd)
});
ads.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var p = {proid: cProRd.get("id"),fld: cFld};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	ads.baseParams={
		jsonData: Ext.encode({
			dataID : 'proAttachFiles',
			queryParams : jparams
		})
	};
});
var attachGrid = new Ext.grid.GridPanel({
	id:'attachFiles',
	title:'',
	store: ads,
	cm: accm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: ads,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
var cbRecord = Ext.data.Record.create([
	{name : 'bm',type : 'string'}, 
	{name : 'mc',type : 'string'}
]);
var tzmodeDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, cbRecord)
});
tzmodeDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_TZMS'}
	}
	tzmodeDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
tzmodeDs.load({});

var xmglDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, cbRecord)
});
xmglDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_XMGLFL'}
	}
	xmglDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
xmglDs.load({});

var xmqxDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, cbRecord)
});
xmqxDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_QX'}
	}
	xmqxDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
xmqxDs.load({});

var jsmsDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, cbRecord)
});
jsmsDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_JSMS'}
	}
	jsmsDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
jsmsDs.load({});

var progressDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, cbRecord)
});
progressDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_XMJD'}
	}
	progressDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
progressDs.load({});

var tzmodeCombo = new Ext.form.ComboBox({
	name : 'tzmodeCb',
	width : 150,
	hiddenName: 'tzmode',
	fieldLabel: "政府投资模式",
	displayField : 'mc',
    valueField : 'bm',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : tzmodeDs,
    listeners:{
    	beforeselect: function(combo, record, index){
			var msname = record.get("mc");
			var tzms =  record.get("bm");
			changeProForm(tzms);
		}
    }
});
function changeProForm(tzms){
	Ext.Msg.confirm('确认', '修改投资模式会改变窗体中的表单，当前修改将被刷新，是否继续？', function(btn){
    	if(btn == 'yes') {
    		if(tzms=="02"||tzms=="03"){
    			Ext.getCmp("xmjdCombo").hide();
    			Ext.getCmp("tzms1Form").hide();
    			Ext.getCmp("tzms2Form").show();
    		}else{
    			Ext.getCmp("xmjdCombo").show();
    			Ext.getCmp("tzms1Form").show();
    			Ext.getCmp("tzms2Form").hide();
    		}
    		pform1.getForm().findField("tzmode").setValue(tzms);
    		cTzms = tzms;
    	}else{
    		pform1.getForm().findField("tzmode").setValue(cTzms);
    	}
	});
}
/*var xmglflCombo = new Ext.form.ComboBox({
	name : 'xmglflCb',
	width : 150,
	hiddenName: 'xmglfl',
	fieldLabel: "项目管理分类",
	displayField : 'mc',
    valueField : 'bm',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : xmglDs
});*/
var xmqxCombo =new Ext.form.ComboBox({
	name : 'qxbmCb',
	width : 150,
	hiddenName: 'qxbm',
	fieldLabel: "项目所在区县",
	displayField : 'mc',
    valueField : 'bm',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : xmqxDs
});

var jsmsCombo =new Ext.form.ComboBox({
	name : 'jsmodeCb',
	width : 150,
	hiddenName: 'jsmode',
	fieldLabel: "项目建设模式",
	displayField : 'mc',
    valueField : 'bm',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : jsmsDs
});

var progressCombo =new Ext.form.ComboBox({
	name : 'progressCb',
	id: 'xmjdCombo',
	width : 150,
	hiddenName: 'progress',
	fieldLabel: "项目进度",
	displayField : 'mc',
    valueField : 'bm',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : progressDs
});

var zgdep = new Ext.form.TriggerField({
	fieldLabel:'主管单位',
	width:150,
	editable: false,
	name:'zgdep_name'
});
zgdep.onTriggerClick=function(e){
	if(LockInfo.zgdep=="1"){
		return;
	}
	zgWin.show();
}

var zgssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
zgssm.handleMouseDown = Ext.emptyFn;
var zgccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var zgRd = Ext.data.Record.create([]);
var zgds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryListPaging',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows',
		totalProperty: 'retData.totalCount'
	}, zgRd)
});
zgds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var zgname = Ext.getCmp('p_zgdep').getValue();
	var p = {name: zgname?zgname:""};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	zgds.baseParams={
		jsonData: Ext.encode({
			dataID : 'zgDeps',
			queryParams : jparams
		})
	};
});
var zggrid = new Ext.grid.GridPanel({
	id:'zgDep',
	title:'',
	store: zgds,
	cm: zgccm,
	selModel: zgssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: zgds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
var zgPanel = new Ext.Panel({
	frame:false,
	layout:'fit',
	autoScroll:true, //自动滚动条
	items:[zggrid],
	tbar: [{ 
		xtype: 'label',
		text :'单位名称：'
	},{
		xtype:'textfield',
		id:'p_zgdep',
		width:150,
		enableKeyEvent:true,
		name:'paras',
		hideLabel:true
		,listeners:{   
			specialkey:function(field,e){   
				if (e.getKey()==Ext.EventObject.ENTER){  
					zgds.load({params:{start:0, limit:PAGE_SIZE}});
				}   
			}
		}   
	},new Ext.Toolbar.Separator(),
	{
		text: '搜索',
		iconCls: 'filter',
		handler : function(){
			zgds.load({params:{start:0, limit:PAGE_SIZE}});
		}
	}]
});
var zgWin = new Ext.Window({
    title : '主管单位列表',
    width : 500,
    height : 400,
    layout : 'fit',
	autoScroll : true,
	modal:true,
    items : [zgPanel],
    closeAction:'hide',
    buttons : [{
    	text : "确定",
	    handler:function(){
        	var records = zggrid.getSelectionModel().getSelections();
	        if(!records||records.length<1){
				Ext.Msg.alert("提示","请选择主管单位!");
				return;
			}
			var rc= records[0];
			pform1.getForm().findField("zgdep_name").setValue(rc.get("name"));
			pform1.getForm().findField("zgdep").setValue(rc.get("code"));
			pform1.getForm().findField("zglxr").setValue(rc.get("lxr"));
			pform1.getForm().findField("zglxrtel").setValue(rc.get("phoneno"));
			zgWin.hide();
	    }
    },{
    	text : "关闭",
	    handler:function(){
	    	zgWin.hide();
	    }
    }]
});
zgWin.on("show",function(){
	zgds.load({params:{start:0, limit:PAGE_SIZE}});
});
var pform1 = new Ext.FormPanel({
	id:"proBasicform1",
	frame: true,
	labelWidth: 140,
	labelAlign: 'right',
	buttonAlign:'center',
	autoScroll: true,
	trackResetOnLoad:true,
	items:[
	{
	    name : 'id',
		xtype : 'hidden',
		value: ''
	},{
		layout:'column',
		items:[
		{
			columnWidth:.5,
			layout: 'form',
			items:[
			{ 
			    fieldLabel :'项目名称',
			    name : 'pname',
			    width : 150,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;border:0px;'
			},{ 
			    fieldLabel :'曾用名',
			    name : 'cyname',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'建设项目代码',
			    name : 'pcode',
			    width : 150,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;border:0px;'
			},{
			    fieldLabel :'前期项目代码',
			    name : 'cycode',
			    width : 150,
				xtype : 'textfield'
			},tzmodeCombo
			,{
				fieldLabel :'项目管理分类',
			    name : 'xmglflname',
			    width : 150,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;border:0px;'
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'市本级财政出资（万元）',
					    name : 'bjczje',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_bjczje',
		                handler: fileUpload
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准建设内容及规模',
						width:150,
						xtype: 'textfield',
						name: 'pzjsnr'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_pzjsnr',
		                handler: fileUpload
					}]
				}]
			},{
				fieldLabel :'批准项目建设期限',
			    name : 'jsqx',
			    width : 150,
				xtype : 'textfield'
			},xmqxCombo]
			
		},{
			columnWidth:.5,
			layout: 'form',
			items:[{
			    fieldLabel :'',
			    name : 'entercode',
				xtype : 'hidden'
			},{
			    fieldLabel :'项目建设单位',
			    name : 'entername',
			    width : 150,
			    readOnly:true,
			    style:'background:none;border:0px;',
				xtype : 'textfield'
			},{
			    fieldLabel :'建设单位联系人',
			    name : 'lxr',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'联系人电话',
			    name : 'lxrtel',
			    width : 150,
				xtype : 'textfield'
			},zgdep
			,{
				name:'zgdep',
				xtype:'hidden',
				value: ''
			},{
				fieldLabel :'主管部门联系人',
			    name : 'zglxr',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'联系人电话',
			    name : 'zglxrtel',
			    width : 150,
				xtype : 'textfield'
			},jsmsCombo,
			{
			    fieldLabel :'开工日期',
			    name : 'kgrq',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'竣工验收日期',
			    name : 'jgrq',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'详细地址',
			    name : 'address',
			    width : 150,
				xtype : 'textfield'
			}]
		}]
	}
	,progressCombo
	,{
		layout:'column',
		id: "tzms1Form",
		items:[
		{
			columnWidth:.5,
			layout: 'form',
			items:[
			{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目估算金额（万元）',
					    name : 'guje',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_guje',
		                handler: fileUpload
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准投资估算文号',
					    name : 'gufileno',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gufileno',
		                handler: fileUpload
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算金额调整1',
					    name : 'gujetz1',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gujetz1',
		                handler: fileUpload
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算调整1决策依据',
					    name : 'gutzfile1',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gutzfile1',
		                handler: fileUpload
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算金额调整2',
					    name : 'gujetz2',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gujetz2',
		                handler: fileUpload
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算调整2决策依据',
					    name : 'gutzfile2',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gutzfile2',
		                handler: fileUpload
					}]
				}]
			}]
		},{
			columnWidth:.5,
			layout: 'form',
			items:[{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目概算金额（万元）',
					    name : 'gaije',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gaije',
		                handler: fileUpload
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准投资概算文号',
					    name : 'gaifileno',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gaifileno',
		                handler: fileUpload
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算金额调整1',
					    name : 'gaijetz1',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gaijetz1',
		                handler: fileUpload
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算调整1决策依据',
					    name : 'gaitzfile1',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gaitzfile1',
		                handler: fileUpload
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算金额调整2',
					    name : 'gaijetz2',
					    width : 150,
						xtype : 'numberfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gaijetz2',
		                handler: fileUpload
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
                	columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算调整2决策依据',
					    name : 'gaitzfile2',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_gaitzfile2',
		                handler: fileUpload
					}]
				}]
			}]
		}]
	},{
		layout:'column',
		id: "tzms2Form",
		items:[
		{
			columnWidth:.5,
			layout: 'form',
			items:[
			{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目决策依据文件',
					    name : 'xmjcfile',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_xmjcfile',
		                handler: fileUpload
					}]
				}]
			}]
		},{
			columnWidth:.5,
			layout: 'form',
			items:[{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'出资责任政策文件',
					    name : 'xmczzrfile',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_xmczzrfile',
		                handler: fileUpload
					}]
				}]
			}]
		}]
	}]
});	

var gsPanel,jqzlPanel,proInfoTab,proWin;

//基本信息页签
var basicPanel = new Ext.Panel({
	id : 'proBasicInfo',
	//上下两部分，上部分基本信息,下部分是相关单位的grid
	layout : 'border',
	items : [{
		id:'proBasicForm',
		layout:'fit',
        region:'north',
        height: 240,
        frame:false,
	    border:false,
		items: pform1
	},{
		region:'center',	
        layout:'fit',
        autoScroll: true,
		items: engrid
	}]
});

function createProWin(){
	proInfoTab = new Ext.TabPanel({  
		id:'proInfoTab',
		activeTab:0,  
		frame: true,
		enableTabScroll:true,
		layoutOnTabChange:true,
		items:[
		{
			layout:'fit',
	        title: '项目基本信息',
	        closable: false,
	        autoScroll:true,
	        items: basicPanel 
	    },{
			layout:'fit',
	        title: '项目概算信息',
	        closable: false,
	        items: gsPanel 
	    },{
			layout:'fit',
	        title: '项目近期汇报材料',
	        closable: false,
	        items: jqzlPanel 
	    }]
	});
	proWin=new Ext.Window({
		title : '项目信息',
		width : 740,
		height : 530,
		autoScroll : true,
		layout : 'fit',
		closeAction:'hide',
		modal:true,
		items : [proInfoTab],
		buttons : [{
	        text : "提交",
	        id: 'btn_submit',
	        handler : function() {	
				Ext.Msg.confirm('确认', '提交后不可编辑，等待专管员核定，确定提交？', function(btn){
			    	if(btn == 'yes') {
			    		savePro(1); 
					}
				});
			}
		},{
	        text : "保存",
	        id: 'btn_save',
	        handler : function() {	
	        	savePro(0); 
	        }
		},{
	        text : "我要修改",
	        id: 'btn_modifyApply',
	        disabled : true,
	        handler : function() {
	        	modifyWin.show();
	        }
		},{
	        text : "关闭",
	        handler : function() {
	        	proWin.hide();
	        }
		}]
	});
	proWin.on("show",function(){
		//按钮可用情况
		var issubmit = cProRd.get("issubmit");
		var status =  cProRd.get("status");
		if(issubmit==1&&status!=5){
			Ext.getCmp("btn_submit").disable();
			Ext.getCmp("btn_save").disable();
		}else{
			Ext.getCmp("btn_submit").enable();
			Ext.getCmp("btn_save").enable();
		}
		if(status ==1 ){
			Ext.getCmp("btn_modifyApply").enable();
		}else{
			Ext.getCmp("btn_modifyApply").disable();
		}
		var tt = "项目信息——"+cProRd.get("pname");
		proWin.setTitle(tt);
		//根据投资模式重新布局
		if(cTzms=="02"||cTzms=="03"){
			Ext.getCmp("xmjdCombo").hide();
			Ext.getCmp("tzms1Form").hide();
			Ext.getCmp("tzms2Form").show();
		}else{
			Ext.getCmp("xmjdCombo").show();
			Ext.getCmp("tzms1Form").show();
			Ext.getCmp("tzms2Form").hide();
		}
		
		//加载项目基本信息
   		var kdata={id: cProRd.get("id")};
		Ext.Ajax.request({
			url: '../xmgl/getSingleRecord',
			method : 'post',
			headers: {
				"Content-Type": "application/json;charset=utf-8"
			},
			params : Ext.encode({
				keyParams : Ext.encode(kdata),
				dataID: 'projectInfo'
			}),
			success : function(response, options) {
			   	var o = Ext.util.JSON.decode(response.responseText);
			   	if(o&&o.retCode=="0"){
			   		var info = o.retData;
		   			pform1.getForm().setValues(info);
		   			gsform.getForm().setValues(info);
		   			//获取lock状态，确定字段的只读/可编辑
		   			var lockParams = {
		   				qParams:{ module:'0',mkey: cProRd.get("id")}
					};
		   			Ext.Ajax.request({
		   				url: '../xmgl/queryList',
		   				method : 'post',
		   				headers: {
		   					"Content-Type": "application/json;charset=utf-8"
		   				},
		   				params : Ext.encode({
		   					queryParams : lockParams,
		   					dataID: 'lockStates'
		   				}),
		   				success : function(response, options) {
		   				   	var o = Ext.util.JSON.decode(response.responseText);
		   				   	if(o&&o.retCode=="0"){
		   				   		var rows= o.retData.rows;
		   				   		if(rows){
		   				   			for(var i=0;i<rows.length;i++){
		   				   				var o = rows[i];
		   				   				if(o.fld){
		   				   					//锁定信息存在本地，以便操作时临时判断锁定状态
		   				   					LockInfo[o.fld]=o.islock;
		   				   					if(pform1.getForm().findField(o.fld)){
		   				   						if(o.islock==1){
		   				   							pform1.getForm().findField(o.fld).disable();
		   				   						}else{
		   				   							pform1.getForm().findField(o.fld).enable();
		   				   						}
		   				   					}
											if(pform1.getForm().findField(o.fld+"_name")){
			   				   					if(o.islock==1){
		   				   							pform1.getForm().findField(o.fld+"_name").disable();
		   				   						}else{
		   				   							pform1.getForm().findField(o.fld+"_name").enable();
		   				   						}
	   				   						}
											if(gsform.getForm().findField(o.fld)){
												if(o.islock==1){
													gsform.getForm().findField(o.fld).disable();
		   				   						}else{
		   				   							gsform.getForm().findField(o.fld).enable();
		   				   						}
											}
		   				   					if(o.fld=="proRltEns"){
		   				   						if(o.islock==1){
		   				   							Ext.getCmp("btn_proEn_add").disable();
		   				   							Ext.getCmp("btn_proEn_remove").disable();
		   				   							Ext.getCmp("btn_proEn_save").disable();
		   				   						}else{
			   				   						Ext.getCmp("btn_proEn_add").enable();
		   				   							Ext.getCmp("btn_proEn_remove").enable();
		   				   							Ext.getCmp("btn_proEn_save").enable();
		   				   						}
		   				   					}
			   				   				if(o.fld=="proGaisuan"){
		   				   						if(o.islock==1){
		   				   							Ext.getCmp("btn_gaisuan_save").disable();
		   				   						}else{
			   				   						Ext.getCmp("btn_gaisuan_save").enable();
		   				   						}
		   				   					}
			   				   				if(o.fld=="jqhbcl"){
					   				   			if(o.islock==1){
					   				   				Ext.getCmp('btn_jqhbcl').disable();
					   				   				jqzlform.getForm().findField("filepath").disable();
					   				   			}else{
					   				   				Ext.getCmp('btn_jqhbcl').enable();
					   				   				jqzlform.getForm().findField("filepath").enable();
					   				   			}
			   				   				}
		   				   				}
		   				   			}
		   				   		}
		   				   	}
		   				},
		   				failure : function() {
		   			  	}
		   			});
			   	}
			},
			failure : function() {
		  	}
		});
		eds.load({});
		gds.load({});
		jds.load({params:{start:0,limit:PAGE_SIZE}});
	});
}
function savePro(isSubmit){
	//检查form，包括概算form的两个字段
	var changedFlds = pform1.getForm().getFieldValues(true);
	var gsFlds = gsform.getForm().getFieldValues(true);
	Ext.apply(changedFlds,gsFlds);
	if(Ext.encode(changedFlds)=="{}"){
		//检查关联企业保存
		saveRltEns(false);
		//检查概算录入保存
		saveGaisuan(false);
		if(isSubmit==0){
			return;
		}else{
			submitPro();
		}
	}else{
		saveRltEns(true);
		saveGaisuan(true);
		//id强制必传，约定变量名proid
		changedFlds.proid = pform1.getForm().findField("id").getValue();
		changedFlds.pname = pform1.getForm().findField("pname").getValue();
		//删除不在项目表中的冗余字段
		delete changedFlds.entername;
		delete changedFlds.zgdep_name;
		Ext.getBody().mask('正在保存……');
		Ext.Ajax.request({
			url: '../xmgl/save',
			method : 'post',
			headers: {
				"Content-Type": "application/json;charset=utf-8"
			},
			params : Ext.encode({
				updateParams : Ext.encode(changedFlds),
				dataID: 'projectInfo'
			}),
			success : function(response, options) {
				Ext.getBody().unmask();
			   	var o = Ext.util.JSON.decode(response.responseText);
			   	if(o&&o.retCode=="0"){
			   		if(isSubmit==1){
			   			submitPro();
			   		}else{
			   			ds.load({params:{start:0,limit:PAGE_SIZE}});
			   			Ext.Msg.alert('信息',o&&o.retData.info?o.retData.info:"已保存！");
			   		}
			   	}else{
			   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"保存时发生错误！");
			   	}
			},
			failure : function() {
		  	}
		});	
	}
}
function submitPro(){
	var submitParams = {
		module:'0',
		mkey: cProRd.get("id"),
		proid:cProRd.get("id"),
		pname : pform1.getForm().findField("pname").getValue(),
		opType:'submitProject'
	};
	Ext.Ajax.request({
		url: '../xmgl/save',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			updateParams : Ext.encode(submitParams),
			dataID: 'submitBasicInfo'
		}),
		success : function(response, options) {
			Ext.getBody().unmask();
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		Ext.Msg.alert('信息',o&&o.retData.info?o.retData.info:"已提交！");
		   		ds.load({params:{start:0,limit:PAGE_SIZE}});
		   		proWin.hide();
		   	}else{
		   	}
		},
		failure : function() {
	  	}
	});
}
//可以申请修改的字段
var mfldsRd = Ext.data.Record.create([
    {name : 'fld',type : 'string'}, 
    {name : 'fldname',type : 'string'},
    {name : 'isattach',type : 'int'},
    {name : 'fldtype',type : 'int'},
    {name : 'option_tb',type : 'string'},
    {name : 'hasdetail',type : 'int'}
]);
var mfDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'fld',
        root:"retData.rows",
    }, mfldsRd)
});
mfDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'module':'0'}
	}
	mfDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'fldsDictionary',
			queryParams : jparams
		})
	};
});
mfDs.load({});
var valRd = Ext.data.Record.create([
    {name : 'bm',type : 'string'}, 
    {name : 'mc',type : 'string'}
]);

var valDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, entypeRd)
});
valDs.on("beforeload",function(store,options){
	var fld = mform.getForm().findField("modifyFld").getValue();
	var r = mfDs.getById(fld);
	var tb = r.get("option_tb"); 
	var jparams = {
		qParams: {'table_bm': tb}
	}
	valDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
var mform=new Ext.FormPanel({
	frame: true,
	labelWidth: 80,
	labelAlign: 'right',
	buttonAlign:'center',
	autoScroll: true,
	items:[
	{
		xtype:'combo',
		width: 200,
		displayField : 'fldname',
		valueField : 'fld',
		typeAhead : true,
		name:'fldCb',
		hiddenName:'modifyFld',
		mode : 'local',
		triggerAction : 'all',
		emptyText : '修改内容',
		selectOnFocus : true,
		editable : false,
		store : mfDs,
		listeners:{
			select: function(combo,r,index){
				var ft = r.get("fldtype"); 
				var hd = r.get("hasdetail");
				if(hd==1){
					mform.getForm().findField("newValue").hide();
					mform.getForm().findField("newValueCb").hide();
				}else{
					if(ft==2){
						mform.getForm().findField("newValue").hide();
						mform.getForm().findField("newValueCb").show();
                        valDs.load({});
					}else{
						mform.getForm().findField("newValue").show();
						mform.getForm().findField("newValueCb").hide();
					}
				}
			}
		}
	},{
		fieldLabel:"新值",
		xtype:'textfield',
		name:'newValue',
		width:200,
		maxLength :3000
	},{
		xtype:'combo',
		name : 'newValue_cb',
		width : 200,
		hiddenName: 'newValueCb',
		fieldLabel: "新值",
		displayField : 'mc',
	    valueField : 'bm',
		hidden: true,
	    typeAhead : true,
	    mode : 'remote',
	    triggerAction : 'all',
	    emptyText : '',
	    selectOnFocus : true,
	    editable : false,
	    store : valDs
	},{
		fieldLabel:"修改原因",
		xtype:'textarea',
		name:'remark',
		width:200,
		height: 100,
		maxLength :3000
	}]
});
var modifyWin = new Ext.Window({
	title : '申请修改',
	width : 360,
	height : 240,
	autoScroll : true,
	closeAction:'hide',
	modal:true,
	layout : 'fit',
	items : [mform],
	buttons : [{
        text : "提交申请",
        handler : function() {	
        	var mkey = cProRd.get("id");
        	var fld = mform.getForm().findField("modifyFld").getValue();
			var ft = mfDs.getById(fld).get("fldtype"); 
			var isattach = mfDs.getById(fld).get("isattach"); 
			var newval = mform.getForm().findField("newValue").getValue();
			if(ft==2){
				newval = mform.getForm().findField("newValueCb").getValue();
			}
			var p={
				module:'0',
				mkey: mkey,
				fld: fld,
				isattach: isattach,
				newval:newval,
				remark: mform.getForm().findField("remark").getValue(),
				
				opType: 'submitModifyApply',
				proid:cProRd.get("id"),
				pname : pform1.getForm().findField("pname").getValue(),
			};
			Ext.getBody().mask('正在提交……');
			Ext.Ajax.request({
				url: '../xmgl/save',
				method : 'post',
				headers: {
					"Content-Type": "application/json;charset=utf-8"
				},
				params : Ext.encode({
					updateParams : Ext.encode(p),
					dataID: 'submitModifyApply'
				}),
				success : function(response, options) {
					Ext.getBody().unmask();
				   	var o = Ext.util.JSON.decode(response.responseText);
				   	if(o&&o.retCode=="0"){
				   		Ext.Msg.alert('信息',o&&o.retData.info?o.retData.info:"已提交！");
				   		modifyWin.hide();
				   	}else{
				   	}
				},
				failure : function() {
			  	}
			});
        }
	},{
        text : "关闭",
        handler : function() {	
        	modifyWin.hide(); 
        }
	}]
});
modifyWin.on("show",function(){
	mform.getForm().findField("newValue").setValue("");
	mform.getForm().findField("newValue").show();
	mform.getForm().findField("newValueCb").setValue("");
	mform.getForm().findField("newValueCb").hide();
	//Ext.getCmp("md_attachFilePath").setRawValue('');
	//Ext.getCmp("md_attachFilePath").hide();
});

//一般的上传
var fileWin = new Ext.Window({
	title : '项目信息',
	width : 620,
	height : 400,
	autoScroll : true,
	closeAction:'hide',
	modal:true,
	layout : 'border',
	items : [{
    	region:'north',
    	height: 50,
    	items: uploadForm
    },{
    	region:'center',
    	layout : 'fit',
    	items: attachGrid
    }],
	buttons : [{
        text : "关闭",
        handler : function() {	
        	fileWin.hide(); 
			Ext.getCmp("attachFilePath").setRawValue('');
        }
	}]
});
fileWin.on("show",function(){
	ads.load({params:{start:0,limit:PAGE_SIZE}});
});
function fileUpload (btn,e){
	var btid = btn.getId();
	cFld = btid.substring(btid.indexOf("_")+1);
	if(LockInfo[cFld]=="1"){//如果当前字段锁定，弹出的附件窗体，form中不可上传。
		Ext.getCmp('btn_commonUpload').disable();
		uploadForm.getForm().findField("filepath").disable();
	}else{
		Ext.getCmp('btn_commonUpload').enable();
		uploadForm.getForm().findField("filepath").enable();
	}
	fileWin.show();
}
function downloadAttach(openOnLine,fid){
	var fm = document.getElementById("fileDownloadForm");
	if(openOnLine==1){
		fm = document.getElementById("fileOpenForm"); 
	}
	fm.isOpen.value=openOnLine;
	fm.fid.value=fid;
	fm.method = "POST"; 
	fm.submit(); 
}
Ext.onReady(function(){
	Ext.QuickTips.init();
	buildGrid("projectsMaintain",ds,ssm,"id",function(){
		
		buildGrid("zgDep",zgds,zgssm,"code",function(){});
		buildGrid("proGaisuan",gds,gssm,"iid",function(){
			//概算页签
			gsPanel = new Ext.Panel({
				id : 'gsInfo',
				//上下两部分，上部分基本信息,下部分是相关单位的grid
				layout : 'border',
				items : [{
					layout:'fit',
			        region:'north',	
			        height: 70,
			        frame:false,
				    border:false,
					items: [gsform]
				},{
					region:'center',	
			        layout:'fit',
			        frame:false,
				    border:false,
					items:[gsgrid]
				}]
			});
			buildGrid("jqhbcl",jds,jssm,"id",function(){
				//近期汇报资料页签
				jqzlPanel = new Ext.Panel({
					id : 'jqzlInfo',
					layout : 'border',
					items : [{
						layout:'fit',
				        region:'north',	
				        height: 60,
				        frame:false,
					    border:false,
						items: [jqzlform]
					},{
						region:'center',	
				        layout:'fit',
				        frame:false,
					    border:false,
						items:[jqzlgrid]
					}]
				});
				createProWin();
			});
		});
		new Ext.Viewport({
			layout:'fit',
	        items:[grid]
		});
		ds.baseParams.sort = "ctime";
		ds.baseParams.dir = "desc";
		ds.load({params:{start:0,limit:PAGE_SIZE}});
		//上传使用的表格
		buildGrid("attachFiles",ads,null,"id",function(){});
	});
});
</script>
</head>
<body>
<form id="fileDownloadForm" action="../xmgl/downloadAttach">
	<input type="hidden" name="fid" value="0">
	<input type="hidden" name="isOpen" value="0"/> 
</form> 
<form id="fileOpenForm" action="../xmgl/downloadAttach" target="_blank">
	<input type="hidden" name="fid" value="0">
	<input type="hidden" name="isOpen" value="0"/> 
</form> 
</body>
</html>