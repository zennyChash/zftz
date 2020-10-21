<%@ page contentType="text/html; charset=UTF-8" %>
<%
    //设置页面不缓存	
	response.setHeader("Pragma","No-cache");
	response.setHeader("Cache-Control","no-cache");
    response.setDateHeader("Expires", 0);
	response.addHeader("Cache-Control", "no-cache");
	response.addHeader("Expires", "Thu, 01 Jan 1970 00:00:01 GMT");
%>
<html>  
<head>  
<title></title>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/ext-all.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/src/locale/ext-lang-zh_CN.js"></script>
</head> 
<script language="JavaScript">
Ext.onReady(function(){
    Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    function getQueryString(name) {
   	  var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)", "i");
   	  var r = window.location.search.substr(1).match(reg);
   	  if (r != null) return unescape(r[2]); return null;
   	}
    var passport = getQueryString("passport");
    Ext.Ajax.request({
		url: 'xmgl/encryptLogin',
		method : 'post',
		params :{
			encryptUserid: passport
		},
		success : function(response, options) {
		   	var o = Ext.util.JSON.decode(response.responseText);
		   	if(o&&o.retCode=="0"){
		   		var userinfo = o.retData;
		   		var cookies = Ext.state.Manager.getProvider();
		   		cookies.set('ifugle_zftz_user',userinfo.USER_NAME); 
		   		location.href = "main.jsp";
		   	}else{
		   		Ext.Msg.alert("失败",o.retMsg);
		   	}
		}
	});
});
</script>
<body>
</body>
</html>