package com.fwiz.zftz.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;







import com.alibaba.fastjson.JSONObject;
import com.fwiz.zftz.service.AuthService;
import com.fwiz.zftz.utils.JResponse;
import com.fwiz.zftz.utils.bean.GetDataJson;
import com.fwiz.zftz.utils.bean.UpdateDataJson;
import com.fwiz.utils.Configuration;

@Controller
public class AuthController {
	private static Logger log = Logger.getLogger(AuthController.class);
	@Autowired
	private Configuration cg ;
	@Autowired
	private AuthService authService;
	
	@RequestMapping(value="/validateLogin",method = RequestMethod.POST)
	@ResponseBody
	public JResponse validateLogin(@RequestParam("username") String username,@RequestParam("pswd") String pswd){
		JResponse jr = new JResponse();
		if(StringUtils.isEmpty(pswd)){
			jr.setRetCode("3");
			jr.setRetMsg("待验证的密码为空 ！");
			jr.setRetData(null);
			return jr;
		}
	    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	    int flag = 0;
		try{
			flag = authService.validateLogin(username,pswd);
		}catch(Exception e){
			jr.setRetCode("9");
			jr.setRetMsg("验证密码过程中发生错误！");
			jr.setRetData(null);
			return jr;
		}
		if(flag==0){
			log.info("用户"+username+"于"+df.format(new Date())+"登录系统！");
			jr.setRetCode("0");
			jr.setRetMsg("");
			Map um = authService.getUserInfo(username);//用户的中文名，类型
			jr.setRetData(um);
			RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			HttpServletResponse response = ((ServletRequestAttributes) requestAttributes).getResponse();
			if (requestAttributes != null) {
				request = ((ServletRequestAttributes) requestAttributes).getRequest();
			}
			if(request!=null){
				request.getSession().setAttribute("user", um);
				String userid=um==null?"":(String)um.get("ID");
		    	request.getSession().setAttribute("userid", userid);
		    }
		}else if(flag==-1){
			jr.setRetCode("-1");
			jr.setRetMsg("用户账户不存在！");
			log.info("用户"+username+"于"+df.format(new Date())+"登录,用户账户不存在！");
		}else if(flag==3){
			jr.setRetCode("3");
			jr.setRetMsg("用户未设置密码！");
			log.info("用户"+username+"于"+df.format(new Date())+"登录,用户未设置密码！");
		}else if(flag==5){
			jr.setRetCode("5");
			jr.setRetMsg("用户"+username+"于"+df.format(new Date())+"登录,用户密码不正确！");
			jr.setRetData(null);
			log.info("用户"+username+"于"+df.format(new Date())+"登录，密码错误！");
		}else{
			jr.setRetCode("9");
			jr.setRetMsg("验证密码过程中发生错误！");
			jr.setRetData(null);
			log.info("用户"+username+"于"+df.format(new Date())+"登录，验证密码过程中发生错误！");
		}
		return jr;
	}
	
