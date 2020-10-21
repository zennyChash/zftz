package com.fwiz.zftz.service;

import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.security.AccessController;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.Provider;
import java.security.Security;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import sun.security.action.GetPropertyAction;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;

import com.sun.crypto.provider.SunJCE;

import sun.misc.BASE64Decoder;
import sun.misc.BASE64Encoder;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.fwiz.zftz.utils.JResponse;
import com.fwiz.utils.Configuration;

import org.apache.log4j.*;
import org.mindrot.jbcrypt.BCrypt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;

@SuppressWarnings({ "unused", "restriction" })
@Transactional
public class AuthService {
	private static Logger log = Logger.getLogger(AuthService.class);
	protected JdbcTemplate jdbcTemplate;
	@Autowired
	public void setJdbcTemplate(JdbcTemplate jdbcTemplate){
		this.jdbcTemplate = jdbcTemplate;
	}
	@Autowired
	private Configuration cg ;
	@Autowired
	private ApplicationContext applicationContext;
	
	public int validateLogin(String userid, String pswdToTest) {
		StringBuffer sql = new StringBuffer("select count(*) from czept_user where user_name=? or telephone=?");
		int cc = jdbcTemplate.queryForObject(sql.toString(), new Object[]{userid,userid},Integer.class);
		if(cc==0){
			return -1;
		}
		sql = new StringBuffer("select nvl(password,'')pswd from czept_user where user_name=? or telephone=?");
		String hashed = jdbcTemplate.queryForObject(sql.toString(), new Object[]{userid,userid},String.class);
		/*int flag = 0;
		if(StringUtils.isEmpty(hashed)){
			return 3;
		}
		try{
			boolean consist = BCrypt.checkpw(pswdToTest, hashed==null?"":hashed);
			flag = consist?0:5;
		}catch(Exception e){
			flag = 9;
			log.error(userid+"验证密码时发生错误："+e.toString());
		}
		return flag;*/
		return 0;
	}

	public Map changePswd(String userid,String oldPswd,String pswd){
		Map info = new HashMap();
		/*StringBuffer sql = null;
		if(!StringUtils.isEmpty(oldPswd)){
			sql = new StringBuffer("select password from users where userid=?");
			String hashed = "";
			try{
				hashed =jdbcTemplate.queryForObject(sql.toString(), new Object[]{userid},String.class);
			}catch(Exception e){}
			if (!BCrypt.checkpw(oldPswd, hashed)){
				info.put("saved", false);
				info.put("msg", "旧密码输入不正确，不能保存设置！");
				return info;
			}
		}
		String hashed = BCrypt.hashpw(pswd, BCrypt.gensalt());
		jdbcTemplate.update("update users set password=? where userid=?",new Object[]{hashed,userid});
		info.put("saved", true);
		info.put("msg", "");*/
		return info;
	}
	public static void main(String[] args){
		String hashed = BCrypt.hashpw("admin", BCrypt.gensalt());
		System.out.println(hashed);
	}

	public JSONObject getSystemBaseInfo(String[] keys) {
		JSONObject jucfg = new JSONObject();
		for(int i=0;i<keys.length;i++){
			String val = cg.getString(keys[i]);
			jucfg.put(keys[i], val);
		}
		return jucfg;
	}

	@SuppressWarnings("restriction")
	public String decrypt(String enStr){
		String deStr = "";
		String algorithm = "Blowfish";
	    Cipher cipher;
	    Security.addProvider(new SunJCE());
	    SecretKey deskey = new SecretKeySpec("hzg-soft".getBytes(), algorithm);

        try {
            cipher = Cipher.getInstance(algorithm);
        } catch (NoSuchAlgorithmException var2) {
            throw new RuntimeException("没有此加密算法，加密器初始化失败", var2);
        } catch (NoSuchPaddingException var3) {
            throw new RuntimeException("加密器初始化失败", var3);
        }
        enStr = urlEncoder(enStr);
        byte[] decryptorData = new byte[enStr.length()];

        try {
            decryptorData = (new BASE64Decoder()).decodeBuffer(enStr);
        } catch (IOException var4) {
            throw new RuntimeException("字符串Base64解码失败", var4);
        }

        deStr = new String(createDecryptor(decryptorData,cipher,deskey));
	    return deStr;
	}
	
	private byte[] createDecryptor(byte[] datasource,Cipher cipher,SecretKey deskey) {
        byte[] decryptorData = (byte[])null;

        try {
            cipher.init(2, deskey);
            decryptorData = cipher.doFinal(datasource);
            return decryptorData;
        } catch (InvalidKeyException var4) {
            throw new RuntimeException("非法的解密密匙，解密失败", var4);
        } catch (BadPaddingException var5) {
            throw new RuntimeException("非法的解密数据，解密失败", var5);
        } catch (IllegalBlockSizeException var6) {
            throw new RuntimeException("解密字符串字节数不对，解密失败", var6);
        }
    }
	private String urlEncoder(String datasource) {
        if(datasource.indexOf(37) < 0) {
            return datasource;
        } else {
            try {
                @SuppressWarnings("restriction")
				String e = (String)AccessController.doPrivileged(new GetPropertyAction("file.encoding"));
                return this.urlEncoder(URLDecoder.decode(datasource, e));
            } catch (Exception var3) {
                var3.printStackTrace();
                throw new RuntimeException("解密失败！");
            }
        }
    }
	
