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
<title>合同基础信息维护</title>
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
var cHtRd ,cCid,cFld,RemovedAccs = new Array();
var LockInfo = new Object();
var ssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
ssm.handleMouseDown = Ext.emptyFn;
var ccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var conRd = Ext.data.Record.create([]);
var ds = new Ext.data.GroupingStore({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryListPaging',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	groupField: 'proid',
	reader: new Ext.data.JsonReader({
		idProperty:'cmpid',
		root: 'retData.rows',
		totalProperty: 'retData.totalCount'
	}, conRd)
});
ds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var pname = Ext.getCmp('fltPname').getValue();
	var p = { qname: pname?pname:""};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	ds.baseParams={
		jsonData: Ext.encode({
			dataID : 'contractsMaintain',
			queryParams : jparams
		})
	};
});
var grid = new Ext.grid.GridPanel({
	id:'contractsMaintain',
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
		text :'项目名称/合同名称/合同编号：'
	},{
		xtype:'textfield',
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
		text: '添加合同',
		iconCls: 'add',
		handler : function(){
			var rds = grid.getSelectionModel().getSelections();
			if(!rds||rds.length<1){
				Ext.Msg.alert("提示","请先选择项目！");
				return;
			}
			cHtRd = rds[0];
			cCid = '-1';
			
			conWin.show();
		}
	},{
		text: '详情',
		iconCls: 'details',
		handler : function(){
			var rds = grid.getSelectionModel().getSelections();
			if(!rds||rds.length<1){
				Ext.Msg.alert("提示","请先选择合同！");
				return;
			}
			cHtRd = rds[0];
			cCid = rds[0].get('id');
			conWin.show();
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
var cbRecord = Ext.data.Record.create([
	{name : 'bm',type : 'string'}, 
	{name : 'mc',type : 'string'}
]);
var htypeDs = new Ext.data.Store({
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
htypeDs.on("beforeload",function(store,options){
	var jparams = {
		qParams: {'table_bm':'BM_GCITEM'}
	}
	htypeDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'comboOptions',
			queryParams : jparams
		})
	};
});
htypeDs.load({});

var cform = new Ext.FormPanel({
	id:"contractform",
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
		value: '-1'
	},{
	    name : 'proid',
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
               		columnWidth : ".85",
               		border: true,
                    xtype : 'container',
                    labelWidth: 140,
                    layout : 'form',
					items: [{
						fieldLabel :'招标文件审核意见书',
					    name : 'zbwjsh',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_zbwjsh',
		                handler: fileUpload
					}]
				}]
			},{
			    fieldLabel :'合同名称',
			    name : 'mc',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'建设单位（甲方）',
			    name : 'jsdwmc',
			    width : 150,
				xtype : 'textfield',
				readOnly: true,
				style:'background:none;'
			},{
				fieldLabel :'建设单位曾用名',
			    name : 'jsdwcym',
			    width : 150,
				xtype : 'textfield'
			},{
				fieldLabel :'建设单位联系方式',
			    name : 'jsdwlxfs',
			    width : 150,
				xtype : 'textfield'
			}]
		},{
			columnWidth:.5,
			layout: 'form',
			items:[
			{
				xtype:'combo',
				fieldLabel :'合同类别',
				name : 'htypeCb',
				width : 150,
				hiddenName: 'htype',
				displayField : 'mc',
			    valueField : 'bm',
			    typeAhead : true,
			    mode : 'local',
			    triggerAction : 'all',
			    emptyText : '',
			    selectOnFocus : true,
			    editable : false,
			    store : htypeDs
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
						fieldLabel :'合同编号',
					    name : 'htbh',
					    width : 150,
						xtype : 'textfield'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_btbh',
		                handler: fileUpload
					}]
				}]
			},{
			    fieldLabel :'施工单位',
			    name : 'sgdw',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'施工单位变更名',
			    name : 'sgdwbgmc',
			    width : 150,
				xtype : 'textfield'
			},{
			    fieldLabel :'施工单位联系方式',
			    name : 'sgdwlxfs',
			    width : 150,
				xtype : 'textfield'
			}]
		}]
	},{
		fieldLabel :'合同支付条款说明',
	    name : 'zftksm',
	    width : 500,
	    height: 50,
		xtype : 'textarea'
	},{
		layout:'column',
		items:[
		{
			columnWidth:.5,
			layout: 'form',
			items:[{
			    fieldLabel :'合同签订金额',
			    name : 'htqdje',
			    width : 150,
				xtype : 'numberfield'
			},{
			    fieldLabel :'其中：文明施工费',
			    name : 'wmsgf',
			    width : 150,
				xtype : 'numberfield'
			},{
			    fieldLabel :'签订合同总额',
			    name : 'htze',
			    width : 150,
				xtype : 'numberfield'
			},{
			    fieldLabel :'合同报审金额',
			    name : 'htbsje',
			    width : 150,
				xtype : 'numberfield'
			},{
			    fieldLabel :'合同审定金额',
			    name : 'htsdje',
			    width : 150,
				xtype : 'numberfield'
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
						fieldLabel :'补充合同',
					    name : 'contractappendix',
					    width : 150,
					    readOnly:true,
						style:'background:none;'
					}]
				},{
					columnWidth : ".15",
					items: [{
						name : 'change',
		                xtype: 'button',
		                text: '附件',
		                id: 'btn_contractappendix',
		                handler: fileUpload
					}]
				}]
			},{
			    fieldLabel :'本类合同金额小计',
			    name : 'htypezje',
			    width : 150,
				xtype : 'numberfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'累计支付额度',
			    name : 'ljzfje',
			    width : 150,
				xtype : 'numberfield',
				readOnly:true,
				style:'background:none;'
			},{
			    fieldLabel :'历史支付额度',
			    name : 'lszfje',
			    width : 150,
				xtype : 'numberfield'
			},{
			    fieldLabel :'累计支付占比',
			    name : 'ljzfzb',
			    width : 150,
				xtype : 'numberfield',
				readOnly:true,
				style:'background:none;'
			}]
		}]
	}]
});	
var fccm = new Ext.grid.ColumnModel({
	columns:[{
		header: "文件名称",
		dataIndex: 'filename',
		width: 190,
		align: 'left',
		renderer: renderFoo
	},{
	    header: "合同金额",
	    dataIndex: 'je',
	    width: 100,
	    align:'center',
	    renderer :regMoney
	},{
	    header: "上传时间",
	    dataIndex: 'ctime',
	    width: 120,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "上传人",
	    dataIndex: 'uploaduser',
	    width: 80,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "文件大小",
	    dataIndex: 'fsize',
	    width: 80,
	    align:'left'
	},{
	    header: "操作",
	    dataIndex: '',
	    width: 100,
	    align:'center',
	    renderer :renderAttach
	}],
	defaultSortable: true
});
var fRd = Ext.data.Record.create([
    {name: 'id', type: 'int'},
	{name: 'cid', type: 'int'},
	{name: 'fid', type: 'string'},
	{name: 'filename', type: 'string'},
	{name: 'fld', type: 'string'},
	{name: 'filetype', type: 'string'},
	{name: 'ufname', type: 'string'},
	{name: 'ctime', type: 'string'},
	{name: 'fsize', type: 'string'},
	{name: 'uploaduser', type: 'string'},
	{name: 'je', type: 'float'}
]);
var fds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows'
	}, fRd)
});
fds.on("beforeload",function(store,options){
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("proid");
	var p = {proid: proid,cid: cCid};
	var jparams = {
		qParams: p
	}
	fds.baseParams={
		jsonData: Ext.encode({
			dataID : 'contractAppendices',
			queryParams : jparams
		})
	};
});
var fileGrid = new Ext.grid.GridPanel({
	title:'',
	store: fds,
	cm: fccm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false
});

