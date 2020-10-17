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
<title>项目基础信息审核</title>
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
var cTab,cProRd ,cTzms,cFld,checkMode;
var LockInfo = new Object();

//基本信息审核
var cbssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
cbssm.handleMouseDown = Ext.emptyFn;
var cbcm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var cbRd = Ext.data.Record.create([]);
var cbds = new Ext.data.Store({
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
	},cbRd)
});
cbds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var jparams = {
		start: st,
		limit: lm,
		qParams: {}
	}
	cbds.baseParams={
		jsonData: Ext.encode({
			dataID : 'projects2Check',
			queryParams : jparams
		})
	};
});
var cbGrid = new Ext.grid.GridPanel({
	id:'projects2Check',
	title:'',
	store: cbds,
	cm: cbcm,
	selModel: cbssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	tbar:[
   	{
   		text: '审核',
   		iconCls: 'details',
   		handler : function(){
   			var rds = cbGrid.getSelectionModel().getSelections();
   			if(!rds||rds.length<1){
   				Ext.Msg.alert("提示","请先选择要审核的记录！");
   				return;
   			}
   			cTab = "checkPro";
   			cProRd = rds[0];
   			proWin.show();
   		}
   	}],
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: cbds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
//字段修改审核
var cfssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
cfssm.handleMouseDown = Ext.emptyFn;
var cfcm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var cfRd = Ext.data.Record.create([]);
var cfds = new Ext.data.Store({
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
	}, cfRd)
});
cfds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var p = {};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	cfds.baseParams={
		jsonData: Ext.encode({
			dataID : 'modifyFlds2Check',
			queryParams : jparams
		})
	};
});
var cfGrid = new Ext.grid.GridPanel({
	id:'modifyFlds2Check',
	title:'',
	store: cfds,
	cm: cfcm,
	selModel: cfssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	tbar:[
  	{
  		text: '审核',
  		iconCls: 'details',
  		handler : function(){
  			var rds = cfGrid.getSelectionModel().getSelections();
  			if(!rds||rds.length<1){
  				Ext.Msg.alert("提示","请先选择要审核的记录！");
  				return;
  			}
  			cTab = "checkFld";
  			cProRd = rds[0];
  			mfWin.show();
  		}
  	}],
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: cfds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
//已审核
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
			dataID : 'projectsChecked',
			queryParams : jparams
		})
	};
});
var cGrid = new Ext.grid.GridPanel({
	id:'projectsChecked',
	title:'已审核',
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
			var rds = cGrid.getSelectionModel().getSelections();
			if(!rds||rds.length<1){
				Ext.Msg.alert("提示","请先选择项目！");
				return;
			}
			cTab = "checkedPro";
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


//项目相关企业grid
var eccm = new Ext.grid.ColumnModel({
	columns:[
   	{
   		header: "单位类型",
   		dataIndex: 'entypename',
   		width: 150,
   		align: 'left'
   	},{
   	    header: "单位名称",
   	    dataIndex: 'ename',
   	    width: 200,
   	    align:'left'
   	},{
   	    header: "备注",
   	    dataIndex: 'remark',
   	    width: 300,
   	    align:'left'
   	}],
	defaultSortable: true
});
var eRd = Ext.data.Record.create([
    {name: 'id', type: 'int'},
	{name: 'entype', type: 'string'},
	{name: 'entypename', type: 'string'},
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
	var proid = cProRd.get("proid");
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
var engrid = new Ext.grid.GridPanel({
	id:'proRltEns',
	title:'',
	store: eds,
	cm: eccm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false
});
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
		readOnly: true,
		style:'background:none;',
		maxLength :300
	},{
		xtype:'textfield',
		name: 'gspf_fileno',
		fieldLabel: '概算批复文件文号',
		readOnly: true,
		width:200,
		maxLength :200,
		style:'background:none;'
	}]
});
//概算grid
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
	var proid = cProRd.get("proid");
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
var gsgrid = new Ext.grid.GridPanel({
	id:'proGaisuan',
	title:'',
	store: gds,
	cm: gccm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false
});
gsgrid.on('beforeedit',function(e){ 
	//审核页面，不能修改。该grid和“基本信息维护”公用。
	e.cancel = true;
});

