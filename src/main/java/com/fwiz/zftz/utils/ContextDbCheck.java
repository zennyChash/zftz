package com.fwiz.zftz.utils;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;
import org.apache.commons.dbcp.BasicDataSource;

@Component
public class ContextDbCheck implements ApplicationContextAware {
 
    private static ApplicationContext context;
 
    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        try {
            context = applicationContext;
            // ===== 在项目初始化bean后检验数据库连接是否
            BasicDataSource dataSource = (BasicDataSource) context.getBean("dataSource");
            dataSource.getConnection().close();
            System.out.println("数据库连接正常。");
        } catch (Exception e) {
            e.printStackTrace();
            // ===== 当检测数据库连接失败时, 停止项目启动
            System.exit(-1);
        }
    }
 
    public ApplicationContext getApplicationContext() {
        return context;
    }
}