var pccm = new Ext.grid.ColumnModel({
	columns:[{
	    header: "收款单位",
	    dataIndex: 'skdw',
	    width: 200,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "金额",
	    dataIndex: 'je',
	    width: 100,
	    align:'right',
	    renderer :regMoney
	},{
		header: "支付时间",
		dataIndex: 'ctime',
		width: 120,
		align: 'left',
		renderer: renderFoo
	},{
	    header: "开户行",
	    dataIndex: 'khbank',
	    width: 180,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "收款账户",
	    dataIndex: 'account',
	    width: 80,
	    align:'left'
	}],
	defaultSortable: true
});
var pRd = Ext.data.Record.create([
    {name: 'id', type: 'int'},
	{name: 'cid', type: 'int'},
	{name: 'skdw', type: 'string'},
	{name: 'khbank', type: 'string'},
	{name: 'account', type: 'string'},
	{name: 'je', type: 'float'},
	{name: 'ctime', type: 'string'}
]);
var pds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/getContractPayments',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'id',
		root: 'retData.rows'
	}, pRd)
});
pds.on("beforeload",function(store,options){
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("proid");
	var p = {proid: proid,cid: cCid};
	var jparams = {
		qParams: p
	}
	pds.baseParams={
		jsonData: Ext.encode({
			dataID : 'paymentHistory',
			queryParams : jparams
		})
	};
});
var payGrid = new Ext.grid.GridPanel({
	id:'paymentHistory',
	title:'',
	store: pds,
	cm: pccm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false
});

