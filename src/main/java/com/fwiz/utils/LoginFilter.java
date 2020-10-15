package com.fwiz.utils;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.apache.commons.lang3.StringUtils;

import com.alibaba.fastjson.JSONObject;

public class LoginFilter implements Filter{
	public void destroy() {
    }

    public void doFilter(ServletRequest request, ServletResponse response,FilterChain fchain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest)request;
        HttpServletResponse resp =(HttpServletResponse) response;
        HttpSession session = req.getSession();
        String contextPath = req.getContextPath();
        //获得用户请求的uri(相对地址)
        String path = req.getRequestURI();
        //获取session中作为判断的字段
        Configuration cg = Configuration.getConfig();
        String testMode = cg.getString("testMode","off");
        if("on".equals(testMode)){
        	fchain.doFilter(req,resp);
        }else{
	        //登录请求不拦截
	        if(path.indexOf("Login" ) > -1||path.indexOf("index.jsp") > -1){
	        	fchain.doFilter(req,resp);
	        }else {
	        	String userlog = (String) session.getAttribute("userid");
	        	if (StringUtils.isNotEmpty(userlog)) {
	                fchain.doFilter(request, response);
	                return;
	            } else {
	            	response.setCharacterEncoding("UTF-8");
                    response.setContentType("application/json; charset=utf-8");
                    PrintWriter out = response.getWriter();
                    JSONObject jr = new JSONObject();
                    jr.put("msg", "未登录或登录超时，请重新登录！");
                    jr.put("isLogin", "false");
                    out.append(jr.toString());
	            }
	        }
        }
    }
    public void init(FilterConfig arg0) throws ServletException {
        // TODO Auto-generated method stub
    }
}
