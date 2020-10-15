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
<title>项目生成</title>
<style type="text/css">
.x-grid3-cell-text-visible .x-grid3-cell-inner{overflow:visible;padding:3px 3px 3px 5px;white-space:normal;}
</style>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/libs/ext-3.4.0/resources/css/ext-all.css" />
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/css/dfCommon.css" />
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/ext-all.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/src/locale/ext-lang-zh_CN.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/Ext.ux.tree.TreeCheckNodeUI.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/GridExporter.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/ExportGridPanel.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/js/BuildGrid.js"></script>
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
			dataID : 'generatedProjects',
			queryParams : jparams
		})
	};
});
var grid = new Ext.grid.GridPanel({
	id:'generatedProjects',
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
var essm = new Ext.grid.CheckboxSelectionModel({singleSelect: false}); 
essm.handleMouseDown = Ext.emptyFn;
var eccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var epRd = Ext.data.Record.create([]);
var eds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: '../xmgl/queryListPaging',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
	remoteSort: true,
	reader: new Ext.data.JsonReader({
		idProperty:'procode',
		root: 'retData.rows',
		totalProperty: 'retData.totalCount'
	}, epRd)
});
eds.on("beforeload",function(store,options){
	var st = options.params.start;
	var lm = options.params.limit;
	var proname = Ext.getCmp('fltEPname').getValue();
	var p = {
		proname: proname?proname:"",
		mapFlag : 0
	};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	};
	eds.baseParams={
		jsonData: Ext.encode({
			dataID : 'EProjects',
			queryParams : jparams
		})
	};
});
var egrid = new Ext.grid.GridPanel({
	id:'EProjects',
	title:'',
	store: eds,
	cm: eccm,
	selModel: essm,
	frame:false,
	stripeRows: true,
	loadMask: {msg:'正在加载数据....'},
	enableColumnMove: false,
	tbar: [{
		xtype: 'label',
		text :'项目名称：'
	},{
		xtype:'textfield',
		fieldLabel:'名称',
		width:150,
		enableKeyEvent:true,
		id: 'fltEPname',
		hideLabel:true
	},{
		text: '搜索',
		iconCls: 'filter',
		handler : function(){
			eds.load({params:{start:0,limit:PAGE_SIZE}});
		}
	},new Ext.Toolbar.Separator(),{
		text:"映射到已有项目",
		iconCls:"autoMap",
		handler: function(){
			var erd = egrid.getSelectionModel().getSelections();
			if(!erd||erd.length<1){
				Ext.Msg.alert("提示","请先选择要映射的E财项目！");
				return;
			}
			emapWin.show();
		}
	},{
		text:"引入为新项目",
		iconCls:"add",
		handler: function(){
			var erds = egrid.getSelectionModel().getSelections();
			if(!erds||erds.length<1){
				Ext.Msg.alert("提示","请先选择要引入的E财项目！");
				return;
			}
			
			var ecodes = new Array();
			for(var i=0;i<erds.length;i++){
				ecodes.push(erds[i].get("procode"));
			}
			Ext.Msg.confirm('确认', '该操作会在系统中增加项目，基本信息从选中的E财项目复制，是否继续？', function(btn){
    	    	if(btn == 'yes') {
    	    		Ext.getBody().mask('正在引入项目……');
    	    		var adata = {
    	    			epcodes: ecodes.join("|")	
    	    		}; 
    	    		Ext.Ajax.request({
    	    			url: '../xmgl/save',
    	    			method : 'post',
    	    			headers: {
    	    				"Content-Type": "application/json;charset=utf-8"
    	    			},
    	    			params : Ext.encode({
    	    				updateParams : Ext.encode(adata),
    	    				dataID: 'addProFromE'
    	    			}),
    	    			success : function(response, options) {
    	    			   	var o = Ext.util.JSON.decode(response.responseText);
    	    			   	if(o&&o.retCode=="0"){
    	    			   		Ext.Msg.show({
    	    			   		   title:'信息',
    	    			   		   msg: "从E财系统引入了"+erds.length+"个新项目！",
    	    			   		   buttons: Ext.Msg.OK
    	    			   		});
    	    			   		ds.load({params:{start:0,limit:PAGE_SIZE}});
    	    					eds.load({params:{start:0,limit:PAGE_SIZE}});
    	    			   	}else if(o&&o.retCode!="0"){
    	    			   		Ext.Msg.alert('错误',"从E财系统引入项目时发生错误！"+o&&o.retMsg?o.retMsg:"");
    	    			   	}else{
    	    			   		Ext.Msg.alert('错误',"从E财系统引入项目时发生错误！");
    	    			   	}
    	    			   	Ext.getBody().unmask();
    	    			},
    	    			failure : function(response,options) {
    	    				Ext.Msg.alert('错误',"从E财系统引入项目失败，详细错误请咨询管理员！");
    	    				Ext.getBody().unmask();
    	    		  	}
    	    		});
				}
			});
		}
	}],
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: eds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
 
var pssm = new Ext.grid.CheckboxSelectionModel({header:'',singleSelect: true}); 
pssm.handleMouseDown = Ext.emptyFn;
var pccm = new Ext.grid.ColumnModel({
	columns: [],
	defaultSortable: true
});
var mproRd = Ext.data.Record.create([]);
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
	var pname = Ext.getCmp('fltMPname').getValue();
	var p = {pname: pname?pname:""};
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	pds.baseParams={
		jsonData: Ext.encode({
			dataID : 'generatedProjects',
			queryParams : jparams
		})
	};
});
var proGrid = new Ext.grid.GridPanel({
	id:'existedProjects',
	title:'',
	store: pds,
	cm: pccm,
	selModel: pssm,
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
		id: 'fltMPname',
		hideLabel:true
	},{
		text: '搜索',
		iconCls: 'filter',
		handler : function(){
			pds.load({params:{start:0,limit:PAGE_SIZE}});
		}
	}],
	bbar: new Ext.PagingToolbar({
	    pageSize: PAGE_SIZE,
	    store: pds,
	    displayInfo: true,
	    displayMsg: '当前显示 {0} - {1} ，共{2}条记录',
	    emptyMsg: "没有数据",
	    items: ['-']
	})
});
var emapWin=new Ext.Window({
	title : '系统项目库',
	width : 640,
	height : 480,
	autoScroll : true,
	layout : 'fit',
	closeAction:'hide',
	modal:true,
	items : [proGrid],
	buttons : [{
        text : "确定",
        handler : function() {	
			var prds = proGrid.getSelectionModel().getSelections();
			if(!prds||prds.length<1){
				Ext.Msg.alert("提示","请先选择要映射的系统项目！");
				return;
			}
			var erds = egrid.getSelectionModel().getSelections();
			if(!erds||erds.length<1){
				Ext.Msg.alert("提示","请先选择要映射的E财项目！");
				return;
			}
			var ecodes = new Array();
			for(var i=0;i<erds.length;i++){
				ecodes.push(erds[i].get("procode"));
			}
			Ext.Msg.confirm('确认', '该操作会在选中的E财项目和本系统项目之间建立映射，是否继续？', function(btn){
		    	if(btn == 'yes') {
		    		var mdata = {
	    	    		epcodes: ecodes.join("|"),
	    	    		zp_id: prds[0].get("id")
	    	    	}; 
		    		Ext.Ajax.request({
    	    			url: '../xmgl/save',
    	    			method : 'post',
    	    			headers: {
    	    				"Content-Type": "application/json;charset=utf-8"
    	    			},
    	    			params : Ext.encode({
    	    				updateParams : Ext.encode(mdata),
    	    				dataID: 'proMapE2Z'
    	    			}),
    	    			success : function(response, options) {
    	    			   	var o = Ext.util.JSON.decode(response.responseText);
    	    			   	if(o&&o.retCode=="0"){
    	    			   		Ext.Msg.alert('信息',o&&o.info?o.info:"已建立映射关系！");
    	    			   		emapWin.hide();
    	    			   		ds.load({params:{start:0,limit:PAGE_SIZE}});
    	    					eds.load({params:{start:0,limit:PAGE_SIZE}});
    	    			   	}
    	    			},
    	    			failure : function() {
    	    		  	}
    	    		});	
				}
			});
		}
	},{
        text : "关闭",
        handler : function() {
        	emapWin.hide();
        }
	}]
});
emapWin.on("show",function(){
	Ext.getCmp("fltMPname").setValue("");
	pds.load({params:{start:0,limit:PAGE_SIZE}});
});
var ptab ; 
Ext.onReady(function(){
	Ext.QuickTips.init();
	buildGrid("generatedProjects",ds,ssm,"id",function(){
		
		buildGrid("EProjects",eds,essm,"procode",function(){
			
			ptab = new Ext.TabPanel({  
				id:'ptab',
				activeTab:0,  
				frame: true,
				enableTabScroll:true,
				layoutOnTabChange:true,
				items:[
				{
					layout:'fit',
			        title: '已生成项目',
			        closable: false,
			        items: grid 
			    },{
					layout:'fit',
			        title: 'E财新项目',
			        closable: false,
			        items: egrid 
			    }]
			});
			new Ext.Viewport({
				layout:'fit',
		        items:[ptab]
			});
			ds.baseParams.sort = "ctime";
			ds.baseParams.dir = "desc";
			ds.load({params:{start:0,limit:PAGE_SIZE}});
			eds.load({params:{start:0,limit:PAGE_SIZE}});
		});
	});
	buildGrid("existedProjects",pds,pssm,"id",function(){});
});
</script>
</head>
<body>
</body>
</html>