var bssm = new Ext.grid.CheckboxSelectionModel({singleSelect: false}); 
bssm.handleMouseDown = Ext.emptyFn;
var bccm = new Ext.grid.ColumnModel({
	columns:[
	bssm,
   	{
   		header: "收款单位",
   		dataIndex: 'skdw',
   		width: 250,
   		align: 'left',
   		editor: new Ext.form.TextField({selectOnFocus:true,maxLength:100})  
   	},{
   	    header: "开户银行",
   	    dataIndex: 'khbank',
   	    width: 250,
   	    align:'left',
   	 	editor: new Ext.form.TextField({selectOnFocus:true,maxLength:200})  
   	},{
   	    header: "账号",
   	    dataIndex: 'account',
   	    width: 150,
   	    align:'left',
   	 	editor: new Ext.form.TextField({selectOnFocus:true,maxLength:100})  
   	}],
	defaultSortable: true
});
var bRd = Ext.data.Record.create([
    {name: 'id', type: 'int'},
	{name: 'cid', type: 'int'},
	{name: 'skdw', type: 'string'},
	{name: 'khbank', type: 'string'},
	{name: 'account', type: 'string'}
]);
var bds = new Ext.data.Store({
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
	}, bRd)
});
bds.on("beforeload",function(store,options){
	var rds = grid.getSelectionModel().getSelections();
	var proid = rds[0].get("proid");
	var p = {proid: proid,cid: cCid};
	var jparams = {
		qParams: p
	}
	bds.baseParams={
		jsonData: Ext.encode({
			dataID : 'contractBank',
			queryParams : jparams
		})
	};
});
var bankGrid = new Ext.grid.EditorGridPanel({
	id:'contractBanks',
	title:'',
	store: bds,
	cm: bccm,
	selModel: bssm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	clicksToEdit:1,
	enableColumnMove: false,
	tbar:[{
		text: '添加行',
		id:'btn_contractBanks_add',
		iconCls: 'add',
		handler : function(){
			if(LockInfo.contractBanks=="1"){
				return;
			}
			var rds = grid.getSelectionModel().getSelections();
		    var bk = new bRd({
		    	id: -1,
		    	cid: cCid,
		    	skdw: '',
		    	khbank: '',
		    	account:''
		    });
		    bankGrid.stopEditing();
		    bds.insert(bds.getCount(), bk);
		}
	},{
		text: '删除',
		id:'btn_contractBanks_remove',
		iconCls: 'remove',
		handler :function(){
			if(LockInfo.contractBanks=="1"){
				return;
			}
		    var records = bankGrid.getSelectionModel().getSelections();
		    if(!records||records.length<1){
				Ext.Msg.alert("提示","请先选择要删除的行!");
				return;
			}	
			if(records){
				for(var rc=0;rc<records.length;rc++){						    	    	
					bds.remove(records[rc]);
					//只记录非本次新增行的删除
					if(records[rc].get("id")!=-1){
						RemovedBanks.push(records[rc].get("id"));
					}
				}
				
		    }
		}
	},{
		text: '保存',
		iconCls: 'Save',
		id: 'btn_contractBanks_save',
		handler : function(){
			if(LockInfo.contractBanks=="1"){
				return;
			}
			saveBankInfo(false);
		}
	}]
});
bankGrid.on('beforeedit',function(e){ 
	//如果是已经锁定的，不能修改
	if(LockInfo.contractBanks=="1"){
		e.cancel = true;
	}
});
function saveBankInfo(silent){
	var cAccs = buildBankInfo();
	if(!cAccs.removedAccs&&!cAccs.modifiedAccs&&!cAccs.newAccs){
		return;
	}
	if(!cCid|| Number(cCid)<0){
		var cInfo={ 
			proid : cHtRd.get("proid"),
			pname : cHtRd.get("pname")
		};
		Ext.Ajax.request({
			url: '../xmgl/save',
			method : 'post',
			headers: {
				"Content-Type": "application/json;charset=utf-8"
			},
			params : Ext.encode({
				updateParams : Ext.encode(cInfo),
				dataID: 'initContract'
			}),
			success : function(response, options) {
				Ext.getBody().unmask();
			   	var o = Ext.util.JSON.decode(response.responseText);
			   	if(o&&o.retCode=="0"){
			   		cCid = o.retData.info;
			   		cHtRd.set("id",o.retData.info);
			   		cform.getForm().findField("id").setValue(o.retData.info);
			   		saveBankRows(cAccs,silent);
			   	}else{
			   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"增加合同信息时发生错误！");
			   	}
			},
			failure : function() {
		  	}
		});	
	}else{
		saveBankRows(cAccs,silent);
	}
}
function buildBankInfo(){
	var mAccs = new Array();
	var newAccs = new Array();
	//修改
	for(var i=0;i<bds.getModifiedRecords().length;i++){
		var r = bds.getModifiedRecords()[i];
		//只记录非本次新增行、发生变动的字段，名值对形式的object
		if(r.get("id")!=-1){
			var o = r.getChanges();
			o.id = r.get("id");
			mAccs.push(o);
		}
	}
	//新增
	for(var i=0;i<bds.getCount();i++){
		var r = bds.getAt(i);
		//记录本次新增行
		if(r.get("id")==-1){
			newAccs.push(r.data);
		}
	}
	var changedAccs ={
		removedAccs : RemovedAccs.length>0?Ext.encode(RemovedAccs):"",
		modifiedAccs: mAccs.length>0?Ext.encode(mAccs):"",
		newAccs: newAccs.length>0?Ext.encode(newAccs):""
	};
	return changedAccs;
}
function saveBankRows(cAccs,silent){
	var cid = cCid;
	Ext.getBody().mask('正在保存……');
	Ext.Ajax.request({
		url: '../xmgl/saveBankInfo',
		method : 'post',
		headers: {
			"Content-Type": "application/json;charset=utf-8"
		},
		params : Ext.encode({
			proid :cHtRd.get("proid"),
			cid : cid,
			rowsInfo: Ext.encode(cAccs)
		}),
		success : function(response, options) {
			Ext.getBody().unmask();
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		if(!silent){
		   			Ext.Msg.show({
			   		   title:'信息',
			   		   msg: "银行开户信息已保存！",
			   		   buttons: Ext.Msg.OK
			   		});
		   		}
		   		RemovedAccs = new Array();
				bds.commitChanges();
				bds.load({});
		   	}else if(o&&o.retCode!="0"){
		   		Ext.Msg.alert('错误',"保存银行开户信息时发生错误！"+o&&o.retMsg?o.retMsg:"");
		   	}else{
		   		Ext.Msg.alert('错误',"保存银行开户信息时发生错误！");
		   	}
		},
		failure : function(response,options) {
			Ext.Msg.alert('错误',"保存银行开户信息时发生错误，详细错误请咨询管理员！");
			Ext.getBody().unmask();
	  	}
	});
}
var contractTab = new Ext.TabPanel({  
	id:'contractTab',
	activeTab:0,  
	frame: true,
	enableTabScroll:true,
	layoutOnTabChange:true,
	items:[
	{
		layout:'fit',
        title: '补充合同',
        closable: false,
        items: fileGrid 
    },{
		layout:'fit',
        title: '银行开户信息',
        closable: false,
        items: bankGrid 
    },{
		layout:'fit',
        title: '合同已拨付记录',
        closable: false,
        autoScroll:true,
        items: payGrid 
    }]
});
var conWin = new Ext.Window({
	title : '合同信息',
	width : 735,
	height : 560,
	closeAction:'hide',
	modal:true,
	layout : 'border',
	items : [{
    	region:'north',
    	height: 330,
    	autoScroll : true,
    	items: cform
    },{
    	region:'center',
    	layout : 'fit',
    	items: contractTab
    }],
	buttons : [{
        text : "提交",
        id: 'btn_submit',
        handler : function() {	
			Ext.Msg.confirm('确认', '提交后不可编辑，等待专管员核定，确定提交？', function(btn){
		    	if(btn == 'yes') {
		    		var changedFlds = cform.getForm().getFieldValues(true);
		    		saveContract(changedFlds,1); 
				}
			});
		}
	},{
        text : "保存",
        id: 'btn_save',
        handler : function() {	
        	var changedFlds = cform.getForm().getFieldValues(true);
        	saveContract(changedFlds,0); 
        }
	},{
        text : "关闭",
        handler : function() {
        	conWin.hide();
        }
	}]
});
conWin.on("show",function(){
	//按钮可用情况
	var issubmit = cHtRd.get("issubmit");
	if(issubmit==1){
		Ext.getCmp("btn_submit").disable();
		Ext.getCmp("btn_save").disable();
	}else{
		Ext.getCmp("btn_submit").enable();
		Ext.getCmp("btn_save").enable();
	}
	if(cCid=='-1'){
		cform.getForm().findField("jsdwmc").setValue(cHtRd.get("jsdwmc"));
		cform.getForm().findField("id").setValue(-1);
		bds.load({});
		fds.load({});
		pds.load({});
	}else{
		//加载合同信息
		var kdata={proid :cHtRd.get("proid"), id: cCid};
		Ext.Ajax.request({
			url: '../xmgl/getSingleRecord',
			method : 'post',
			headers: {
				"Content-Type": "application/json;charset=utf-8"
			},
			params : Ext.encode({
				keyParams : Ext.encode(kdata),
				dataID: 'contractInfo'
			}),
			success : function(response, options) {
			   	var o = Ext.util.JSON.decode(response.responseText);
			   	if(o&&o.retCode=="0"){
			   		var info = o.retData;
		   			cform.getForm().setValues(info);
		   			cCid = info.id;
		   			//获取lock状态，确定字段的只读/可编辑
		   			var lockParams = {
		   				qParams:{ module:'1',mkey: info.id}
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
		   				   					if(cform.getForm().findField(o.fld)){
		   				   						if(o.islock==1){
		   				   							cform.getForm().findField(o.fld).disable();
		   				   						}else{
		   				   							cform.getForm().findField(o.fld).enable();
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
		bds.load({});
		fds.load({});
		pds.load({});
	}
	
});
function saveContract(changedFlds,issubmit){
	if(Ext.encode(changedFlds)=="{}"){
		//开户行保存
   		saveBankInfo(true);
	}else{
		changedFlds.proid =  cHtRd.get("proid");
		changedFlds.pname = cHtRd.get("pname");
		changedFlds.cid = cCid;
		changedFlds.htbh = cform.getForm().findField("htbh").getValue();
		//删除不在项目表中的冗余字段
		delete changedFlds.jsdwmc;
		delete changedFlds.contractappendix;
		Ext.Ajax.request({
			url: '../xmgl/save',
			method : 'post',
			headers: {
				"Content-Type": "application/json;charset=utf-8"
			},
			params : Ext.encode({
				updateParams : Ext.encode(changedFlds),
				dataID: 'contractInfo'
			}),
			success : function(response, options) {
				Ext.getBody().unmask();
			   	var o = Ext.util.JSON.decode(response.responseText);
			   	if(o&&o.retCode=="0"){
			   		cCid = o.retData.info;
				   	cHtRd.set("",o.retData.info);
				    //开户行保存
			   		saveBankInfo(true);
			   		Ext.Msg.alert('信息',"合同信息已保存！");
			   		ds.load({params:{start:0,limit:PAGE_SIZE}});
			   	}else{
			   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"保存时发生错误！");
			   	}
			},
			failure : function() {
		  	}
		});	
	}
}
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
		columnWidth:.40,
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
		columnWidth:.25,
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
				if(cFld=='contractappendix'){
					var je = uploadForm.getForm().findField("appendixJe").getValue();
					if(!je||je==""){
						Ext.Msg.alert('提示',"请输入补充合同的金额！");
						return;
					}
				}
			    uploadFile(uploadForm, cFld,function(fid){
			    	//加载数据
					ads.load({params:{start:0, limit:PAGE_SIZE}});
					Ext.getCmp("attachFilePath").setRawValue('');
					//如果是合同附件，上传完成后，更新金额、合同总额等数据
					if(cFld=='contractappendix'){
						var uInfo = {
							proid : cHtRd.get("proid"),
							pname : cHtRd.get("pname"),
							cid: cCid,
							fid: fid, 
							je: uploadForm.getForm().findField("appendixJe").getValue()
						}
						Ext.Ajax.request({
							url: '../xmgl/save',
							method : 'post',
							headers: {
								"Content-Type": "application/json;charset=utf-8"
							},
							params : Ext.encode({
								updateParams : Ext.encode(uInfo),
								dataID: 'contractAppendixJe'
							}),
							success : function(response, options) {
								Ext.getBody().unmask();
							   	var o = Ext.util.JSON.decode(response.responseText);
							   	if(o&&o.retCode=="0"){
							   		cForm.getForm().findField("htze").setValue(p.retData.info);
							   	}else{
							   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"保存时发生错误！");
							   	}
							},
							failure : function() {
						  	}
						});	
					}
			    });
			}
		}]
	},{
		columnWidth:.35,
		layout: 'form',
		id:'colAppendixJe',
		labelWidth: 80,
		labelAlign: 'right',
		items:[
		{
			fieldLabel: '合同附件金额',
			width:80,
			xtype: 'textfield',
			name: 'appendixJe',
		}]
	}]
});

