<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="com.fwiz.utils.*"%>
<%
	Configuration cg = (Configuration)ContextUtil.getBean("config");
%>
<html>
<head>
<title>政府投资项目管理系统</title>
<META HTTP-EQUIV="pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Cache-Control" CONTENT="no-cache, must-revalidate">
<META HTTP-EQUIV="expires" CONTENT="Wed, 26 Feb 1997 08:21:57 GMT">
<META HTTP-EQUIV="expires" CONTENT="0">
<style type="text/css">
.x-grid3-cell-text-visible .x-grid3-cell-inner{overflow:visible;padding:3px 3px 3px 5px;white-space:normal;}
</style>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/libs/ext-3.4.0/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/dfCommon.css" />
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/ext-all-debug.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/src/locale/ext-lang-zh_CN.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/GridExporter.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/ExportGridPanel.js"></script>
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
var ssm = new Ext.grid.CheckboxSelectionModel({singleSelect: false}); 
ssm.handleMouseDown = Ext.emptyFn;
var ccm = new Ext.grid.ColumnModel({
	columns:[
	ssm,
	{
		header: "项目",
		dataIndex: 'pname',
		width: 180,
		align: 'left',
		renderer: renderFoo
	},{
	    header: "合同编号",
	    dataIndex: 'htbh',
	    width: 90,
	    align:'left',
	    renderer :renderFoo
	},{
	    header: "申请金额",
	    dataIndex: 'money',
	    width: 110,
	    align:'right',
		renderer: regMoney
	},{
	    header: "用途",
	    dataIndex: 'purpose',
	    width: 160,
	    align:'left',
	    renderer :renderFoo
	},{
	    header: "收款单位",
	    dataIndex: 'recname',
	    width: 160,
	    align:'left',
	    renderer :renderFoo
	},{
	    header: "开户行",
	    dataIndex: 'recbankname',
	    width: 150,
	    align:'left',
	    renderer :renderFoo
	},{
	    header: "账号",
	    dataIndex: 'recbankno',
	    width: 110,
	    align:'left',
	    renderer :renderFoo
	},{
	    header: "制单人",
	    dataIndex: 'username',
	    width: 70,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "审批状态",
	    dataIndex: 'checkstate',
	    width: 70,
	    align:'left',
		renderer: function(v,p,r){
			if(v==1){
				return "审批完成";
			}else if(v==-1){
				return "待审批";
			}else{
				return "未提交";
			}
		}
	},{
	    header: "支付状态",
	    dataIndex: 'paystate',
	    width: 70,
	    align:'left',
		renderer: function(v,p,r){
			if(v==1){
				return "支付完成";
			}else if(v==5){
				return "支付失败";
			}else{
				return "待支付";
			}
		}
	}],
	defaultSortable: true
});