//近期汇报材料，审核时只有附件grid
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
	var proid = cProRd.get("proid");
	var p = {proid: proid};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	jds.baseParams={
		jsonData: Ext.encode({
			dataID : 'jqhbcl',
			queryParams : jparams
		})
	};
});
var jqzlgrid = new Ext.grid.GridPanel({
	id:'jqhbcl',
	title:'',
	store: jds,
	cm: jccm,
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

//各个项目字段的“附件”弹窗，公用。审核时不需要上传form
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
	var p = {proid: cProRd.get("proid"),fld: cFld};
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

var pform1 = new Ext.FormPanel({
	id:"proBasicform1",
	frame: true,
	labelWidth: 140,
	labelAlign: 'right',
	buttonAlign:'center',
	autoScroll: true,
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
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目名称',
					    name : 'pname',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{ 
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'曾用名',
					    name : 'cyname',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'建设项目代码',
					    name : 'pcode',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'前期项目代码',
					    name : 'cycode',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel:'投资模式',
						name : 'tzmsmc',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目管理分类',
					    name : 'xmglflname',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'市本级财政出资（万元）',
					    name : 'bjczje',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准建设内容及规模',
						width:150,
						xtype: 'textfield',
						name: 'pzjsnr',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_pzjsnr',
		                handler: fileUpload
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准项目建设期限',
					    name : 'jsqx',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目所在区县',
					    name : 'qxmc',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			}]
		},{
			columnWidth:.5,
			layout: 'form',
			items:[{
			    fieldLabel :'',
			    name : 'entercode',
				xtype : 'hidden'
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'项目建设单位',
					    name : 'entername',
					    width : 150,
					    readOnly:true,
					    style:'background:none;',
						xtype : 'textfield'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'建设单位联系人',
					    name : 'lxr',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'联系人电话',
					    name : 'lxrtel',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel:'主管单位',
						width:150,
						xtype : 'textfield',
						name:'zgdw',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				name:'zgdep',
				xtype:'hidden',
				value: ''
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'主管部门联系人',
					    name : 'zglxr',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'联系人电话',
					    name : 'zglxrtel',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目建设模式',
					    name : 'jsmsmc',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},
			{	xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'开工日期',
					    name : 'kgrq',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'竣工验收日期',
					    name : 'jgrq',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			},{
				xtype : 'container',
	            layout : 'column',
                items  : [{
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
					    fieldLabel :'详细地址',
					    name : 'address',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				}]
			}]
		}]
	},{
		xtype : 'container',
        layout : 'column',
        items  : [{
       		columnWidth : ".40",
       		border: true,
            xtype : 'container',
            labelWidth: 140,
            layout : 'form',
			items: [{
				fieldLabel :'项目进度',
				id:'xmjdCombo',
			    name : 'xmjdmc',
			    width : 150,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			}]
		}]
	},{
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
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目估算金额（万元）',
					    name : 'guje',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准投资估算文号',
					    name : 'gufileno',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算金额调整1',
					    name : 'gujetz1',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算调整1决策依据',
					    name : 'gutzfile1',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算金额调整2',
					    name : 'gujetz2',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".1",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'估算调整2决策依据',
					    name : 'gutzfile2',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目概算金额（万元）',
					    name : 'gaije',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'批准投资概算文号',
					    name : 'gaifileno',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算金额调整1',
					    name : 'gaijetz1',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算调整1决策依据',
					    name : 'gaitzfile1',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算金额调整2',
					    name : 'gaijetz2',
					    width : 150,
						xtype : 'numberfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
                	columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'概算调整2决策依据',
					    name : 'gaitzfile2',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'项目决策依据文件',
					    name : 'xmjcfile',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
               		columnWidth : ".90",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'出资责任政策文件',
					    name : 'xmczzrfile',
					    width : 150,
						xtype : 'textfield',
						readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".10",
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
			text : "通过",
			id:'btn_pass',
	        handler : function() {
	        	checkMode = "checkBasic";
	        	commentWin.show();
	        }
		},{
			text : "回退",
			id:'btn_rollback',
	        handler : function() {
	        	checkMode = "rollbackBasic";
	        	commentWin.show();
	        }
		},{
			text : "字段纠正",
			id:'btn_modifyFld',
	        handler : function() {
	        	fmodifyWin.show();
	        }
		},{
	        text : "关闭",
	        handler : function() {
	        	proWin.hide();
	        }
		}]
	});
	proWin.on("show",function(){
		if(cTab=="checkPro"){
			Ext.getCmp("btn_modifyFld").hide();
			Ext.getCmp("btn_pass").show();
			Ext.getCmp("btn_rollback").show();
		}else{
			Ext.getCmp("btn_modifyFld").show();
			Ext.getCmp("btn_pass").hide();
			Ext.getCmp("btn_rollback").hide();
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
   		var kdata={id: cProRd.get("proid")};
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

var fileWin = new Ext.Window({
	title : '项目信息',
	width : 620,
	height : 400,
	autoScroll : true,
	closeAction:'hide',
	modal:true,
	layout : 'fit',
	items : [{
    	region:'center',
    	layout : 'fit',
    	items: attachGrid
    }],
	buttons : [{
        text : "关闭",
        handler : function() {	
        	fileWin.hide(); 
        }
	}]
});
fileWin.on("show",function(){
	ads.load({params:{start:0,limit:PAGE_SIZE}});
});
function fileUpload (btn,e){
	var btid = btn.getId();
	cFld = btid.substring(btid.indexOf("_")+1);
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

//审批意见
var commentForm=new Ext.FormPanel({
	frame: true,
	labelAlign: 'right',
	buttonAlign:'center',
	autoScroll: true,
	items:[
	{
		hideLabel :true,
		xtype:'textarea',
		name:'remark',
		width:'260',
		height:'150'
	}]
});
var commentWin = new Ext.Window({
	title : '审批意见',
	width : 300,
	height : 240,
	autoScroll : true,
	closeAction:'hide',
	modal:true,
	layout : 'fit',
	items : [commentForm],
	buttons : [{
		text : "确定",
		handler : function() {	
			var remark = commentForm.getForm().findField("remark").getValue();
			var checkParams = {
				module:'0',
				mkey : cProRd.get("proid"),
				id: cProRd.get("id"),
				remark: remark,
				proid: cProRd.get("proid"),
				pname: cProRd.get("pname"),
				opType: checkMode
				
			};
			var dataID = "";
			if(checkMode=='checkBasic'){
				dataID = 'checkBasicSubmit';
			}else if(checkMode=='checkFld'){
				dataID = 'checkModifyApply';
			}else if(checkMode=='rollbackBasic'){
				dataID = 'rollbackCheck';
				checkParams.allback=1;
				checkParams.aid=cProRd.get("aid");
				checkParams.backfld='';
			}else if(checkMode=='rollbackFld'){
				dataID = 'rollbackCheck';
				checkParams.allback=0;
				checkParams.aid=cProRd.get("aid");
				checkParams.backfld=cProRd.get("fld");
			}
			
			Ext.Ajax.request({
				url: '../xmgl/save',
				method : 'post',
				headers: {
					"Content-Type": "application/json;charset=utf-8"
				},
				params : Ext.encode({
					updateParams : Ext.encode(checkParams),
					dataID: dataID
				}),
				success : function(response, options) {
					Ext.getBody().unmask();
				   	var o = Ext.util.JSON.decode(response.responseText);
				   	if(o&&o.retCode=="0"){
				   		Ext.Msg.alert('信息',o&&o.retData.info?o.retData.info:"已提交！");
				   		
			   			cfds.reload();
			   			cbds.reload();
			   			ds.reload();
				   		commentWin.hide();
				   		mfWin.hide();
				   		proWin.hide();
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
			commentWin.hide();
		}
	}]
});
commentWin.on("show",function(){
	if(checkMode=='checkBasic'||checkMode=='checkFld'){
		commentWin.setTitle("审批意见");
	}else if(checkMode=='rollbackBasic'||checkMode=='rollbackFld'){
		commentWin.setTitle("回退原因");
	}
});
//字段修改申请
var mform=new Ext.FormPanel({
	frame: true,
	labelWidth: 80,
	labelAlign: 'right',
	buttonAlign:'center',
	autoScroll: true,
	items:[
	{
		name:'id',
		xtype:'hidden',
		value: ''
	},{
		fieldLabel:"修改内容",
		xtype:'textfield',
		width: 250,
		name : 'fldname',
		style:'background:none;border:0px;',
		readOnly: true
	},{
		fieldLabel:"新值",
		xtype:'textfield',
		name:'newvalname',
		width:250,
		style:'background:none;border:0px;',
		readOnly: true
	},{
		fieldLabel:"当前值",
		xtype:'textfield',
		name:'oldvalname',
		width:250,
		style:'background:none;border:0px;',
		readOnly: true
	},{
		fieldLabel:"申请原因",
		xtype:'textarea',
		name:'remark',
		width:250,
		height: 60,
		style:'background:none;border:0px;',
		readOnly: true
	}]
});
var mfWin = new Ext.Window({
	title : '字段修改',
	width : 400,
	height : 300,
	autoScroll : true,
	closeAction:'hide',
	modal:true,
	layout : 'fit',
	items : [mform],
	buttons : [{
        text : "通过",
        handler : function() {	
        	checkMode = "checkFld";
        	commentWin.show();
        }
	},{
        text : "退回",
        handler : function() {
        	checkMode = "rollbackFld";
        	commentWin.show();
        }
	},{
        text : "关闭",
        handler : function() {	
        	mfWin.hide(); 
        }
	}]
});
mfWin.on("show",function(){
	//加载修改信息
	var p={
		module: '0',
		id: cProRd.get("aid"),
		fld: cProRd.get("fld")
	};
	Ext.Ajax.request({
		url: '../xmgl/getSingleRecord',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			keyParams : Ext.encode(p),
			dataID: 'modifyApply'
		}),
		success : function(response, options) {
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		var info = o.retData;
		   		mform.getForm().setValues(info);
		   	}
		},
		failure : function() {
	  	}
   	});
});

//财政端发起修改
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

var fmform = new Ext.FormPanel({
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
		fieldLabel:'修改内容',
		selectOnFocus : true,
		editable : false,
		store : mfDs
	},{
		fieldLabel:"意见",
		xtype:'textarea',
		name:'remark',
		width:200,
		height :100
	}]
});
var fmodifyWin =  new Ext.Window({
	title : '发起修改通知',
	width : 360,
	height : 240,
	autoScroll : true,
	closeAction:'hide',
	modal:true,
	layout : 'fit',
	items : [fmform],
	buttons : [{
        text : "确定",
        handler : function() {	
        	var remark = fmform.getForm().findField("remark").getValue();
			var rp = {
				module:'0',
				mkey : cProRd.get("proid"),
				proid: cProRd.get("proid"),
				pname: cProRd.get("pname"),
				backfld: fmform.getForm().findField("modifyFld").getValue(),
				allback: 0,
				opType: "backFromFinance",
				remark: remark
			};
			Ext.Ajax.request({
				url: '../xmgl/save',
				method : 'post',
				headers: {
					"Content-Type": "application/json;charset=utf-8"
				},
				params : Ext.encode({
					updateParams : Ext.encode(rp),
					dataID: 'backFromFinance'
				}),
				success : function(response, options) {
					Ext.getBody().unmask();
				   	var o = Ext.util.JSON.decode(response.responseText);
				   	if(o&&o.retCode=="0"){
				   		Ext.Msg.alert('信息',o&&o.retData.info?o.retData.info:"已提交！");
				   		ds.load({params:{start:0,limit:PAGE_SIZE}});
				   		proWin.hide();
				   		fmodifyWin.hide();
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
        	fmodifyWin.hide(); 
        }
	}]
});

Ext.onReady(function(){
	Ext.QuickTips.init();
	buildGrid("projects2Check",cbds,cbssm,"id",function(){
		buildGrid("modifyFlds2Check",cfds,cfssm,"id",function(){
			buildGrid("projectsChecked",ds,ssm,"id",function(){
				var listTab = new Ext.TabPanel({  
					id:'proCheckTab',
					activeTab:0,  
					frame: true,
					enableTabScroll:true,
					layoutOnTabChange:true,
					items:[
					{
						layout:'fit',
				        title: '项目基本信息审核',
				        closable: false,
				        autoScroll:true,
				        items: cbGrid
				    },{
						layout:'fit',
				        title: '字段修改审核',
				        closable: false,
				        items: cfGrid 
				    },{
						layout:'fit',
				        title: '已审核',
				        closable: false,
				        items: cGrid 
				    }]
				});
				new Ext.Viewport({
					layout:'fit',
			        items:[listTab]
				});
				cbds.baseParams.sort = "id";
				cbds.baseParams.dir = "desc";
				cbds.load({params:{start:0,limit:PAGE_SIZE}});
				cfds.baseParams.sort = "id";
				cfds.baseParams.dir = "desc";
				cfds.load({params:{start:0,limit:PAGE_SIZE}});
				ds.baseParams.sort = "id";
				ds.baseParams.dir = "desc";
				ds.load({params:{start:0,limit:PAGE_SIZE}});
			});
		});
	});
		
	buildGrid("proGaisuan",gds,null,"iid",function(){
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
		buildGrid("jqhbcl",jds,null,"id",function(){
			//近期汇报资料页签
			jqzlPanel = new Ext.Panel({
				id : 'jqzlInfo',
				layout : 'fit',
				items : [{
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
	//上传使用的表格
	buildGrid("attachFiles",ads,null,"id",function(){});
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