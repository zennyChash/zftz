package com.fwiz.utils;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 自定义RequestParameterWrapper包装类，对request参数进行自定义处理
 */
public class RequestParameterWrapper extends HttpServletRequestWrapper {
    private Logger logger = LoggerFactory.getLogger(this.getClass());
    private Map<String, String[]> params = new HashMap<>();

    /**
     * 包装原request对象.
     */
    public RequestParameterWrapper(HttpServletRequest request) {
        super(request);
        //将现有parameter传递给params
        this.params.putAll(request.getParameterMap());
    }

    /**
     * 重写getParameter，参数从当前类中的map获取
     * @param name
     * @return
     */
    @Override
    public String getParameter(String name) {
        this.logger.info(">>>>>>>>>> 调用 RequestParameterWrapper 的方法获取 {} 参数 <<<<<<<<<<", name);
        String[] values = params.get(name);
        if (values == null || values.length == 0) {
            return null;
        }
        return values[0];
    }

    @Override
    public Map<String, String[]> getParameterMap() {
        return this.params;
    }

    @Override
    public String[] getParameterValues(String name) {
        return params.get(name);
    }

    /**
     * 添加多个参数
     * @param extraParams
     */
    public void addParameters(Map<String, Object> extraParams) {
        for (Map.Entry<String, Object> entry : extraParams.entrySet()) {
            addParameter(entry.getKey(), entry.getValue());
        }
    }

    /**
     * 添加一个参数
     *
     * @param name
     * @param value
     */
    public void addParameter(String name, Object value) {
        if (value != null) {
            if (value instanceof String[]) {
                params.put(name, (String[]) value);
            } else if (value instanceof String) {
                params.put(name, new String[]{(String) value});
            } else {
                params.put(name, new String[]{String.valueOf(value)});
            }
        }
    }
}
