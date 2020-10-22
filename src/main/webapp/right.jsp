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
var cbRecord = Ext.data.Record.create([
	{name : 'bm',type : 'string'}, 
	{name : 'mc',type : 'string'}
]);
var optypeDs = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: 'xmgl/queryList',
        headers: {
			"Content-Type": "application/json;charset=utf-8"
		}
    }),
    reader : new Ext.data.JsonReader({
        idProperty : 'bm',
        root:"retData.rows",
    }, cbRecord)
});
optypeDs.on("beforeload",function(store,options){
	
	optypeDs.baseParams={
		jsonData: Ext.encode({
			dataID : 'logTemplates',
			queryParams : {}
		})
	};
});
optypeDs.load({});
var ssm = new Ext.grid.CheckboxSelectionModel({singleSelect: false}); 
ssm.handleMouseDown = Ext.emptyFn;
var ccm = new Ext.grid.ColumnModel({
	columns:[
	ssm,
	{
		header: "操作类型",
		dataIndex: 'opname',
		width: 160,
		align: 'left',
		renderer: renderFoo
	},{
	    header: "操作者",
	    dataIndex: 'username',
	    width: 100,
	    align:'left',
	    renderer :renderFoo
	},{
	    header: "时间",
	    dataIndex: 'ctime',
	    width: 150,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "内容",
	    dataIndex: 'content',
	    width: 380,
	    align:'left',
		renderer: renderFoo
	},{
	    header: "详情",
	    dataIndex: '',
	    width: 100,
	    align:'center',
	    renderer :renderDetail
	}],
	defaultSortable: true
});
function renderDetail(v,p,r){
	return '<a onclick=showInfo("'+id+'") style=text-decoration:underline;color:blue;>详情</a>';
}
function showInfo(id){
	
}
var cRd = Ext.data.Record.create  ([
    {name: 'id', type: 'int'},
	{name: 'optype', type: 'string'},
	{name: 'opname', type: 'string'},
	{name: 'userid', type: 'string'},
	{name: 'username', type: 'string'},
	{name: 'content', type: 'string'},
	{name: 'ctime', type: 'string'}
]);
var ds = new Ext.data.Store({
	proxy: new Ext.data.HttpProxy({   
        method: 'post',   
        url: 'xmgl/queryListPaging',
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
	var optype = Ext.getCmp('optype').getValue();
	var hasread = Ext.getCmp('hasread').getValue();
	var p = {
		optype: optype?optype:"",
		hasread: hasread
	}
	var jparams = {
		start: st,
		limit: lm,
		qParams: p
	}
	ds.baseParams={
		jsonData: Ext.encode({
			dataID : 'opLogs',
			queryParams : jparams
		})
	};
});
var grid = new Ext.grid.GridPanel({
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
		text :'操作类型：'
	},{
		xtype:'combo',
		name : 'opTypeCb',
		width : 150,
		id: 'optype',
		displayField : 'mc',
	    valueField : 'bm',
	    typeAhead : true,
	    mode : 'local',
	    triggerAction : 'all',
	    emptyText : '',
	    selectOnFocus : true,
	    editable : false,
	    store : optypeDs
	},new Ext.Toolbar.Separator(),{
		xtype: 'label',
		text :'是否已读：'
	},{
		xtype:'combo',
		name : 'readCb',
		width : 100,
		id: 'hasread',
		displayField : 'mc',
	    valueField : 'bm',
	    typeAhead : true,
	    mode : 'local',
	    triggerAction : 'all',
	    emptyText : '',
	    selectOnFocus : true,
	    editable : false,
	    store : new Ext.data.SimpleStore({ 
        	fields : ["bm", "mc"], 
        	data : [ 
        	['0', '未读'],
        	['1', '已读'], 
        	['', '全部']
         	] 
        })
	},new Ext.Toolbar.Separator(),{
		text: '删除',
		iconCls: 'remove',
		handler : function(){
			var rds = grid.getSelectionModel().getSelections();
			if(!rds||rds.length<1){
				Ext.Msg.alert("提示","请先选择要删除的记录！");
				return;
			}
			var ls = new Array();
			for(var i=0;i<rds.length;i++){
				ls.push(rds[i].get("id"));
			}
			var dInfo = {
				lids: ls.join("|")	
			};
			Ext.Ajax.request({
				url: 'xmgl/delete',
				method : 'post',
				headers: {
					"Content-Type": "application/json;charset=utf-8"
				},
				params : Ext.encode({
					delParams : Ext.encode(dInfo),
					dataID: 'opLogs'
				}),
				success : function(response, options) {
					Ext.getBody().unmask();
				   	var o = Ext.util.JSON.decode(response.responseText);
				   	if(o&&o.retCode=="0"){
				   		Ext.Msg.alert('提示',"日志已删除！");
				   	}else{
				   		Ext.Msg.alert('错误',o&&o.retMsg?o.retMsg:"删除日志时发生错误！");
				   	}
				},
				failure : function() {
			  	}
			});	
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