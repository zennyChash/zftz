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
<title>政府投资项目管理</title>
<link rel="stylesheet" type="text/css" href="<%=request.getContextPath()%>/libs/ext-3.4.0/resources/css/ext-all.css" />
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/adapter/ext/ext-base.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/ext-all.js"></script>
<script type="text/javascript" src="<%=request.getContextPath()%>/libs/ext-3.4.0/src/locale/ext-lang-zh_CN.js"></script>
</head>  
<style type="text/css">
.login_bg{
	background-image: url(images/login_bg.jpg);
	background-repeat: no-repeat;
	background-position: center center;
	height: 570px;
}
.STYLE1 {font-size: 12px}
</style>
<script language="JavaScript" >
if (top != window)   
      top.location.href = window.location.href;  
      
function gotoNext()
{
  if(event.keyCode==13 && event.srcElement.type!='button' && event.srcElement.type!='submit' && event.srcElement.type!='reset' && event.srcElement.type!='textarea' && event.srcElement.type!='')
     event.keyCode=9;
}
function gotoSub(){
	if(event.keyCode==13){
		doSubmit();
	}
}
function doSubmit(){
	var logname = document.getElementById("logname").value;
	var pswd = document.getElementById("pswd").value;
	Ext.Ajax.request({
		url: 'xmgl/validateLogin',
		method : 'post',
		params :{
			username: logname,
			pswd: pswd
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
}
function doReset(){
	loginForm.reset();
}
Ext.onReady(function(){
    Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
    var cookies = Ext.state.Manager.getProvider();
    document.getElementById("logname").value=cookies.get('ifugle_zftz_user'); 
});
</script>
<body scroll="no" >
<form id="loginForm" name="loginForm">
	<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0"> 
	<tr> 
	<td align="center"><table width="798" height="300" border="0" cellpadding="0" cellspacing="0" > 
	<tr> 
	<td align="center" class="login_bg">
	<div class="login_bg">
	  <table width="86%" height="300" border="0" cellpadding="0" cellspacing="0">
	    <tr>
	      <td width="51%" height="200">&nbsp;</td>
	      <td width="49%">&nbsp;</td>
	    </tr>
	    <tr>
	      <td height="200">&nbsp;</td>
	      <td ><table width="96%" height="100" border="0" cellpadding="0" cellspacing="0">
	        <tr>
	          <td width="18%" height="37" align="right"><span class="STYLE1">用户名：</span></td>
	          <td width="82%"><input tabindex="1" type="text" id="logname" name="logname" style="width:150px" maxlength="30" value="" class="login_input" />
	          </td>
	        </tr>
	        <tr>
	          <td align="right"><span class="STYLE1">密　码：</span></td>
	          <td><input tabindex="2" type="password" id="pswd" name="pswd" style="width:150px" onkeydown="gotoSub();" class="login_input" maxlength="30"/></td>
	        </tr>
	        <tr>
	          <td height="50" colspan="2" align="center" valign="middle"><table width="100%" height="39" border="0" cellpadding="0" cellspacing="0">
	            <tr>
	              <td width="45%" align="right"><input name="bt_submit" type="button" class="login_submit" value="登录" onclick="javascript:doSubmit();"/></td>
	              <td width="5%">&nbsp;</td>
	              <td width="50%"><input name="bt_reset" type="reset" class="login_submit" value="重置"/></td>
	            </tr>
	          </table></td>
	          </tr>
	      </table></td>
	    </tr>
	  </table>
	</div>
	
	</td> 
	</tr> 
	</table></td> 
	</tr> 
	</table> 
</form>
</body>
</html>