	@SuppressWarnings("restriction")
	public String encrypt(String str){
		String enStr = "";
		String algorithm = "Blowfish";
	    Cipher cipher;
	    Security.addProvider(new SunJCE());
	    SecretKey deskey = new SecretKeySpec("hzg-soft".getBytes(), algorithm);

        try {
            cipher = Cipher.getInstance(algorithm);
        } catch (NoSuchAlgorithmException var2) {
            throw new RuntimeException("没有此加密算法，加密器初始化失败", var2);
        } catch (NoSuchPaddingException var3) {
            throw new RuntimeException("加密器初始化失败", var3);
        }
        enStr = createEncryptor(str, cipher, deskey);
	    return enStr;
	}
	private byte[] createEncryptor(byte[] datasource,Cipher cipher,SecretKey deskey) {
        byte[] encryptorData = (byte[])null;

        try {
            cipher.init(1, deskey);
            encryptorData = cipher.doFinal(datasource);
            return encryptorData;
        } catch (InvalidKeyException var4) {
            throw new RuntimeException("非法的加密密匙，加密失败", var4);
        } catch (BadPaddingException var5) {
            throw new RuntimeException("非法的加密数据，加密失败", var5);
        } catch (IllegalBlockSizeException var6) {
            throw new RuntimeException("加密字符串字节数不对，加密失败", var6);
        }
    }

    public String createEncryptor(String datasource,Cipher cipher,SecretKey deskey) {
        try {
            byte[] e = createEncryptor(datasource.getBytes(),cipher, deskey);
            String enc = (String)AccessController.doPrivileged(new GetPropertyAction("file.encoding"));
            return URLEncoder.encode((new BASE64Encoder()).encode(e), enc);
        } catch (Exception var4) {
            var4.printStackTrace();
            throw new RuntimeException("加密失败");
        }
    }

	public Map getUserInfo(String userid) {
		Map mu = new HashMap();
		StringBuffer sql = new StringBuffer("select u.user_name,to_char(u.id)id,u.full_name,u.telephone,to_char(e.user_type)user_type ");
		sql.append(" from CZEPT_USER u, CZEPT_USER_ENTERPRISE e where u.id=e.user_id(+) and (u.user_name=? or telephone=?)");
		List lst = jdbcTemplate.queryForList(sql.toString(), new Object[]{userid,userid});
		if(lst!=null){
			mu = (Map)lst.get(0); 
		}
		return mu;
	}

	public List getAllModules(String pid) {
		List modules = new ArrayList();
		StringBuffer sql=new StringBuffer("select moduleid id,name text,pid,href,target hrefTarget,isleaf leaf,");
    	sql.append("decode(isleaf,0,'folder','file')cls,dorder from(select * from zftz_modules start with pid is null ");
    	sql.append("connect by prior moduleid=pid ) where qybj=1 and pid ");
    	if(pid==null||"".equals(pid)){
    		sql.append(" is null");
    	}else {
    		sql.append("='").append(pid).append("'");
    	}
    	sql.append(" order by dorder");
    	List rsts = jdbcTemplate.queryForList(sql.toString());
    	if(rsts!=null){
			for(int i=0;i<rsts.size();i++){
				Map r = (Map)rsts.get(i);
				Map v = new HashMap();
				Iterator it = r.entrySet().iterator();
	            while(it.hasNext()) {
	                Entry<String, Object> entry = (Entry)it.next();
	                if("hrefTarget".equalsIgnoreCase((String)entry.getKey())){
	                	v.put("hrefTarget", r.get(entry.getKey()));
	                }else{
	                	v.put(((String)entry.getKey()).toLowerCase(), r.get(entry.getKey()));
	                }
	            }
	            modules.add(v);
			}
    	}
		return modules;
	}

	public List getAccessableModules(String cuser, String pid) {
		List modules = new ArrayList();
		StringBuffer sql=new StringBuffer("select distinct moduleid id,name text,pid,href,target hrefTarget,isleaf leaf,");
    	sql.append("decode(isleaf,0,'folder','file')cls,dorder from( select b.* from zftz_modules b " );
    	sql.append("start with moduleid in(select distinct moduleid from zftz_user_post u,zftz_post_module p where p.postid = u.postid ");
    	sql.append("and u.userid=?) connect by prior b.pid=moduleid )a where qybj=1 and pid ");
    	if(pid==null||"".equals(pid)){
    		sql.append(" is null");
    	}else {
    		sql.append("='").append(pid).append("'");
    	}
    	sql.append(" order by dorder");
    	List rsts = jdbcTemplate.queryForList(sql.toString(),new Object[]{cuser});
    	if(rsts!=null){
			for(int i=0;i<rsts.size();i++){
				Map r = (Map)rsts.get(i);
				Map v = new HashMap();
				Iterator it = r.entrySet().iterator();
	            while(it.hasNext()) {
	                Entry<String, Object> entry = (Entry)it.next();
	                if("hrefTarget".equalsIgnoreCase((String)entry.getKey())){
	                	v.put("hrefTarget", r.get(entry.getKey()));
	                }else{
	                	v.put(((String)entry.getKey()).toLowerCase(), r.get(entry.getKey()));
	                }
	            }
	            modules.add(v);
			}
    	}
		return modules;
	}

	public int validateUser(String userid) {
		//用的是和e平台相同的用户库，暂且都认为合法
		return 0;
	}

}