var cRd = Ext.data.Record.create  ([
    {name: 'id', type: 'int'},
    {name: 'proid', type: 'int'},
    {name: 'cid', type: 'int'},
	{name: 'pname', type: 'string'},
	{name: 'htbh', type: 'string'},
	{name: 'money', type: 'float'},
	{name: 'purpose', type: 'string'},
	{name: 'recname', type: 'string'},
	{name: 'recbankname', type: 'string'},
	{name: 'recbankno', type: 'string'},
	{name: 'userid', type: 'string'},
	{name: 'username', type: 'string'},
	{name: 'checkstate', type: 'int'},
	{name: 'paystate', type: 'int'},
	{name: 'ctime', type: 'string'}
]);
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
	}, cRd)
});
ds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var jparams = {
		start: st,
		limit: lm,
		qParams: {}
	}
	ds.baseParams={
		jsonData: Ext.encode({
			dataID : 'paymentApplies',
			queryParams : jparams
		})
	};
});
var grid = new Ext.grid.GridPanel({
	title:'支付申请',
	store: ds,
	cm: ccm,
	selModel: ssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	tbar:[
	{
		text: '添加支付申请',
		iconCls: 'add',
		handler : function(){
			cID = -1;
			payWin.show();
		}
	},{
		text: '修改申请',
		iconCls: 'edit',
		handler : function(){
			var rds = grid.getSelectionModel().getSelections();
			if(!rds||rds.length<1){
				Ext.Msg.alert("提示","请先选择要修改的记录！");
				return;
			}
			cID = rds[0].get("id");
			payWin.show();
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

var enRecord = Ext.data.Record.create([
	{name : 'guid',type : 'int'}, 
	{name : 'code',type : 'string'}, 
	{name : 'name',type : 'string'}
]);
var enDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'guid',
        root:"retData.rows",
    }, enRecord)
});
enDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {}
	}
	enDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'ensOfUser',
			queryParams : jparams
		})
	};
});
enDs.load({});
var enCombo = new Ext.form.ComboBox({
	name : 'enCb',
	id: 'ebCombo',
	width : 120,
	hiddenName: 'enterguid',
	fieldLabel: "单位",
	displayField : 'name',
    valueField : 'guid',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : enDs,
    listeners: {
    	select: function(combo,r,index ){
			var entercode= r.get("code");
			pform.getForm().findField("entercode").setValue(entercode);
		}
    }
});

var cbRecord = Ext.data.Record.create([
	{name : 'id',type : 'int'}, 
	{name : 'htbh',type : 'string'}, 
	{name : 'mc',type : 'string'},
	{name : 'htzje',type : 'float'},
	{name : 'htyzf',type : 'float'}
]);
var contractDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'id',
        root:"retData.rows",
    }, cbRecord)
});
contractDs.on("beforeload",function(store,options){
	var proid = pform.getForm().findField("proid").getValue();
	var p = {proid : proid}
	var jparams = {
		qParams: p
	}
	contractDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'contractsOfPorject',
			queryParams : jparams
		})
	};
});

var contractCombo = new Ext.form.ComboBox({
	name : 'conCb',
	id: 'contractCombo',
	width : 120,
	hiddenName: 'cid',
	fieldLabel: "合同",
	displayField : 'htbh',
    valueField : 'id',
    typeAhead : true,
    mode : 'remote',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : contractDs,
	listeners:{
		beforequery: function(){
			var proid = pform.getForm().findField("proid").getValue();
			if(!proid || proid==""){
				Ext.Msg.alert("提示","请先选择项目！");
			}else{
				contractDs.load({});
			}
		},
		select: function(combo,r,index ){
			var htzje = r.get("htzje");
			var htyzf = r.get("htyzf");
			pform.getForm().findField("htzje").setValue(htzje);
			pform.getForm().findField("htyzf").setValue(htyzf);
		}
	}
});

var recRecord = Ext.data.Record.create([
	{name : 'id',type : 'int'}, 
	{name : 'recname',type : 'string'}, 
	{name : 'recbankname',type : 'string'},
	{name : 'recbankno',type : 'string'}
]);
var recDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'id',
        root:"retData.rows",
    }, recRecord)
});
recDs.on("beforeload",function(store,options){
	var cid = pform.getForm().findField("cid").getValue();
	var p = {cid : cid}
	var jparams = {
		qParams: p
	}
	recDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'recOfContracts',
			queryParams : jparams
		})
	};
});
var recCombo  = new Ext.form.ComboBox({
	name : 'recCb',
	id: 'recCombo',
	width : 120,
	hiddenName: 'recname',
	fieldLabel: "收款单位",
	displayField : 'recname',
    valueField : 'recname',
    typeAhead : true,
    mode : 'local',
    triggerAction : 'all',
    emptyText : '',
    selectOnFocus : true,
    editable : false,
    store : recDs,
	listeners:{
		beforequery: function(combo){
			var cid = pform.getForm().findField("cid").getValue();
			if(!cid||cid==""){
				Ext.Msg.alert("提示","请先选定合同！");
				return;
			}
			recDs.load({});
		},
		select: function(combo,r,index ){
			var recbank = r.get("recbankname");
			var recno = r.get("recbankno");
			pform.getForm().findField("recbankname").setValue(recbank);
			pform.getForm().findField("recbankno").setValue(recno);
		}
	}
});
var proTrigger = new Ext.form.TriggerField({
	fieldLabel:'项目',
	width:120,
	editable: false,
	name:'pname'
});
proTrigger.onTriggerClick=function(e){
	proWin.show();
} 

var pssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
pssm.handleMouseDown = Ext.emptyFn;
var pccm = new Ext.grid.ColumnModel({
	columns: [
	pssm,
	{
		header: "项目名称",
		dataIndex: 'pname',
		width: 300,
		align: 'left',
		renderer: renderFoo
	},{
	    header: "项目管理分类",
	    dataIndex: 'xmglflname',
	    width: 110,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "项目专管人",
	    dataIndex: 'pmanager',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	}],
	defaultSortable: true
});
var mproRd = Ext.data.Record.create([
	{name: 'id', type: 'int'},
	{name: 'pcode', type: 'string'},
	{name: 'pname', type: 'string'},
	{name: 'tzmode', type: 'string'},
	{name: 'tzlx', type: 'string'},
	{name: 'ename', type: 'string'},
	{name: 'xmglflname', type: 'string'},
	{name: 'ctime', type: 'string'},
	{name: 'pmanager', type: 'string'}
]);
var pds = new Ext.data.Store({
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
	}, mproRd)
});
pds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var pname = Ext.getCmp('fltPname').getValue();
	var p = {pname: pname?pname:""};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	pds.baseParams={
		jsonData: Ext.encode({
			dataID : 'projectsMaintain',
			queryParams : jparams
		})
	};
});
var proGrid = new Ext.grid.GridPanel({
	title:'',
	store: pds,
	cm: pccm,
	selModel: pssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: pds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
var proPanel = new Ext.Panel({
	frame:false,
	layout:'fit',
	autoScroll:true, //自动滚动条
	items:[proGrid],
	tbar:[
  	{
  		xtype: 'label',
  		text :'项目名称：'
  	},{
  		xtype:'textfield',
  		fieldLabel:'名称',
  		width:120,
  		enableKeyEvent:true,
  		id: 'fltPname',
  		hideLabel:true
  	},{
  		text: '搜索',
  		iconCls: 'filter',
  		handler : function(){
  			pds.load({params:{start:0,limit:PAGE_SIZE}});
  		}
  	}]
});
var proWin = new Ext.Window({
    title : '项目列表',
    width : 500,
    height : 400,
    layout : 'fit',
	autoScroll : true,
	modal:true,
    items : [proPanel],
    closeAction:'hide',
    buttons : [{
    	text : "确定",
	    handler:function(){
        	var records = proGrid.getSelectionModel().getSelections();
	        if(!records||records.length<1){
				Ext.Msg.alert("提示","请选择项目!");
				return;
			}
			var rc= records[0];
			pform.getForm().findField("proid").setValue(rc.get("id"));
			pform.getForm().findField("pname").setValue(rc.get("pname"));
			proWin.hide();
	    }
    },{
    	text : "关闭",
	    handler:function(){
	    	proWin.hide();
	    }
    }]
});	
proWin.on("show",function(){
	pds.load({params:{start:0,limit:PAGE_SIZE}});
});


//指标选择
var bgssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
bgssm.handleMouseDown = Ext.emptyFn;
var bgccm = new Ext.grid.ColumnModel({
	columns: [
	bgssm,
	{
		header: "资金性质",
		dataIndex: 'resname',
		width: 100,
		align: 'left',
		renderer: renderFoo
	},{
	    header: "预算科目",
	    dataIndex: 'funname',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "预算项目",
	    dataIndex: 'proname',
	    width: 150,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "政府经济分类",
	    dataIndex: 'goveconame',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "部门经济分类",
	    dataIndex: 'econame',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "支出类别",
	    dataIndex: 'paytypename',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "指标ID",
	    dataIndex: 'gplanid',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "指标计划数",
	    dataIndex: 'planmoney',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "指标可用数",
	    dataIndex: 'kymoney',
	    width: 90,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "是否关联账户",
	    dataIndex: 'isglzh',
	    width: 80,
	    align:'left',
		renderer: function(v,p,r){
			if(v==1){
				return "是";
			}else{
				return "否";
			}
		}
	},{
	    header: "是否科研",
	    dataIndex: 'istech',
	    width: 80,
	    align:'left',
	    renderer: function(v,p,r){
			if(v==1){
				return "是";
			}else{
				return "否";
			}
		}
	}],
	defaultSortable: true
});
var bgRd = Ext.data.Record.create([
	{name: 'id', type: 'int'},
	{name: 'resguid', type: 'int'},
	{name: 'resname', type: 'string'},
	{name: 'funcode', type: 'int'},
	{name: 'funname', type: 'string'},
	{name: 'proguid', type: 'int'},
	{name: 'proname', type: 'string'},
	{name: 'ecocode', type: 'int'},
	{name: 'econame', type: 'string'},
	{name: 'govecocode', type: 'int'},
	{name: 'goveconame', type: 'string'},
	{name: 'paytype', type: 'int'},
	{name: 'paytypename', type: 'string'},
	{name: 'istech', type: 'int'},
	{name: 'isglzh', type: 'int'},
	{name: 'planmoney', type: 'float'},
	{name: 'kymoney', type: 'float'}
]);
var bgds = new Ext.data.Store({
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
	}, bgRd)
});
bgds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var enterguid = pform.getForm().findField("enterguid").getValue();
	var p = {enterguid: enterguid?enterguid:""};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	bgds.baseParams={
		jsonData: Ext.encode({
			dataID : 'budgetOfEn',
			queryParams : jparams
		})
	};
});
var bgGrid = new Ext.grid.GridPanel({
	title:'',
	store: bgds,
	cm: bgccm,
	selModel: bgssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: bgds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
var bgPanel = new Ext.Panel({
	frame:false,
	layout:'fit',
	autoScroll:true, //自动滚动条
	items:[bgGrid],
	tbar:[
  	{
  		xtype: 'label',
  		text :'项目名称：'
  	},{
  		xtype:'textfield',
  		fieldLabel:'名称',
  		width:120,
  		enableKeyEvent:true,
  		id: 'fltBgname',
  		hideLabel:true
  	},{
  		text: '搜索',
  		iconCls: 'filter',
  		handler : function(){
  			bgds.load({params:{start:0,limit:PAGE_SIZE}});
  		}
  	}]
});
var bgWin =  new Ext.Window({
    title : '项目列表',
    width : 680,
    height : 400,
    layout : 'fit',
	autoScroll : true,
	modal:true,
    items : [bgPanel],
    closeAction:'hide',
    buttons : [{
    	text : "确定",
	    handler:function(){
        	var records = bgGrid.getSelectionModel().getSelections();
	        if(!records||records.length<1){
				Ext.Msg.alert("提示","请选择项目!");
				return;
			}
			var rc= records[0];
			pform.getForm().findField("gplanid").setValue(rc.get("id"));
			pform.getForm().findField("resguid").setValue(rc.get("resguid"));
			pform.getForm().findField("resname").setValue(rc.get("resname"));
			pform.getForm().findField("funcode").setValue(rc.get("funcode"));
			pform.getForm().findField("funname").setValue(rc.get("funname"));
			pform.getForm().findField("proguid").setValue(rc.get("proguid"));
			pform.getForm().findField("proname").setValue(rc.get("proname"));
			pform.getForm().findField("ecocode").setValue(rc.get("ecocode"));
			pform.getForm().findField("econame").setValue(rc.get("econame"));
			pform.getForm().findField("govecocode").setValue(rc.get("govecocode"));
			pform.getForm().findField("goveconame").setValue(rc.get("goveconame"));
			pform.getForm().findField("paytype").setValue(rc.get("paytype"));
			pform.getForm().findField("paytypename").setValue(rc.get("paytypename"));
			pform.getForm().findField("planmoney").setValue(rc.get("planmoney"));
			pform.getForm().findField("kymoney").setValue(rc.get("kymoney"));
			pform.getForm().findField("istech").setValue(rc.get("istech")==1?"是":"否");
			bgWin.hide();
	    }
    },{
    	text : "关闭",
	    handler:function(){
	    	bgWin.hide();
	    }
    }]
});	
bgWin.on("show",function(){
	bgds.load({params:{start:0,limit:PAGE_SIZE}});
});

//支付申请
var pform = new Ext.FormPanel({
	id:"paymentform",
	frame: true,
	labelWidth: 90,
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
	    name : 'proid',
		xtype : 'hidden',
		value: ''
	},{
	    name : 'entercode',
		xtype : 'hidden',
		value: ''
	},{
	    name : 'resguid',
		xtype : 'hidden'
	},{
	    name : 'funcode',
		xtype : 'hidden'
	},{
	    name : 'proguid',
		xtype : 'hidden'
	},{
	    name : 'ecocode',
		xtype : 'hidden'
	},{
	    name : 'govecocode',
		xtype : 'hidden'
	},{
	    name : 'paytype',
		xtype : 'hidden'
	},{
		layout:'column',
		items:[
		{
			columnWidth:.33,
			layout: 'form',
			items:[
			enCombo
			,{ 
			    fieldLabel :'合同总金额',
			    name : 'htzje',
			    width : 120,
				xtype : 'numberfield',
				readOnly:true,
				style:'background:none;'
			}]
		},{
			columnWidth:.33,
			layout: 'form',
			items:[
				proTrigger
			,{ 
			    fieldLabel :'合同已支付',
			    name : 'htyzf',
			    width : 120,
				xtype : 'numberfield',
				readOnly:true,
				style:'background:none;'
			}]
		},{
			columnWidth:.33,
			layout: 'form',
			items:[
				contractCombo,
			{ 
			    fieldLabel :'申请金额',
			    name : 'money',
			    width : 120,
				xtype : 'numberfield'
			}]
		}]
	},{
		fieldLabel :'用途',
	    name : 'purpose',
	    width : 565,
		xtype : 'textfield'
	},{
		layout:'column',
		items:[
		{
			columnWidth:.33,
			layout: 'form',
			items:[
	        {
	    	    fieldLabel :'结算方式',
	    	    name : 'settleCb',
			    width : 120,
				xtype:'combo',
			    mode : 'local', 
		        triggerAction : 'all', 
		        hiddenName:'settletype',
		        valueField : "id", 
		        displayField : "text",
		        forceSelection:true,
		        value: '2',
		        store : new Ext.data.SimpleStore({ 
		        	fields : ["id", "text"], 
		        	data : [ 
		        	['1', '现金'], 
		        	['2', '转账']
		         	] 
		        })
	       },recCombo,
			{
			    fieldLabel :'资金性质',
			    name : 'resname',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'政府经济分类',
			    name : 'goveconame',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
				fieldLabel :'指标ID',
			    name : 'gplanid',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
				fieldLabel :'是否科研',
			    name : 'istech',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			}]
		},{
			columnWidth:.33,
			layout: 'form',
			items:[
			{
			    fieldLabel :'附单据',
			    name : 'accbills',
			    width : 120,
				xtype : 'numberfield'
			},{
				fieldLabel :'开户银行',
			    name : 'recbankname',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'预算科目',
			    name : 'funname',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'部门经济分类',
			    name : 'econame',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
				fieldLabel :'指标计划数',
			    name : 'planmoney',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			}]
		},{
			columnWidth:.33,
			layout: 'form',
			items:[
			{
				xtype:'button',
				width: 50,
				text: '指标',
				handler: function(){
					bgWin.show();
				}
			},{
				fieldLabel :'账号',
			    name : 'recbankno',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'预算项目',
			    name : 'proname',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'支出类别',
			    name : 'paytypename',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			},{
				fieldLabel :'指标可用数',
			    name : 'kymoney',
			    width : 120,
				xtype : 'textfield',
				readOnly:true,
				style:'background:none;'
			}]
		}]
	}]
});
var payWin = new Ext.Window({
	title : '支付申请',
	width : 700,
	height : 350,
	autoScroll : true,
	layout : 'fit',
	closeAction:'hide',
	modal:true,
	items : [pform],
	buttons : [{
        text : "提交",
        handler : function() {	
			Ext.Msg.confirm('确认', '提交后不可编辑，等待专管员审核，确定提交？', function(btn){
		    	if(btn == 'yes') {
		    		savePay(1); 
				}
			});
		}
	},{
        text : "保存",
        handler : function() {	
        	savePay(0); 
        }
	},{
        text : "关闭",
        handler : function() {
        	payWin.hide();
        }
	}]
});
payWin.on("show",function(){
	//加载基本信息
	var kdata={id: cID};
	Ext.Ajax.request({
		url: '../xmgl/getSingleRecord',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			keyParams : Ext.encode(kdata),
			dataID: 'paymentInfo'
		}),
		success : function(response, options) {
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		var info = o.retData;
	   			pform.getForm().setValues(info);
	   			Ext.getCmp("contractCombo").value=info.htbh;
		   	}
		},
		failure : function() {
	  	}
	});
});

