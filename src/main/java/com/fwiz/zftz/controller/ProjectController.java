package com.fwiz.zftz.controller;

import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.mindrot.jbcrypt.BCrypt;
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

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.fwiz.utils.Configuration;
import com.fwiz.zftz.service.CommonDataService;
import com.fwiz.zftz.service.PorjectDataService;
import com.fwiz.zftz.utils.JResponse;
import com.fwiz.zftz.utils.bean.*;
@Controller
public class ProjectController {
	private static Logger log = Logger.getLogger(CommonController.class);
	@Autowired
	private Configuration cg ;
	@Autowired
	private PorjectDataService proService;
	
	@RequestMapping(value="/saveRltEns",method = RequestMethod.POST)
	@ResponseBody
	public JResponse saveRltEns(@RequestBody UpdateRows ur){
		JResponse jr = new JResponse();
		String userid="",strEns="",proid = "";
		if(ur!=null){
			strEns = ur.getRowsInfo();
			proid = ur.getProid();
		}
		if(StringUtils.isEmpty(strEns)){
			jr.setRetCode("0");
			jr.setRetMsg("没有修改内容要保存。");
			jr.setRetData(null);
			return jr;
		}
		JSONObject params = ur.parseJRowsInfo();
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = (String)params.get("operator");
				}catch(Exception e){
				}
			}
		}
		Map result = proService.saveRltEns(userid,proid,strEns);
		String flag = (String)result.get("flag");
		if("1".equals(flag)){
			jr.setRetCode("0");
			jr.setRetMsg("");
			JSONObject oj = new JSONObject();
			oj.put("info", (String)result.get("info"));
			jr.setRetData(oj);
		}else{
			jr.setRetCode("9");
			jr.setRetMsg((String)result.get("info"));
			jr.setRetData(null);
		}
		return jr;
	}
	@RequestMapping(value="/saveBankInfo",method = RequestMethod.POST)
	@ResponseBody
	public JResponse saveBankInfo(@RequestBody UpdateRows ur){
		JResponse jr = new JResponse();
		String userid="",strEns="",cid = "",proid="";
		if(ur!=null){
			strEns = ur.getRowsInfo();
			cid = ur.getCid();
			proid=ur.getProid();
		}
		if(StringUtils.isEmpty(strEns)){
			jr.setRetCode("0");
			jr.setRetMsg("没有修改内容要保存。");
			jr.setRetData(null);
			return jr;
		}
		JSONObject params = ur.parseJRowsInfo();
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = (String)params.get("operator");
				}catch(Exception e){
				}
			}
		}
		Map result = proService.saveBankInfo(userid,proid,cid,strEns);
		String flag = (String)result.get("flag");
		if("1".equals(flag)){
			jr.setRetCode("0");
			jr.setRetMsg("");
			JSONObject oj = new JSONObject();
			oj.put("info", (String)result.get("info"));
			jr.setRetData(oj);
		}else{
			jr.setRetCode("9");
			jr.setRetMsg((String)result.get("info"));
			jr.setRetData(null);
		}
		return jr;
	}
	@RequestMapping(value="/saveGaisuan",method = RequestMethod.POST)
	@ResponseBody
	public JResponse saveGaisuan(@RequestBody UpdateRows ur){
		JResponse jr = new JResponse();
		String userid="",strRows="",proid = "";
		if(ur!=null){
			strRows = ur.getRowsInfo();
			proid = ur.getProid();
		}
		if(StringUtils.isEmpty(strRows)){
			jr.setRetCode("0");
			jr.setRetMsg("没有修改内容要保存。");
			jr.setRetData(null);
			return jr;
		}
		JSONObject params = ur.parseJRowsInfo();
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = (String)params.get("operator");
				}catch(Exception e){
				}
			}
		}
		Map result = proService.saveGaisuan(userid,proid,strRows);
		String flag = (String)result.get("flag");
		if("1".equals(flag)){
			jr.setRetCode("0");
			jr.setRetMsg("");
			JSONObject oj = new JSONObject();
			oj.put("info", (String)result.get("info"));
			jr.setRetData(oj);
		}else{
			jr.setRetCode("9");
			jr.setRetMsg((String)result.get("info"));
			jr.setRetData(null);
		}
		return jr;
	}
	
	@RequestMapping(value="/getContractPayments",method = RequestMethod.POST)
	@ResponseBody
	public JResponse getContractPayments(@RequestBody GetDataJson gd){
		JResponse jr = new JResponse();
		String dtID=gd.getDataID();
		JSONObject jparams = gd.parseJQueryParams();
		String sort="",dir="",qparams = "",userid="";
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = jparams.getString("operator");
				}catch(Exception e){
				}
			}
		}
		sort = jparams.containsKey("sort")?jparams.getString("sort"):"";
		dir =  jparams.containsKey("dir")?jparams.getString("dir"):"";
		String qps = jparams.containsKey("qParams")? jparams.getString("qParams"):"";
		String tparams = StringUtils.substringBetween(qps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		JSONObject jucfg = proService.getContractPayments(userid,sort,dir,dtID,qps);
		if(jucfg!=null&&jucfg.containsKey("error")){
			jr.setRetCode("9");
			jr.setRetMsg(jucfg.getString("error"));
			jr.setRetData(null);
		}else{
			jr.setRetCode("0");
			jr.setRetMsg("");
			jr.setRetData(jucfg);
		}
		return jr;
	}
}
