package com.fwiz.zftz.utils.bean;

import com.alibaba.fastjson.JSONObject;

public class CheckRuleJson {
	private String event;
	private String checkParams ;
	public String getEvent() {
		return event;
	}
	public void setEvent(String event) {
		this.event = event;
	}
	public String getCheckParams() {
		return checkParams;
	}
	public void setCheckParams(String checkParams) {
		this.checkParams = checkParams;
	}
	public JSONObject parseJCheckRuleParams(){
		return JSONObject.parseObject(this.checkParams);
	}
}
