if (!Ext.grid.GridView.prototype.templates) {  
	   Ext.grid.GridView.prototype.templates = {};  
	}  
	Ext.grid.GridView.prototype.templates.cell = new Ext.Template(  
	   '<td class="x-grid3-col x-grid3-cell x-grid3-td-{id} x-selectable {css}" style="{style}" tabIndex="0" {cellAttr}>',  
	   '<div class="x-grid3-cell-inner x-grid3-col-{id}" {attr}>{value}</div>',  
	   '</td>'  
	); 
//千分位，保留两位小数
function regMoney(v, p, record) {
	v = (Math.round((v - 0) * 100)) / 100;
	v = (v == Math.floor(v)) ? v + ".00" : ((v * 10 == Math.floor(v * 10)) ? v
			+ "0" : v);
	v = String(v);
	var ps = v.split('.');
	var whole = ps[0];
	var sub = ps[1] ? '.' + ps[1] : '.00';
	var r = /(\d+)(\d{3})/;
	while (r.test(whole)) {
		whole = whole.replace(r, '$1' + ',' + '$2');
	}
	v = whole + sub;
	//p.attr = 'title=' + v;// 增加属性
	if (v.charAt(0) == '-') {
		return '-' + v.substr(1);
	}
	return v;
}
//缩小1万倍（万元），保留2位小数,千分位
function regWanMoney(v, p, record) {
	v = v/10000;
	v = (Math.round((v - 0) * 100)) / 100;
	v = (v == Math.floor(v)) ? v + ".00" : ((v * 10 == Math.floor(v * 10)) ? v
			+ "0" : v);
	v = String(v);
	var ps = v.split('.');
	var whole = ps[0];
	var sub = ps[1] ? '.' + ps[1] : '.00';
	var r = /(\d+)(\d{3})/;
	while (r.test(whole)) {
		whole = whole.replace(r, '$1' + ',' + '$2');
	}
	v = whole + sub;
	//p.attr = 'title=' + v;// 增加属性
	if (v.charAt(0) == '-') {
		return '-' + v.substr(1);
	}
	return v;
}
//缩小1亿倍（亿元），保留2位小数
function regYi2Decimals(v, p, record) {
	v = v/100000000;
	v = (Math.round((v - 0) * 100)) / 100;
	v = (v == Math.floor(v)) ? v + ".00" : ((v * 10 == Math.floor(v * 10)) ? v
			+ "0" : v);
	return v;
}

//最多保留6位小数
function regMoney6(v,p,r){
	v = (Math.round((v - 0) * 1000000)) / 1000000;
	v = String(v);
	var ps = v.split('.');
	var whole = ps[0];
	var sub = ps[1] ? '.' + ps[1] : '';
	var r = /(\d+)(\d{3})/;
	while (r.test(whole)) {
		whole = whole.replace(r, '$1' + ',' + '$2');
	}
	v = whole + sub;
	if (v.charAt(0) == '-') {
		return '-' + v.substr(1);
	}
	return v;
}
function regDate(value, p, record) {
	if(value==""){
		return "";
	}
	var dt = new Date(value);
	return dt.format('Y-m-d');                   
}
function reg2Decimal(value, p, record) {
	//p.attr = 'title=' + value;
	if (parseFloat(value) == value)
		return Math.round(value * 100) / 100;
	else
		return 0;
}
function renderFoo(value, p, record) {
	p.attr = 'title=' + (value?value:"&nbsp;");
	p.attr = ' ext:qtip="' + value + '"';  
	return value;
}
function renderInt(value, p, record, fld) {
	var v = String(value);
	var ps = v.split('.');
	var whole = ps[0];
	//p.attr = 'title=' + whole;
	return whole;
}

function regInt(value, p, record, fld) {
	var v = String(value);
	var ps = v.split('.');
	var whole = ps[0];
	//p.attr = 'title=' + whole;
	return whole;
}

function renderDownload(value, p, record) { 
	if(typeof value == 'undefined' || value == ''){
		return "";
	}else{
		value=encodeURI(value);
		//return '<a href=downfile.policy?doType=downFile&path='+value+' style=text-decoration:underline;color:red;>下载</a>';
		return '<a onclick=download("'+value+'") style=text-decoration:underline;color:red;>下载</a>';
	}    
}  
function renderIndent(v,p,r){
	var l = r.get("codelevel");
	var sp = "";
	for(var i=1;i<l;i++){
		sp += "&nbsp;&nbsp;&nbsp;"
	}
	if(r.get("isleaf")==0){
		return "<b>"+sp+v+"</b>";
	}else{
		return sp+v;
	}
}
function regStatus(v, p, r){
	var str = "";
	if(v=="1"){
		str = "<font color=green>完成</font>";
	}else if(v=="9"){
		str = "<font color=red>作废</font>";
	}else{
		str = "未完成";
	}
	return str;
}
function addTooltip(v,p,r){
	p.attr = ' ext:qtip="' + v + '"';    
	return v;
}

function renderAutoWrap(v,p,r) {  
	//p.attr ='style="white-space:normal;"'; 
	p.attr = 'title=' + (v?v:"&nbsp;");
	p.style = 'overflow:auto;padding: 3px 6px;text-overflow: ellipsis;white-space: nowrap;white-space:normal;line-height:20px;';   
	return v;
	//return '<div style="word-wrap:break-word;word-break: break-all;" mce_style="word-wrap:break-word;word-break: break-all;">' + v + '</div>';  
}  

String.prototype.endWith=function(str){
 if(str==null||str==""||this.length==0||str.length>this.length)
  return false;
 if(this.substring(this.length-str.length)==str)
  return true;
 else
  return false;
 return true;
}
String.prototype.startWith = function(str) {
	if (str == null || str == "" || this.length == 0
			|| str.length > this.length)
		return false;
	if (this.substr(0, str.length) == str)
		return true;
	else
		return false;
	return true;
}
String.prototype.trim= function(){  
    // 用正则表达式将前后空格  
    // 用空字符串替代。  
    return this.replace(/(^\s*)|(\s*$)/g, "");  
}
function required(para){
	var obj=document.getElementById(para);
	if(obj.getAttribute("value")&&obj.getAttribute("value")!=""){
		return "success";
	}else{
		return "不能为空！";
	}
}
function v_notNull(para){
	var p = cForm.getForm().findField(para);
	var result = {
		success: true,
		remark:""
	}
	if(!p||!p.getValue()){
		result.success=false;
		result.remark="不能为空";
	}
	return result;
}
function renderAttach(v,p,r){
	var o = "<a href='javascript:void(0);' onclick='downloadAttach(1,"+ r.get("fid")+")' >打开</a>";
	var d = "<a href='javascript:void(0);' onclick='downloadAttach(0,"+ r.get("fid")+")' >下载</a>";
	return o+"&nbsp;&nbsp;&nbsp;&nbsp;"+d;
}
function renderStatus(v,p,r){
	if(v==5){
		return "退回";
	}else if(v==1){
		return "完成";
	}else if(v==0){
		return "审批中";
	}
}
String.prototype.replaceAll = function(regexp, replacement) {
	var str = this;
	if (typeof regexp == 'string') {
		regexp = new RegExp(regexp, 'gi');
	}
	var result = str.replace(regexp, replacement);
	return result;
};
function getIlleagalInfo(rowEl,iid,swdjzh,isdup,isexc){
	
	rowEl.set({
		'ext:qtip':str
	},false);
}

