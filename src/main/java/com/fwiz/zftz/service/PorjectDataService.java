package com.fwiz.zftz.service;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.collections.iterators.EntrySetMapIterator;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.fwiz.utils.Configuration;

@Service
@Transactional
public class PorjectDataService {
	private static Logger log = Logger.getLogger(PorjectDataService.class);
	protected JdbcTemplate jdbcTemplate;
	@Autowired
	public void setJdbcTemplate(JdbcTemplate jdbcTemplate){
		this.jdbcTemplate = jdbcTemplate;
	}
	@Autowired
	private Configuration cg ;
	
	public Map saveRltEns(String userid,String proid,String strEns) {
		Map info = new HashMap();
		try{
			JSONObject jens = JSON.parseObject(strEns);
			JSONArray removedEns=null,modifiedEns=null,addEns= null;
			if(jens!=null){
				try{
					String s = jens.getString("removedEns");
					removedEns = JSONArray.parseArray(s);
				}catch(Exception e){}
				try{
					String s = jens.getString("modifiedEns");
					modifiedEns=JSONArray.parseArray(s);
				}catch(Exception e){}
				try{
					String s = jens.getString("newEns");
					addEns=JSONArray.parseArray(s);
				}catch(Exception e){
					log.error(e.toString());
				}
			}
			//1、处理删除的记录
			StringBuffer sql = new StringBuffer("");
			if(removedEns!=null&&removedEns.size()>0){
				sql = new StringBuffer("delete from zftz_project_gldw where id=?");
				for(int i=0;i<removedEns.size();i++){
					String eid = removedEns.getString(i);
					jdbcTemplate.update(sql.toString(), new Object[]{eid});
				}
			}
			//2、处理修改记录
			if(modifiedEns!=null&&modifiedEns.size()>0){
				for(int i=0;i<modifiedEns.size();i++){
					sql = new StringBuffer("update zftz_project_gldw set ");
					JSONObject en = modifiedEns.getJSONObject(i);
					for(Map.Entry<String, Object> entry : en.entrySet()){
					    String k = entry.getKey();
					    if("id".equals(k)){
					    	continue;
					    }
					    String v = (String)entry.getValue();
					    sql.append(k).append("='").append(v).append("',");
					}
					String msql = sql.substring(0,sql.length()-1);
					msql=msql+" where id = ?";
					jdbcTemplate.update(msql, new Object[]{en.getIntValue("id")});
				}
			}
			//3、处理增加记录
			if(addEns!=null&&addEns.size()>0){
				sql = new StringBuffer("insert into zftz_project_gldw(id,proid,entype,ename,remark)");
				sql.append("select sq_zftz_project_sub.nextval,?,?,?,? from dual");
				for(int i=0;i<addEns.size();i++){
					JSONObject en = addEns.getJSONObject(i);
					String entype = en.getString("entype");
					String ename = en.getString("ename");
					String remark = en.getString("remark");
					jdbcTemplate.update(sql.toString(), new Object[]{proid,entype,ename,remark});
				}
			}
			if(jens!=null){
				//记录日志，每保存一次只记录一次日志，粗粒度。具体删除、添加、修改内容，可从参数中解析
				StringBuffer lsql = new StringBuffer("insert into zftz_logs");
				lsql.append("(id,proid,optype,params,userid,ctime)");
				lsql.append("select sq_zftz_log.nextval,?,'saveProRltEns',?,?,sysdate from dual");
				jdbcTemplate.update(lsql.toString(), new Object[]{proid,strEns,userid});
			}
		}catch(Exception e){
			info.put("flag", "9");
			info.put("info", e.toString());
			return info;
		}
		info.put("flag", "1");
		info.put("info", "项目相关单位保存成功！");
		return info;
	}

