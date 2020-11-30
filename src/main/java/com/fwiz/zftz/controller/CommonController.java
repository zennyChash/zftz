package com.fwiz.zftz.controller;

import java.io.*;
import java.net.URL;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import org.springframework.web.multipart.MultipartFile;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.fwiz.zftz.service.CommonDataService;
import com.fwiz.zftz.service.ExecuteCheckRunnable;
import com.fwiz.zftz.utils.JResponse;
import com.fwiz.zftz.utils.bean.CheckRuleJson;
import com.fwiz.zftz.utils.bean.DeleteDataJson;
import com.fwiz.zftz.utils.bean.GetDataJson;
import com.fwiz.zftz.utils.bean.KeyValuePair;
import com.fwiz.zftz.utils.bean.QuerySingleRdJson;
import com.fwiz.zftz.utils.bean.UpdateDataJson;
import com.fwiz.utils.Configuration;

@Controller
public class CommonController {
	private static Logger log = Logger.getLogger(CommonController.class);
	@Autowired
	private Configuration cg ;
	@Autowired
	private CommonDataService dataService;

	/**
	 * 获取分页列表
	 * @param gd
	 * @return
	 */
	@RequestMapping(value="/queryListPaging",method = RequestMethod.POST)
	@ResponseBody
	public JResponse queryListPaging(@RequestBody GetDataJson gd){
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
		int start=jparams.containsKey("start")?jparams.getIntValue("start"):0;
		int limit=jparams.containsKey("limit")?jparams.getIntValue("limit"):30;
		sort = jparams.containsKey("sort")?jparams.getString("sort"):"";
		dir =  jparams.containsKey("dir")?jparams.getString("dir"):"";
		String qps = jparams.containsKey("qParams")? jparams.getString("qParams"):"";
		//2020-11-06对E平台的请求进行处理，统一后缀_ept去掉，再根据流水号（lsh）转换业务id，重置请求参数
		if(!StringUtils.isEmpty(dtID)&&"_ept".equalsIgnoreCase(dtID.substring(dtID.length()-4))){
			dtID=dtID.substring(0,dtID.length()-4);
			JSONObject jqps = JSON.parseObject(qps);
			qps = dataService.processParamsForEpt("queryListPaging",jqps);
		}
		String tparams = StringUtils.substringBetween(qps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		JSONObject jucfg = dataService.getListPaging(userid,start,limit,sort,dir,dtID,tparams);
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
	
	/**
	 * 获取不分页列表
	 * @param gd
	 * @return
	 */
	@RequestMapping(value="/queryList",method = RequestMethod.POST)
	@ResponseBody
	public JResponse queryList(@RequestBody GetDataJson gd){
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
		//2020-11-06对E平台的请求进行处理，统一后缀_ept去掉，再根据流水号（lsh）转换业务id，重置请求参数
		if(!StringUtils.isEmpty(dtID)&&"_ept".equalsIgnoreCase(dtID.substring(dtID.length()-4))){
			dtID=dtID.substring(0,dtID.length()-4);
			JSONObject jqps = JSON.parseObject(qps);
			qps = dataService.processParamsForEpt("queryList",jqps);
		}
		String tparams = StringUtils.substringBetween(qps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		JSONObject jucfg = dataService.getList(userid,sort,dir,dtID,tparams);
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
	@RequestMapping(value="/getTreeBms",method = RequestMethod.POST)
	@ResponseBody
	public JResponse getTreeBms(@RequestBody GetDataJson gd){
		JResponse jr = new JResponse();
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
		String sLoadAll = jparams.containsKey("loadAll")?jparams.getString("loadAll"):"0";
		boolean loadAll = "1".equals(sLoadAll)||"true".equals(sLoadAll);
		jparams.put("loadAll", sLoadAll);
		String tparams = StringUtils.substringBetween(jparams.toJSONString(), "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		String proName = "treeBms";
		JSONObject jucfg = dataService.getList(userid,"","",proName,tparams);
		if(jucfg!=null&&jucfg.containsKey("error")){
			jr.setRetCode("9");
			jr.setRetMsg(jucfg.getString("error"));
			jr.setRetData(null);
		}else{
			if(loadAll){//非懒加载时，构造children结构
				List allRows = jucfg.getJSONArray("rows");
				if(allRows!=null&&allRows.size()>0){
					List sortedRows = new ArrayList();
					for(int i=0;i<allRows.size();i++){
						Map rRow = (Map)allRows.get(i);
						String rootPid = (String)rRow.get("pid");
						//取出第一层（pid为空的）的节点，进行子节点构造
						if(StringUtils.isEmpty(rootPid)){
							String rootId = (String)rRow.get("id");
							List children = new ArrayList();
							buildChildren(allRows,rRow,i+1,children);
							rRow.put("children", children);
							sortedRows.add(rRow);
						}
					}
					jucfg.put("rows", sortedRows);
				}
			}
			jr.setRetCode("0");
			jr.setRetMsg("");
			jr.setRetData(jucfg);
		}
		return jr;
	}
	private void buildChildren(List allRows,Map preRow,int idx,List children){
		while(idx<allRows.size()){
			Map jrow = (Map)allRows.get(idx);
			String cPid = (String)jrow.get("pid");
			String cLeaf = (String)jrow.get("leaf");
			String pNode = (String)preRow.get("id");
			if(pNode.equals(cPid)){
				if(!"1".equals(cLeaf)){
					List newChildren = new ArrayList();
					buildChildren(allRows,jrow,idx+1,newChildren);
					jrow.put("children", newChildren);
					children.add(jrow);
				}else{
					children.add(jrow);
				}
			}else{
				preRow.put("children", children);
			}
			idx++;
		}
	}
	/**
	 * 保存信息
	 * @param ud
	 * @return
	 */
	@RequestMapping(value="/save",method = RequestMethod.POST)
	@ResponseBody
	public JResponse saveData(@RequestBody UpdateDataJson ud){
		JResponse jr = new JResponse();
		String dtId = ud.getDataID();
		JSONObject params = ud.parseJUpdateParams();
		String userid="";
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = params.getString("operator");
				}catch(Exception e){
				}
			}
		}
		//对于密码，在调用存储过程（传递到数据库）之前就加密
		if(params!=null&&params.containsKey("pswd")&&!StringUtils.isEmpty(params.getString("pswd"))){
			String pswd = params.getString("pswd");
			String hashed = BCrypt.hashpw(pswd, BCrypt.gensalt());
			params.put("pswd", hashed);
		}
		String sps = params.toJSONString();
		String tparams = StringUtils.substringBetween(sps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		
		Map result = dataService.saveData(userid,dtId,tparams);
		
		//记录日志
		String opType = "";
		try{
			opType = params.getString("opType");
		}catch(Exception e){
			log.info(e.toString());
		}
		//如果参数中没有指明opType，使用save+数据Id，首字母大写
		if(StringUtils.isEmpty(opType)){
			opType = "save" + dtId.substring(0, 1).toUpperCase()+ dtId.substring(1, dtId.length());
		}
		
		String flag = (String)result.get("flag");
		if("1".equals(flag)){
			//记录日志
			dataService.addLog(opType,params.toJSONString(),userid);
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
	
	/**
	 * 删除信息
	 * @param ud
	 * @return
	 */
	@RequestMapping(value="/delete",method = RequestMethod.POST)
	@ResponseBody
	public JResponse deleteData(@RequestBody DeleteDataJson dd){
		JResponse jr = new JResponse();
		String dtId = dd.getDataID();
		JSONObject params = dd.parseJDelParams();
		String userid="";
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = params.getString("operator");
				}catch(Exception e){
				}
			}
		}
		String sps = params.toJSONString();
		String tparams = StringUtils.substringBetween(sps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		Map result = dataService.deleteData(userid,dtId,tparams);
		
		//记录日志
		String opType = "";
		try{
			opType = params.getString("opType");
		}catch(Exception e){
			log.info(e.toString());
		}
		//如果参数中没有指明opType，使用save+数据Id，首字母大写
		if(StringUtils.isEmpty(opType)){
			opType = "delete" + dtId.substring(0, 1).toUpperCase()+ dtId.substring(1, dtId.length());
		}
		
		String flag = (String)result.get("flag");
		if("1".equals(flag)){
			//记录日志
			dataService.addLog(opType,params.toJSONString(),userid);
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
	
	/**
	 * 获取单条记录
	 * @param ud
	 * @return
	 */
	@RequestMapping(value="/getSingleRecord",method = RequestMethod.POST)
	@ResponseBody
	public JResponse getSingleRecord(@RequestBody QuerySingleRdJson qb){
		JResponse jr = new JResponse();
		String dtID = qb.getDataID();
		JSONObject params = qb.parseJKeyParams();
		String userid="";
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = params.getString("operator");
				}catch(Exception e){
				}
			}
		}
		String sps = params.toJSONString();
		//2020-11-06对E平台的请求进行处理，统一后缀_ept去掉，再根据流水号（lsh）转换业务id，重置请求参数
		if(!StringUtils.isEmpty(dtID)&&"_ept".equalsIgnoreCase(dtID.substring(dtID.length()-4))){
			dtID=dtID.substring(0,dtID.length()-4);
			JSONObject jsps = JSON.parseObject(sps);
			sps = dataService.processParamsForEpt("getSingleRecord",jsps);
		}
		String tparams = StringUtils.substringBetween(sps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		Map result = dataService.getSingleRecord(userid,dtID,tparams);
		if(result!=null&&result.containsKey("error")){
			jr.setRetCode("9");
			jr.setRetMsg((String)result.get("error"));
			jr.setRetData(null);
		}else{
			jr.setRetCode("0");
			jr.setRetMsg("");
			jr.setRetData(result);
		}
		return jr;
	}
	/**
	 * 查重
	 * @param ud
	 * @return
	 */
	@RequestMapping(value="/checkDuplicate",method = RequestMethod.POST)
	@ResponseBody
	public JResponse checkDuplicate(@RequestBody QuerySingleRdJson qb){
		JResponse jr = new JResponse();
		String dtId = qb.getDataID();
		JSONObject params = qb.parseJKeyParams();
		String userid="";
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = params.getString("operator");
				}catch(Exception e){
				}
			}
		}
		String sps = params.toJSONString();
		String tparams = StringUtils.substringBetween(sps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		Map infos = dataService.checkDuplicate(userid,dtId,tparams);
		String flag = (String)infos.get("flag");
		if("1".equals(flag)){
			jr.setRetCode("0");
			jr.setRetMsg("");
			JSONObject dup = new JSONObject();
			dup.put("isDup", (String)infos.get("isDup"));
			dup.put("info", (String)infos.get("info"));
			jr.setRetData(dup);
		}else{
			jr.setRetCode("9");
			jr.setRetMsg((String)infos.get("info"));
			jr.setRetData(null);
		}
		return jr;
	}
	
	@RequestMapping("/getFormInfo")
	@ResponseBody
	public JResponse getFormInfo(@RequestParam("fid") String fid){
		JResponse jr = new JResponse();
		String infos = cg.getExtFormFields(fid);
		JSONObject jf = JSONObject.parseObject(infos);
		jr.setRetCode("0");
		jr.setRetMsg("");
		jr.setRetData(jf);
		return jr;
	}
	@RequestMapping("/getGridInfo")
	@ResponseBody
	public JResponse getGridInfo(@RequestParam("gid") String gid){
		JResponse jr = new JResponse();
		String infos = cg.getExtGrids(gid);
		JSONObject jg = JSONObject.parseObject(infos);
		jr.setRetCode("0");
		jr.setRetMsg("");
		jr.setRetData(jg);
		return jr;
	}

	@RequestMapping("/uploadAttachment")
	@ResponseBody
	public Map uploadAttachment(@RequestParam("filepath") List<MultipartFile> uploadfile, HttpServletRequest request){
		Map result = new HashMap();
		Map infos = new HashMap();
		int fid = -1;
		String uaParams = request.getParameter("uaParams");
		JSONObject jParams = JSON.parseObject(uaParams);
		String module = jParams.getString("module");
		String mkey = jParams.getString("mkey");
		String fld = jParams.getString("fld");
		String fname = "";
		log.info(module+","+mkey+","+fld);
		if (!uploadfile.isEmpty() && uploadfile.size() > 0) {
			for (MultipartFile file : uploadfile) {
				fname = file.getOriginalFilename();
				String ftype = fname.substring(fname.lastIndexOf(".")+1);
				long byteSize = file.getSize();
				String fsize = dataService.getFileSizeStr(byteSize, "M");
				log.info("文件名："+fname);
				log.info("文件大小："+byteSize+"Bytes，即："+fsize);
				String realPath =dataService.saveAttachmen(file,module, mkey, ftype);
				jParams.put("fname", fname);
				jParams.put("ftype", ftype);
				jParams.put("fsize", fsize);
				jParams.put("ufname", realPath);
				String userid = (String)request.getSession().getAttribute("userid");
				//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
				if("on".equals(cg.getString("testMode"))){
					if(StringUtils.isEmpty(userid)){
						try{
							userid = jParams.getString("operator");
						}catch(Exception e){
						}
					}
				}
				jParams.put("userid", userid);
				fid =dataService.saveAttachInfo(jParams);
			}
			if(fid>-1){
				infos.put("msg", "文件："+fname+"上传成功！");
				infos.put("newFid", fid);
				result.put("success",true);
				result.put("infos",infos);
			}else{
				infos.put("msg", "服务端保存文件失败！");
				result.put("success",false);
				result.put("errors",infos);
			}
		} else {
			infos.put("msg", "未提供上传文件！");
			result.put("success",false);
			result.put("errors",infos);
		}	
		return result;
	}
	@RequestMapping("/downloadAttach")
	public void downloadAttach(HttpServletRequest request, HttpServletResponse response){
        try{
        	String fid = request.getParameter("fid");
        	String isOpen = request.getParameter("isOpen");
    		dataService.downloadAttach(fid, request,response, "1".equals(isOpen));     
        } catch(Exception e){
            e.printStackTrace();
        }
	}
	/**
	 * 获取页面布局
	 * @param
	 * @return
	 */
	@RequestMapping("/getBasePanelByPhase")
	@ResponseBody
	public JResponse getBasePanelByPhase(@RequestParam("module") String module){
		JResponse jr = new JResponse();
		List result = null;
		try{
			result = dataService.getBasePanelByPhase(module);
		}catch(Exception e){
			jr.setRetCode("9");
			jr.setRetMsg(e.toString());
			jr.setRetData(null);
		}
		jr.setRetCode("0");
		jr.setRetMsg("");
		jr.setRetData(result);
		return jr;
	}
	@RequestMapping(value="/rulesCheck",method = RequestMethod.POST)
	@ResponseBody
	public JResponse rulesCheck(@RequestBody CheckRuleJson cr){
		JResponse jr = new JResponse();
		String eventBm = cr.getEvent();
		JSONObject params = cr.parseJCheckRuleParams();
		String userid="";
		RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
		if (requestAttributes != null) {
			HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
			userid = (String)request.getSession().getAttribute("userid");
		}
		//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
		if("on".equals(cg.getString("testMode"))){
			if(StringUtils.isEmpty(userid)){
				try{
					userid = params.getString("operator");
				}catch(Exception e){
				}
			}
		}
		try{
			//按当前毫秒数生成执行批次号
			String batchid = String.valueOf(System.currentTimeMillis());
	    	cg.setTaskStatus(batchid, 0);
			//将任务交给另一个线程去做
			ExecuteCheckRunnable exeCheck = new ExecuteCheckRunnable(userid,eventBm,batchid,params);
			new Thread(exeCheck).start();
			//请求立刻返回
			jr.setRetCode("0");
			jr.setRetMsg("");
			JSONObject jdata = new JSONObject();
			jdata.put("batchid", batchid);
			jr.setRetData(jdata); 
		}catch(Exception e){
			jr.setRetCode("9");
			jr.setRetMsg(e.toString());
			jr.setRetData(null);
		}
		return jr;
	}
	
	@RequestMapping(value="/pollCheckResults")
	@ResponseBody
	public JResponse pollCheckResults(@RequestParam Map<String, String> params){
		JResponse jr = new JResponse();
		if(params!=null){
			String batchid = params.get("batchid");
			String userid ="";
			RequestAttributes requestAttributes = RequestContextHolder.currentRequestAttributes();
			if (requestAttributes != null) {
				HttpServletRequest request = ((ServletRequestAttributes) requestAttributes).getRequest();
				userid = (String)request.getSession().getAttribute("userid");
			}
			//测试模式下，会话中没有，则从请求参数中取，这是为了方便单个请求接口测试。
			if("on".equals(cg.getString("testMode"))){
				if(StringUtils.isEmpty(userid)){
					try{
						userid =  params.get("userid");
					}catch(Exception e){
					}
				}
			}
			if(StringUtils.isEmpty(batchid)){
				jr.setRetCode("9");
				jr.setRetMsg("未指定要查看的执行批次号！");
				jr.setRetData("");
			}else{
				Map crInfos = dataService.pollCheckResults(userid,batchid);
				jr.setRetCode("0");
				jr.setRetMsg("");
				jr.setRetData(crInfos);
			}
		}else{
			jr.setRetCode("9");
			jr.setRetMsg("缺少参数，无法执行！");
			jr.setRetData("");
		}
		return jr;
	}
	
} 
