package com.fwiz.zftz.service;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.CallableStatementCallback;

import com.alibaba.fastjson.JSONObject;
import com.fwiz.utils.Configuration;
import com.fwiz.utils.ContextUtil;

public class ExecuteCheckRunnable {
	private String batchid;
	private String userid;
	private String eventBm;
	private JSONObject params;
	private Configuration cg ;
	private CommonDataService dataService;
	public ExecuteCheckRunnable(String userid,String eventBm,String batchid,JSONObject params){
		this.batchid=batchid;
		this.userid=userid;
		this.eventBm=eventBm;
		this.params=params;
		cg = (Configuration)ContextUtil.getBean("config");
		dataService = (CommonDataService)ContextUtil.getBean("dataService");
	}
	public synchronized void run() {
		//查询事件触发的检查任务
		List tasks = dataService.getCheckTasks(this.eventBm);
		if (tasks==null||tasks.size()==0){
			return;
		}
		String sps = this.params.toJSONString();
		String tparams = StringUtils.substringBetween(sps, "{", "}");
		tparams = StringUtils.replace(tparams, "\"", "");
		for(int i=0;i<tasks.size();i++){
			Map task = (Map)tasks.get(i);
			String proName =(String)task.get("rprocedure");
			final JSONObject infos = new JSONObject();
			if(proName==null||"".equals(proName)){
				continue;
			}
			long rid = ((BigDecimal)task.get("rid")).longValue();
			dataService.executeCheckRule(proName,this.userid,this.eventBm,this.batchid,String.valueOf(rid),tparams);
		}
		//完成后设置标记
		cg.setTaskStatus(this.batchid, 1);
	}
}
