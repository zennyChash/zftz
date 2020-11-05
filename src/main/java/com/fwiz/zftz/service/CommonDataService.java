package com.fwiz.zftz.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.net.URLEncoder;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.CallableStatementCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.alibaba.fastjson.JSONObject;
import com.fwiz.utils.Configuration;

@Transactional
public class CommonDataService {
	private static Logger log = Logger.getLogger(CommonDataService.class);
	protected JdbcTemplate jdbcTemplate;
	@Autowired
	public void setJdbcTemplate(JdbcTemplate jdbcTemplate){
		this.jdbcTemplate = jdbcTemplate;
	}
	@Autowired
	private Configuration cg ;
	
	//获取分页列表数据的统一方法；
	@SuppressWarnings("unchecked")
	public JSONObject getListPaging(String userid,int start,int limit,String sort,String dir,String dtID, String qparams) {
		final JSONObject infos = new JSONObject();
		String proName = cg.getProName("pro_pglist_"+dtID);
		if(proName==null||"".equals(proName)){
			infos.put("error", "未设置相应的存储过程："+"pro_pglist_"+dtID);
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?,?,?,?,?,?)}");
		
		final String fuserid = userid;
		final int fstart = start;
		final int flimit = limit;
		final String fparams = qparams;
		final String fsort = sort;
		final String fdir = dir;
		final List rows = new ArrayList();
		infos.put("totalCount", 0);
		infos.put("rows", rows);
		try{
			@SuppressWarnings("unchecked")
			Object execute = jdbcTemplate.execute(sql.toString(),new CallableStatementCallback() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					cs.setString(1,fuserid);
					cs.setString(2,fparams);
					cs.setString(3,fsort);
					cs.setString(4,fdir);
					cs.setInt(5,fstart);
					cs.setInt(6,flimit);
					cs.registerOutParameter(7, Types.NUMERIC);
	                cs.registerOutParameter(8,oracle.jdbc.OracleTypes.CURSOR);  
	                cs.execute();  
	                int count = cs.getInt(7);
	                infos.put("totalCount", count);
	                ResultSet rs = (ResultSet) cs.getObject(8); 
	                if(rs==null){
	                	return rows;
	                }
	                ResultSetMetaData rsmd=rs.getMetaData();
	        		//获取元信息
	        		int colNum=rsmd.getColumnCount();
	                while (rs.next()) {
	                	Map row = new HashMap();
	                	for(int i=1;i<=colNum;i++){
	        				String sVal=rs.getString(i);
	        				String colName = rsmd.getColumnLabel(i).toLowerCase();
	        				row.put(colName, sVal);
	        			}
	                	rows.add(row);
	                }
	                infos.put("rows", rows);
	                return rows;
				} 
			});
		}catch(Throwable e){
			infos.put("error", e.toString());
			log.error(e.toString());
		}
		return infos;
	}

	@SuppressWarnings("unchecked")
	public JSONObject getList(String userid,String sort,String dir,String dtID, String qparams) {
		final JSONObject infos = new JSONObject();
		String proName = cg.getProName("pro_list_"+dtID);
		if(proName==null||"".equals(proName)){
			infos.put("error", "未设置相应的存储过程："+"pro_list_"+dtID);
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?,?,?)}");
		final String fuserid = userid;
		final String fparams = qparams;
		final String fsort = sort;
		final String fdir = dir;
		try{
			Object data = (List)jdbcTemplate.execute(sql.toString(),new CallableStatementCallback() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					final List rows = new ArrayList();
					cs.setString(1,fuserid);
					cs.setString(2,fparams);
					cs.setString(3,fsort);
					cs.setString(4,fdir);
	                cs.registerOutParameter(5,oracle.jdbc.OracleTypes.CURSOR);  
	                cs.execute();  
	                ResultSet rs = (ResultSet) cs.getObject(5); 
	                if(rs==null){
	                	return rows;
	                }
	                ResultSetMetaData rsmd=rs.getMetaData();
	        		//获取元信息
	        		int colNum=rsmd.getColumnCount();
	                while (rs.next()) {
	                	Map row = new HashMap();
	                	for(int i=1;i<=colNum;i++){
	        				String sVal=rs.getString(i);
	        				String colName = rsmd.getColumnLabel(i).toLowerCase();
	        				row.put(colName, sVal);
	        			}
	                	rows.add(row);
	                }
	                infos.put("rows", rows);
	                return rows;
				} 
			});
		}catch(Throwable e){
			infos.put("error", e.toString());
			log.error(e.toString());
		}
		return infos;
	}

	@SuppressWarnings("unchecked")
	public Map saveData(String userid,String dtID, String params) {
		final JSONObject infos = new JSONObject();
		String proName = cg.getProName("pro_save_"+dtID);
		if(proName==null||"".equals(proName)){
			infos.put("flag", "9");
			infos.put("info", "未设置相应的存储过程："+"pro_save_"+dtID);
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?,?)}");
		String flag = "1";
		final String[] results = new String[2];
		try{
			final String fUser = userid;
			final String fparams = params;
			flag = (String)jdbcTemplate.execute(sql.toString(),new CallableStatementCallback() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					cs.setString(1,fUser);
					cs.setString(2,fparams);
	                cs.registerOutParameter(3,Types.VARCHAR);  
	                cs.registerOutParameter(4,Types.VARCHAR);  
	                cs.execute();  
	                String tmpflag = cs.getString(3);
	                String tmpInfo = cs.getString(4);
	                if(!"1".equals(tmpflag)){
	                	log.error(tmpInfo);
	                }
	                results[0] = tmpflag;
	                results[1] = tmpInfo;
	                infos.put("flag", tmpflag);
	                infos.put("info", tmpInfo);
	                return tmpflag;  
				} 
			});
		}catch(Throwable e){
			results[0] = "9";
			results[1] = e.toString();
			log.error(e.toString());
		}
		return infos;
	}

	@SuppressWarnings("unchecked")
	public Map deleteData(String userid,String dtID, String params) {
		final JSONObject infos = new JSONObject();
		String proName = cg.getProName("pro_delete_"+dtID);
		if(proName==null||"".equals(proName)){
			infos.put("flag", "9");
			infos.put("info", "未设置相应的存储过程："+"pro_delete_"+dtID);
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?,?)}");
		String flag = "1";
		try{
			final String fUser = userid;
			final String fparams = params;
			flag = (String)jdbcTemplate.execute(sql.toString(),new CallableStatementCallback() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					cs.setString(1,fUser);
					cs.setString(2,fparams);
	                cs.registerOutParameter(3,Types.VARCHAR);  
	                cs.registerOutParameter(4,Types.VARCHAR);  
	                cs.execute();  
	                String tmpflag = cs.getString(3);
	                String tmpInfo = cs.getString(4);
	                if(!"1".equals(tmpflag)){
	                	log.error(tmpInfo);
	                }
	                infos.put("flag", tmpflag);
	                infos.put("info", tmpInfo);
	                return tmpflag;  
				} 
			});
		}catch(Throwable e){
			infos.put("flag", "9");
            infos.put("info", e.toString());
			log.error(e.toString());
		}
		return infos;
	}

	@SuppressWarnings("rawtypes")
	public Map getSingleRecord(String userid,String dtID, String params) {
		Map infos = new HashMap();
		String proName = cg.getProName("pro_get_"+dtID);
		if(proName==null||"".equals(proName)){
			infos.put("error", "未设置相应的存储过程："+"pro_get_"+dtID);
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?)}");
		final String fuserid = userid;
		final String fparams = params;
		try{
			@SuppressWarnings("unchecked")
			final Map trow = (Map)jdbcTemplate.execute(sql.toString(),new CallableStatementCallback() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					Map row =new HashMap();
					cs.setString(1,fuserid);
					cs.setString(2,fparams);
	                cs.registerOutParameter(3,oracle.jdbc.OracleTypes.CURSOR);  
	                cs.execute();  
	                ResultSet rs = (ResultSet) cs.getObject(3); 
	                if(rs==null){
	                	return row;
	                }
	                ResultSetMetaData rsmd=rs.getMetaData();
	        		//获取元信息
	        		int colNum=rsmd.getColumnCount();
	                while (rs.next()) {
	                	for(int i=1;i<=colNum;i++){
	        				String sVal=rs.getString(i);
	        				String colName = rsmd.getColumnName(i).toLowerCase();
	        				row.put(colName, sVal);
	        			}
	                }
	                return row;
				} 
			});
			infos = trow;
		}catch(Throwable e){
			infos.put("error", e.toString());
			log.error(e.toString());
		}
		return infos;
	}

	@SuppressWarnings("unchecked")
	public Map checkDuplicate(String userid,String dtID, String params) {
		final JSONObject infos = new JSONObject();
		String proName = cg.getProName("pro_checkDup_"+dtID);
		if(proName==null||"".equals(proName)){
			infos.put("flag", "9");
			infos.put("info", "未设置相应的存储过程："+"pro_checkDup_"+dtID);
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?,?,?)}");
		String flag = "1";
		final String[] results = new String[2];
		try{
			final String fUser = userid;
			final String fparams = params;
			flag = (String)jdbcTemplate.execute(sql.toString(),new CallableStatementCallback() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					cs.setString(1,fUser);
					cs.setString(2,fparams);
	                cs.registerOutParameter(3,Types.VARCHAR);  
	                cs.registerOutParameter(4,Types.VARCHAR);  
	                cs.registerOutParameter(5,Types.VARCHAR); 
	                cs.execute();  
	                String tmpflag = cs.getString(3);
	                String tmpDup = cs.getString(4);
	                String tmpInfo = cs.getString(5);
	                if(!"1".equals(tmpflag)){
	                	log.error(tmpInfo);
	                }
	                infos.put("flag", tmpflag);
	                infos.put("isDup", tmpDup);
	                infos.put("info", tmpInfo);
	                return tmpflag;  
				} 
			});
		}catch(Throwable e){
			infos.put("flag", "9");
			infos.put("isDup", "");
			infos.put("info", e.toString());
			log.error(e.toString());
		}
		return infos;
	}

	public String saveAttachmen(MultipartFile file, String module,String mkey,String ftype) {
		String root = cg.getString("attachmentRoot", "c:/zftz_attach");
		root = root.endsWith("/") ? root : (root + "/");
		String mkeyDir = root+module+"/"+mkey+"/";
		String savePath=mkeyDir;
		try{
			//检查根目录下，模块目录，项目是否存在
		    java.io.File dir=new java.io.File(mkeyDir);
		    if(!dir.exists()){
		    	dir.mkdirs();
		    }
		    SimpleDateFormat sdf=new SimpleDateFormat("yyyyMMddhhmmssSSS");
			java.util.Date cDate = new java.util.Date();     
			String cTime=sdf.format(cDate);
			savePath=mkeyDir+cTime+"."+ftype;
		    try {
				file.transferTo(new File(savePath));
			} catch (Exception e) {
				e.printStackTrace();
				return "error";
			}
		}catch(Exception e){
			log.error(e.toString());
			return "";
		}
		return savePath;
	}
	public String getFileSizeStr(long len, String unit) {
        double fileSize = 0;
        String strSize="";
        if ("B".equals(unit.toUpperCase())) {
            fileSize = (double) len;
            strSize = fileSize+"B";
        } else if ("K".equals(unit.toUpperCase())) {
            fileSize = (double) len / 1024;
            if(fileSize>1024){
            	strSize = getFileSizeStr(len,"M");
            }else{
            	strSize = String.format("%.2f", fileSize)+"K";
            }
        } else if ("M".equals(unit.toUpperCase())) {
            fileSize = (double) len / 1048576;
            if(fileSize<1){
            	strSize = getFileSizeStr(len,"K");
            }else{
            	strSize = String.format("%.2f", fileSize)+"M";
            }
        } else if ("G".equals(unit.toUpperCase())) {
            fileSize = (double) len / 1073741824;
            strSize = String.format("%.2f", fileSize)+"G";
        }
        return strSize;
    }

	public int saveAttachInfo(JSONObject jParams) {
		String module = jParams.getString("module");
		String mkey = jParams.getString("mkey");
		String fld = jParams.getString("fld");
		String fname = jParams.getString("fname");
		String ftype = jParams.getString("ftype");
		String ufname = jParams.getString("ufname");
		String fsize = jParams.getString("fsize");
		String userid = jParams.getString("userid");
		int newid = jdbcTemplate.queryForObject("select sq_zftz_attach.nextval from dual",Integer.class);
		StringBuffer sql = new StringBuffer("insert into zftz_attachfile(id,module,mkey,fld,filename,");
		sql.append("filetype,ufname,fsize,userid,ctime)values(?,?,?,?,?,?,?,?,?,sysdate)");
		jdbcTemplate.update(sql.toString(),new Object[]{newid,module,mkey,fld,fname,ftype,ufname,fsize,userid});
		return newid;
	}
	//下载或打开
	public void downloadAttach(String fid, HttpServletRequest request,HttpServletResponse response, boolean openOnLine) {
		Map finfo = null;
		OutputStream out = null;
		InputStream fis = null;
		try{
			StringBuffer sql = new StringBuffer("select * from zftz_attachfile where id=?");
			finfo = jdbcTemplate.queryForMap(sql.toString(), new Object[]{fid});
			String filePath = (String)finfo.get("UFNAME");
			String fname = (String)finfo.get("FILENAME");
			File f = new File(filePath);
			if (!f.exists()) {
				response.sendError(404, "File not found!");
				return;
			}
			fis = new BufferedInputStream(new FileInputStream(f));
			byte[] buffer = new byte[fis.available()];
			fis.read(buffer);
			fis.close();
			
			response.reset();
			
			String agent = request.getHeader("USER-AGENT");
//			if (null != agent && -1 != agent.indexOf("MSIE")) {
//				fname = URLEncoder.encode(fname, "UTF8");
//			} else if (null != agent && -1 != agent.indexOf("Mozilla")) {
//				fname = new String(fname.getBytes("UTF-8"), "ISO8859-1");
//			} else {
//				fname = URLEncoder.encode(fname, "UTF8");
//			}
			fname = URLEncoder.encode(fname, "UTF8");
			response.setContentType("application/x-download");
			if (openOnLine) { 
				URL u = new URL("file:///" + filePath);
				response.setContentType(u.openConnection().getContentType());
				response.addHeader("Content-Disposition", "inline; filename=" + fname);
			} else { 
				response.setContentType("application/x-msdownload");
				response.addHeader("Content-Disposition", "attachment; filename=" + fname);
			}
			
			
			out = new BufferedOutputStream(response.getOutputStream());
			out.write(buffer);
			out.flush();
			out.close();
	    }catch(IOException e) {  
	        e.printStackTrace();  
	        throw new RuntimeException("文件输出异常!请检查.") ;  
	    }finally {   
	        try {  
	            if(out != null) {  
	                fis.close();
	                out.close(); 
	                out = null; 
	            }  
	        } catch (IOException e) {   
	            e.printStackTrace();  
	        }  
	    }  
	}

	public Map addLog(String optype, String proid,String pname,String cid,String htbh,String jparams,String userid) {
		final JSONObject infos = new JSONObject();
		String proName = cg.getProName("pro_logs");
		if(proName==null||"".equals(proName)){
			infos.put("flag", "9");
			infos.put("info", "未设置记录日志的存储过程。");
			return infos;
		}
		StringBuffer sql = new StringBuffer("{call ");
		sql.append(proName).append("(?,?,?,?,?,?,?,?,?)}");
		String flag = "1";
		final String[] results = new String[2];
		try{
			final String fUser = userid;
			final String fproid = proid;
			final String fpname = pname;
			final String fcid = cid;
			final String fhtbh = htbh;
			final String opname = optype;
			final String fparams = jparams;
			flag = (String)jdbcTemplate.execute(sql.toString(),new CallableStatementCallback<Object>() {
				public Object doInCallableStatement(CallableStatement cs)throws SQLException, DataAccessException {
					cs.setString(1,fUser);
					cs.setString(2,fproid);
					cs.setString(3,fpname);
					cs.setString(4,fcid);
					cs.setString(5,fhtbh);
					cs.setString(6,opname);
					cs.setString(7,fparams);
	                cs.registerOutParameter(8,Types.VARCHAR);  
	                cs.registerOutParameter(9,Types.VARCHAR);  
	                cs.execute();  
	                String tmpflag = cs.getString(8);
	                String tmpInfo = cs.getString(9);
	                if(!"1".equals(tmpflag)){
	                	log.error(tmpInfo);
	                }
	                results[0] = tmpflag;
	                results[1] = tmpInfo;
	                infos.put("flag", tmpflag);
	                infos.put("info", tmpInfo);
	                return tmpflag;  
				}
			});
		}catch(Throwable e){
			results[0] = "9";
			results[1] = e.toString();
			log.error(e.toString());
		}
		return infos;
	}

	public List getBasePanelByPhase(String module)throws Exception {
		List phases = new ArrayList();
		//查询出有几个阶段设置
		StringBuffer sql=new StringBuffer("select phasebm,phasename from zftz_phase where module=?");
    	sql.append(" order by showorder");
    	List rsts = jdbcTemplate.queryForList(sql.toString(),new Object[]{module});
    	if(rsts!=null){
			for(int i=0;i<rsts.size();i++){
				Map r = (Map)rsts.get(i);
				Map phase = new HashMap();
				String phasebm =(String)r.get("phasebm");
				String phasename =(String)r.get("phasename");
				//根据阶段bm获取字段详情
				StringBuffer dsql = new StringBuffer("select fld,fldname name,nvl(isattach,'0') isattach,nvl(canlock,'0') canlock,");
				dsql.append("nvl(editable,'0') editable,nvl(fldtype,'0') fldtype,option_tb,nvl(hasdetail,'0') hasdetail,nvl(ishidden,'0') ishidden");
				dsql.append(" from zftz_dictionary where phasebm=?");
				List flds = jdbcTemplate.queryForList(dsql.toString(),new Object[]{phasebm});
				List lowerflds = new ArrayList();
				if(flds!=null&&flds.size()>0){
					//属性都转化成小写
					for(int j=0;j<flds.size();j++){
						Map f = (Map)flds.get(j);
						Map fv = new HashMap();
						Iterator it = f.entrySet().iterator();
			            while(it.hasNext()) {
			                Entry<String, Object> entry = (Entry)it.next();
			                fv.put(((String)entry.getKey()).toLowerCase(), f.get(entry.getKey()));
			            }
			            lowerflds.add(fv);
					}
					
				}
				phase.put("phasebm", phasebm);
				phase.put("phasename", phasename);
				phase.put("fields", lowerflds);
				phases.add(phase);
			}
    	}
		return phases;
	}
}
