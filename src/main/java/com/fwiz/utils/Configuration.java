package com.fwiz.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.Map.Entry;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

import org.json.JSONObject;
public class Configuration {
	protected JdbcTemplate jdbcTemplate;
	@Autowired
	public void setJdbcTemplate(JdbcTemplate jdbcTemplate){
		this.jdbcTemplate = jdbcTemplate;
	}
	private static Logger log = Logger.getLogger(Configuration.class);
	private static Configuration systemConfig = null;
	private static ResourceBundle resources = null;
	private List systemSets = null;
	private Map mapSystemSets = null;
	private List proSystemSets = null;
	private Map mapProSystemSets = null;
	private Map formFieldsMap = null;
	private Map gridsMap = null;
	//执行检查规则任务时，全局的任务执行状态，批次号——>状态（0：未完，1：执行完）
	private Map taskStatus = new HashMap();
	
	private Configuration(){
	    try{
	    	resources = ResourceBundle.getBundle("Resource", Locale.getDefault());
	    }catch(MissingResourceException mre){
	    	System.out.println(mre.toString());
	    }
    }

    public static Configuration getConfig(){
        if(systemConfig == null)
            systemConfig = new Configuration();
        return systemConfig;
    }
    //检查是否获得正确的资源文件
    private static boolean checkResources(){
        boolean result = true;
        if(resources == null){
            result = false;
        }
        return result;
    }

   /**
    * 获取指定配置项的值
    * @param key 配置项名
    * @param defaultValue 默认值。
    * @return 配置项的值。如找不到该项，则使用默认值。
    */
    public String getString(String key, String defaultValue){
        String result = null;
        if(mapSystemSets==null){
        	try{
        		loadSystemSets();
        	}catch(Exception e){
    	    }
        }
        if(mapSystemSets!=null){
        	Map sysSet = (Map)mapSystemSets.get(key);
        	result = sysSet==null?null:(String)sysSet.get("ivalue");
        }
        if(result==null){
        	try{
        		result=resources.getString(key);
        	}catch(Exception e){
        		result = defaultValue;
        	}
        }
        return result;
    }
    //加载系统设置
  	private void loadSystemSets(){
  		try{
	  		Object[] params = null;
	  		StringBuffer sql = new StringBuffer("select item,iname,ivalue,remark from zftz_systemset order by item");
	  		systemSets=jdbcTemplate.queryForList(sql.toString(),new Object[]{});
	  		if(systemSets!=null&&systemSets.size()>0){
	  			mapSystemSets = new HashMap();
	  	    	for(int i=0;i<systemSets.size();i++){
	  	    		Map ss = (Map)systemSets.get(i);
	  	    		mapSystemSets.put((String)ss.get("item"), ss);
	  	    	}
	  		}
  		}catch(Exception e){
	  	}
  	}
  	
  	private void loadProSystemSets(){
  		try{
	  		Object[] params = null;
	  		StringBuffer sql = new StringBuffer("select item,iname,ivalue,remark from zftz_system_pro_set order by item");
	  		proSystemSets=jdbcTemplate.queryForList(sql.toString(),new Object[]{});
	  		if(proSystemSets!=null&&proSystemSets.size()>0){
	  			mapProSystemSets = new HashMap();
	  	    	for(int i=0;i<proSystemSets.size();i++){
	  	    		Map ss = (Map)proSystemSets.get(i);
	  	    		mapProSystemSets.put((String)ss.get("item"), ss);
	  	    	}
	  		}
  		}catch(Exception e){
	  	}
  	}
  	
  	public void reloadSystemSets(){
  		loadSystemSets();
  	}
    /**
     * 获取指定配置项的值。
     * 该方法不提供默认值。
     * @param key 配置项名
     * @return 配置项的值。
     */
    public String getString(String key){
        return getString(key, null);
    }
    
    public void reloadProSystemSets(){
    	loadProSystemSets();
  	}
    public String getProName(String key){
        String result = null;
        try{
	        /*if(mapProSystemSets==null){
	        	loadProSystemSets();
	        }*/
        	loadProSystemSets();
	        if(mapProSystemSets!=null){
	        	Map proSet = (Map)mapProSystemSets.get(key);
	        	result = proSet==null?null:(String)proSet.get("ivalue");
	        }
	        
	    }catch(Exception e){
	        result = null;
	    }
        return result;
    }
    