	public Map saveGaisuan(String userid,String proid, String strRows) {
		Map info = new HashMap();
		try{
			JSONObject jinfo = null;
			JSONArray jitems = null;
			try{
				jinfo = JSON.parseObject(strRows);
			}catch(Exception e){}
			try{
				String s = jinfo.getString("rows");
				jitems = JSONArray.parseArray(s);
			}catch(Exception e){}
			//先删
			StringBuffer sql = new StringBuffer("delete from zftz_project_gs where proid=?");
			jdbcTemplate.update(sql.toString(), new Object[]{proid});
			//再增
			if(jitems!=null&&jitems.size()>0){
				sql = new StringBuffer("insert into zftz_project_gs(id,proid,iid,iname,je,remark)");
				sql.append("select sq_zftz_project_sub.nextval,?,?,?,?,? from dual");
				for(int i=0;i<jitems.size();i++){
					JSONObject item = jitems.getJSONObject(i);
					String iid = item.getString("iid");
					String iname = item.getString("iname");
					double je = item.getDoubleValue("je");
					String remark = item.getString("remark");
					jdbcTemplate.update(sql.toString(), new Object[]{proid,iid,iname,je,remark});
				}
				
				//记录日志，每保存一次只记录一次日志，粗粒度。具体删除、添加、修改内容，可从参数中解析
				StringBuffer lsql = new StringBuffer("insert into zftz_logs");
				lsql.append("(id,proid,optype,params,userid,ctime)");
				lsql.append("select sq_zftz_log.nextval,?,'saveProGaisuan',?,?,sysdate from dual");
				jdbcTemplate.update(lsql.toString(), new Object[]{proid,strRows,userid});
			}
		}catch(Exception e){
			info.put("flag", "9");
			info.put("info", e.toString());
			return info;
		}
		info.put("flag", "1");
		info.put("info", "项目的概算信息保存成功！");
		return info;
	}

	public JSONObject getContractPayments(String userid, String sort,String dir, String dtID, String qps) {
		// TODO Auto-generated method stub
		return null;
	}

	public Map saveBankInfo(String userid, String proid,String cid, String strAccs) {
		Map info = new HashMap();
		try{
			JSONObject jAccs = JSON.parseObject(strAccs);
			JSONArray removedAccs=null,modifiedAccs=null,addAccs= null;
			if(jAccs!=null){
				try{
					String s = jAccs.getString("removedAccs");
					removedAccs = JSONArray.parseArray(s);
				}catch(Exception e){}
				try{
					String s = jAccs.getString("modifiedAccs");
					modifiedAccs=JSONArray.parseArray(s);
				}catch(Exception e){}
				try{
					String s = jAccs.getString("newAccs");
					addAccs=JSONArray.parseArray(s);
				}catch(Exception e){
					log.error(e.toString());
				}
			}
			//1、处理删除的记录
			StringBuffer sql = new StringBuffer("");
			if(removedAccs!=null&&removedAccs.size()>0){
				sql = new StringBuffer("delete from zftz_contract_bank where id=?");
				for(int i=0;i<removedAccs.size();i++){
					String aid = removedAccs.getString(i);
					jdbcTemplate.update(sql.toString(), new Object[]{aid});
				}
			}
			//2、处理修改记录
			if(modifiedAccs!=null&&modifiedAccs.size()>0){
				for(int i=0;i<modifiedAccs.size();i++){
					sql = new StringBuffer("update zftz_contract_bank set ");
					JSONObject account = modifiedAccs.getJSONObject(i);
					for(Map.Entry<String, Object> entry : account.entrySet()){
					    String k = entry.getKey();
					    if("id".equals(k)){
					    	continue;
					    }
					    String v = (String)entry.getValue();
					    sql.append(k).append("='").append(v).append("',");
					}
					String msql = sql.substring(0,sql.length()-1);
					msql=msql+" where id = ?";
					jdbcTemplate.update(msql, new Object[]{account.getIntValue("id")});
				}
			}
			//3、处理增加记录
			if(addAccs!=null&&addAccs.size()>0){
				sql = new StringBuffer("insert into zftz_contract_bank(id,cid,skdw,khbank,account)");
				sql.append("select sq_zftz_contract_sub.nextval,?,?,?,? from dual");
				for(int i=0;i<addAccs.size();i++){
					JSONObject acc = addAccs.getJSONObject(i);
					String skdw = acc.getString("skdw");
					String khbank = acc.getString("khbank");
					String account = acc.getString("account");
					jdbcTemplate.update(sql.toString(), new Object[]{cid,skdw,khbank,account});
				}
			}
			if(jAccs!=null){
				//记录日志，每保存一次只记录一次日志，粗粒度。具体删除、添加、修改内容，可从参数中解析
				StringBuffer lsql = new StringBuffer("insert into zftz_logs");
				lsql.append("(id,proid,cid,optype,params,userid,ctime)");
				lsql.append("select sq_zftz_log.nextval,?,?,'saveBankInfo',?,?,sysdate from dual");
				jdbcTemplate.update(lsql.toString(), new Object[]{proid,cid,strAccs,userid});
			}
		}catch(Exception e){
			info.put("flag", "9");
			info.put("info", e.toString());
			return info;
		}
		info.put("flag", "1");
		info.put("info", "银行开户信息保存成功！");
		return info;
	}
}