	@RequestMapping("/getAuthModules")
	@ResponseBody
	public List getAuthModules(@RequestParam("pid") String pid,@RequestParam(required=false)String userid){
		List modules = null;
		String cuser ="";
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					cuser = userid;
				}catch(Exception e){
				}
			}
		}
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		HttpServletRequest request = null;
		if (requestAttributes != null) {
			request = ((ServletRequestAttributes) requestAttributes).getRequest();
			cuser=(String)request.getSession().getAttribute("userid");
		}
		if("admin".equals(userid)){
			modules = authService.getAllModules(pid);
		}else{
			modules = authService.getAccessableModules(cuser,pid);
		}
		return modules;
	}
	@RequestMapping(value="/changePswd",method = RequestMethod.POST)
	@ResponseBody
	public JResponse changePswd(@RequestBody UpdateDataJson ud){
		JResponse jr = new JResponse();
		JSONObject params = ud.parseJUpdateParams();
		String userid=params.getString("userid");
		String oldPswd=params.getString("oldPswd");
		String pswd=params.getString("pswd");
		Map result = authService.changePswd(userid, oldPswd, pswd);
		if((boolean)result.get("saved")){
			jr = new JResponse("0","",result);
		}else{
			jr = new JResponse("9",(String)result.get("msg"),null);
		}
		return jr;
	}
	
	@RequestMapping("/getSystemBaseInfo")
	@ResponseBody
	public JResponse getSystemBaseInfo(@RequestParam("sysKeys") String sysKeys){
		JResponse jr = new JResponse();
		if(StringUtils.isEmpty(sysKeys)){
			jr.setRetCode("9");
			jr.setRetMsg("sysKeys为空！");
			jr.setRetData(null);
			return jr;
		}
		String[] keys = sysKeys.split(",");
		JSONObject jucfg = authService.getSystemBaseInfo(keys);
		jr.setRetCode("0");
		jr.setRetMsg("");
		jr.setRetData(jucfg);
		return jr;
	}
	
	
	@RequestMapping("/logout")
	@ResponseBody
	public JResponse logout(@RequestParam("userid") String userid){
		JResponse jr = new JResponse();
		if(StringUtils.isEmpty(userid)){
			jr.setRetCode("9");
			jr.setRetMsg("请求中的userid为空！");
			jr.setRetData(null);
			return jr;
		}
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		HttpServletRequest request=null;
		if (requestAttributes != null) {
			request = ((ServletRequestAttributes) requestAttributes).getRequest();
			request.getSession().removeAttribute("userid");
			request.getSession().invalidate();
		}
		jr.setRetCode("0");
		jr.setRetMsg("");
		JSONObject oj = new JSONObject();
		oj.put("info", "用户已注销！");
		jr.setRetData(oj);
		return jr;
	}
	
	@RequestMapping("/encryptStr")
	@ResponseBody
	public JResponse encryptStr(@RequestParam("str") String str){
		JResponse jr = new JResponse();
		if(StringUtils.isEmpty(str)){
			jr.setRetCode("3");
			jr.setRetMsg("待加密的内容为空 ！");
			jr.setRetData(null);
			return jr;
		}
		String enStr= "";
		try{
			enStr = authService.encrypt(str);
		}catch(Exception e){
			jr.setRetCode("9");
			jr.setRetMsg("加密过程中发生错误！"+e.getMessage());
			jr.setRetData(null);
		}
		jr.setRetCode("0");
		JSONObject jo = new JSONObject();
		jo.put("encrypt", enStr);
		jr.setRetData(jo);
		return jr;
	}
	
	@RequestMapping("/decryptStr")
	@ResponseBody
	public JResponse decryptStr(@RequestParam("str") String str){
		JResponse jr = new JResponse();
		if(StringUtils.isEmpty(str)){
			jr.setRetCode("3");
			jr.setRetMsg("待解密的内容为空 ！");
			jr.setRetData(null);
			return jr;
		}
		String deStr= "";
		try{
			deStr = authService.decrypt(str);
		}catch(Exception e){
			jr.setRetCode("9");
			jr.setRetMsg("解密过程中发生错误！"+e.getMessage());
			jr.setRetData(null);
		}
		jr.setRetCode("0");
		JSONObject jo = new JSONObject();
		jo.put("decrypt", deStr);
		jr.setRetData(jo);
		return jr;
	}
	@RequestMapping("/encryptLogin")
	@ResponseBody
	public JResponse encryptLogin(@RequestParam("encryptUserid") String encryptUserid,@RequestParam(required=false) String encryptPswd){
		JResponse jr = new JResponse();
	    SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	    //先用原始的用户ID验证是否存在
	    int flag = -1;
		try{
			flag = authService.validateUser(encryptUserid);
		}catch(Exception e){
			jr.setRetCode("9");
			jr.setRetMsg("验证登录过程中发生错误！");
			jr.setRetData(null);
			return jr;
		}
		//如果不存在，则用解密算法解密之后再测一次
		String decryptedUserid = authService.decrypt(encryptUserid);
		if(flag==-1){
			try{
				flag = authService.validateUser(decryptedUserid);
			}catch(Exception e){
				jr.setRetCode("9");
				jr.setRetMsg("验证登录过程中发生错误！");
				jr.setRetData(null);
				return jr;
			}
		}
		if(flag==0){
			log.info("用户"+decryptedUserid+"于"+df.format(new Date())+"登录系统！");
			jr.setRetCode("0");
			jr.setRetMsg("");
			Map um = authService.getUserInfo(decryptedUserid);//用户的中文名，类型
			jr.setRetData(um);
			RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			HttpServletResponse response = ((ServletRequestAttributes) requestAttributes).getResponse();
			if (requestAttributes != null) {
				request = ((ServletRequestAttributes) requestAttributes).getRequest();
			}
			if(request!=null){
				request.getSession().setAttribute("user", um);
				String userid=um==null?"":(String)um.get("ID");
		    	request.getSession().setAttribute("userid", userid);
		    }
		}else if(flag==-1){
			jr.setRetCode("-1");
			jr.setRetMsg("用户账户不存在！");
			log.info("用户"+decryptedUserid+"于"+df.format(new Date())+"登录,用户账户不存在！");
		}
		return jr;
	}
}