function savePay(isCommit){
	//检查form
	var changedFlds = pform.getForm().getFieldValues(true);
	if(Ext.encode(changedFlds)=="{}"){
		return;
	}
	//检查
	var zje = pform.getForm().findField("htzje").getValue();
	var yzf = pform.getForm().findField("htyzf").getValue();
	var money = pform.getForm().findField("money").getValue();
	var maxMoney = Number(zje)*0.95;
	if(Number(yzf)+Number(money)>maxMoney){
		Ext.Msg.alert('信息',"本次申请金额过大，累计支付将超出合同总金额的95%。");
		return;
	}
	var kymoney = pform.getForm().findField("kymoney").getValue(); 
	if(Number(money)>kymoney){
		Ext.Msg.alert('信息',"本次申请金额不能超过指标可用金额！");
		return;
	}
	
	//id强制必传
	changedFlds.id = pform.getForm().findField("id").getValue();
	changedFlds.proid = pform.getForm().findField("proid").getValue();
	changedFlds.cid = pform.getForm().findField("cid").getValue();
	
	//istech的转化
	var istech = pform.getForm().findField("istech").getValue(); 
	changedFlds.istech = istech=="是"?1:0;
	changedFlds.settletype = pform.getForm().findField("settletype").getValue(); 
	changedFlds.paymode = 1; 
	//删除不在项目表中的冗余字段
	delete changedFlds.entername;
	delete changedFlds.pname;
	Ext.getBody().mask('正在保存……');
	Ext.Ajax.request({
		url: '../xmgl/save',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			updateParams : Ext.encode(changedFlds),
			dataID: 'paymentApply'
		}),
		success : function(response, options) {
			Ext.getBody().unmask();
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		Ext.Msg.alert('信息',"支付申请信息已"+(isCommit==1?"提交！":"保存！"));
		   		payWin.hide();
		   		ds.load({params:{start:0,limit:PAGE_SIZE}});
		   	}else{
		   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"保存信息时发生错误！");
		   	}
		},
		failure : function() {
	  	}
	});	
}
Ext.onReady(function(){
    Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    var viewport = new Ext.Viewport({
        layout:'fit',
        items:[grid]
    });
    ds.load({params:{start:0,limit:PAGE_SIZE}});
});
</script>
</head>
<body>
</body>
</html>