    private List lowerCaseKeys(List rsts){
    	if(rsts==null){
    		return null;
    	}
    	List lowerKeyList = new ArrayList();
    	for(int i=0;i<rsts.size();i++){
			Map r = (Map)rsts.get(i);
			Map v = new HashMap();
			Iterator it = r.entrySet().iterator();
            while(it.hasNext()) {
                Entry<String, Object> entry = (Entry)it.next();
                v.put(((String)entry.getKey()).toLowerCase(), r.get(entry.getKey()));
            }
            lowerKeyList.add(v);
    	}
    	return lowerKeyList;
    }
  //查找ext的form字段配置信息
  	public String getExtFormFields(String formID){
  		JSONObject jf = null;
  		String sjf = "";
  		System.out.println("formID："+formID);
  		if(formFieldsMap == null){
  			loadExtFormFields();
  		}
  		if(formFieldsMap != null&& formFieldsMap.containsKey(formID)){
  			jf = (JSONObject)formFieldsMap.get(formID);
  			sjf = jf.toString();
  		}
  		return sjf;
  	}
  	//查找ext的grid配置信息
  	public String getExtGrids(String gridID){
  		JSONObject jg = null;
  		String sjg = "";
  		System.out.println("gridID："+gridID);
  		if(gridsMap == null){
  			loadExtGrids();
  		}
  		if(gridsMap != null&& gridsMap.containsKey(gridID)){
  			jg = (JSONObject)gridsMap.get(gridID);
  			sjg = jg.toString();
  		}
  		return sjg;
  	}
  	private void loadExtFormFields(){
  		String path=getString("formsRoot","/forms/");
  		System.out.println("form的配置："+path);
  		formFieldsMap =new HashMap();
  		loadExtInfo(path,formFieldsMap);
  	}
  	private void loadExtGrids(){
  		String path=getString("gridsRoot","/grids/");
  		System.out.println("grid的配置："+path);
  		gridsMap =new HashMap();
  		loadExtInfo(path,gridsMap);
  	}
  	private void loadExtInfo(String path,Map infoMap){
  		String pre=path.substring(0,1);
  		String pathType = getString("rptPathType", "relative");
  		if("relative".equals(pathType)){//相对路径模式
  			if(!"/".equals(pre)){
  				path="/"+path;
  			}
  			URL rootF=Configuration.class.getClassLoader().getResource(path); 
  			if(rootF==null){
  				log.info(path+" is null!");
  				return;
  			}
  			try{
  				path=rootF.toURI().getPath();
  				System.out.println("grid和form的全路径："+path);
  			}catch(Throwable e){
  				System.out.println("toURI转换错误："+e.toString());
  				path=rootF.getPath();
  				path = path.replaceAll("%20", " ");
  			}
  		}
  		InputStream is=null;
  		List paths=new ArrayList();
  		try{
  			java.io.File dir=new java.io.File(path);
  			getAllFilesPath(dir,paths);
  			if(paths!=null&&paths.size()>0){
  				for(int i=0;i<paths.size();i++){
  					String jPath=(String)paths.get(i);
  					File f=new File(jPath); 
  					is=new FileInputStream(f) ;
  					long contentLength = f.length();
  					byte[] ba = new byte[(int)contentLength];
  					is.read(ba);
  					String info = new String(ba,"utf-8");
  					is.close();
  					JSONObject jp=null;
  					try{
  						jp = new JSONObject(info);
  					}catch(Exception e){
  						System.out.println(e.toString());
  					}
  					if(jp==null){
  						continue;
  					}
  					infoMap.put(jp.getString("id"), jp);
  				}
  			}
  		}catch(Exception e){
  			if(is!=null){
  				try{
  					is.close();
  				}catch(Exception ex){};
  			}
  			System.out.print("加载Ext的配置信息时发生错误："+e.toString());
  		}finally{
  			try{
  				is.close();
  			}catch(Exception e){
  				
  			}
  		}
  		return ;
  	}
  	private void getAllFilesPath(File dir,List pathList)throws Exception{
  		File[] fs = dir.listFiles(); 
  		if(fs==null||fs.length==0)return;
  		for(int i=0; i<fs.length; i++){ 
  			if(fs[i].isDirectory()){
  				getAllFilesPath(fs[i],pathList); 
  			}else{
  				pathList.add(fs[i].getAbsolutePath());
  				System.out.println(fs[i].getAbsolutePath());
  			}
  		} 
  	}
    
    public void reloadAllSets(){
    	reloadSystemSets();
    	loadProSystemSets();
    	loadExtGrids();
    }
    //检查规则的任务开始时，将批次号及其状态放入全局map
	public void setTaskStatus(String tid,int status){
  		taskStatus.put(tid, status);
  	}
	//按批次号获取其状态
	public int getTaskStatus(String tid){
  		int flag = 0;
  		if(taskStatus.containsKey(tid)){
  			flag = ((Integer)taskStatus.get(tid)).intValue();
  		}else{
  			flag = 9;
  		}
  		return flag;
  	}
	//任务完成后，删除批次号及其状态记录
	public void clearTaskLogs(String batchid) {
  		if(taskStatus.containsKey(batchid)){
  			taskStatus.remove(batchid);
  		}
	}
}
