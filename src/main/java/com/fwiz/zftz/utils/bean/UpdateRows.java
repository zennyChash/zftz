package com.fwiz.zftz.utils.bean;

import com.alibaba.fastjson.JSONObject;

public class UpdateRows {
	private String proid;
	private String cid;
	private String rowsInfo ;
	public String getProid() {
		return proid;
	}
	public void setProid(String proid) {
		this.proid = proid;
	}
	public String getCid() {
		return cid;
	}
	public void setCid(String cid) {
		this.cid = cid;
	}
	public String getRowsInfo() {
		return rowsInfo;
	}
	public void setRowsInfo(String rowsInfo) {
		this.rowsInfo = rowsInfo;
	}
	public JSONObject parseJRowsInfo(){
		return JSONObject.parseObject(this.rowsInfo);
	}
}