function uploadFile(ufm,rltFld,fn){
	Ext.Msg.wait("正在导入...");
    ufm.getForm().submit({
  	timeout: 10*60*1000,
  	url :'../xmgl/uploadAttachment',
		params:{
			uaParams: Ext.encode({module:'1', mkey :cCid, fld: rltFld})
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
				fn(obj.infos.newFid);
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
	var p = {cid: cCid,fld: cFld};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	ads.baseParams={
		jsonData: Ext.encode({
			dataID : 'contractAttachFiles',
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
    	height: 60,
    	frame: true,
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
	if(cFld=='contractappendix'){
		Ext.getCmp("colAppendixJe").show();
	}else{
		Ext.getCmp("colAppendixJe").hide();
	}
	if(LockInfo[cFld]=="1"){//如果当前字段锁定，弹出的附件窗体，form中不可上传。
		Ext.getCmp('btn_commonUpload').disable();
		uploadForm.getForm().findField("filepath").disable();
		uploadForm.getForm().findField("appendixJe").disable();
	}else{
		Ext.getCmp('btn_commonUpload').enable();
		uploadForm.getForm().findField("filepath").enable();
		uploadForm.getForm().findField("appendixJe").enable();
	}
	if(!cCid|| Number(cCid)<0){
		var cInfo={ 
			proid : cHtRd.get("proid"),
			pname : cHtRd.get("pname")
		};
		Ext.Ajax.request({
			url: '../xmgl/save',
			method : 'post',
			headers: {
				"Content-Type": "application/json;charset=utf-8"
			},
			params : Ext.encode({
				updateParams : Ext.encode(cInfo),
				dataID: 'initContract'
			}),
			success : function(response, options) {
				Ext.getBody().unmask();
			   	var o = Ext.util.JSON.decode(response.responseText);
			   	if(o&&o.retCode=="0"){
			   		alert(o.retData.info);
			   		cCid = o.retData.info;
			   		cHtRd.set("id",o.retData.info);
			   		cform.getForm().findField("id").setValue(o.retData.info);
			   		fileWin.show();
			   	}else{
			   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"增加合同信息时发生错误！");
			   	}
			},
			failure : function() {
		  	}
		});	
	}else{
		fileWin.show();
	}
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
	buildGrid("contractsMaintain",ds,ssm,"cmpid",function(){
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