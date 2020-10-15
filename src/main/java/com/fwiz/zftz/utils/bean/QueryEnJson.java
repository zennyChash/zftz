package com.fwiz.zftz.utils.bean;

import com.alibaba.fastjson.JSONObject;

public class QueryEnJson {
	private int enType;
	private int opType;
	private String queryParams;
	
	public JSONObject parseJQueryParams(){
		return JSONObject.parseObject(this.queryParams);
	}
	
	public int getEnType() {
		return enType;
	}

	public void setEnType(int enType) {
		this.enType = enType;
	}

	public int getOpType() {
		return opType;
	}

	public void setOpType(int opType) {
		this.opType = opType;
	}

	public String getQueryParams() {
		return queryParams;
	}
	public void setQueryParams(String queryParams) {
		this.queryParams = queryParams;
	} 
}
