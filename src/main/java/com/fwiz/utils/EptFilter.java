package com.fwiz.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
public class EptFilter implements Filter {
	private static final Logger log = LoggerFactory.getLogger(EptFilter.class);
	@Override
	public void destroy() {
	}

	@SuppressWarnings("unchecked")
	@Override
	public void doFilter(ServletRequest request, ServletResponse response,FilterChain chain) throws IOException, ServletException {
		RequestParameterWrapper rqw = new RequestParameterWrapper((HttpServletRequest) request);
		//从payload取出参数串
		StringBuilder sb = new StringBuilder();
        try{
        	BufferedReader reader = request.getReader();
            char[]buff = new char[1024];
            int len;
            while((len = reader.read(buff)) != -1) {
            	sb.append(buff,0, len);
            }
        }catch (IOException e) {
        	e.printStackTrace();
        }
        String params= sb.toString();
        JSONObject jparams=null;
        try{
        	jparams = JSON.parseObject(params);
        }catch(Exception e){}
		String dataID = jparams!=null?jparams.getString("dataID"):null;
		log.info("dataID:{}",dataID);
		if(!StringUtils.isEmpty(dataID)&&"_ept".equalsIgnoreCase(dataID.substring(dataID.length()-4))){
			rqw.addParameter("dataID", dataID.substring(0,dataID.length()-4));
			chain.doFilter(rqw, response);
			log.info("来自E平台的请求，重置后继续......");
		} else {
			chain.doFilter(request, response);
			log.info("并非来自E平台，继续......");
		}
	}

	@Override
	public void init(FilterConfig arg0) throws ServletException {
	}
}