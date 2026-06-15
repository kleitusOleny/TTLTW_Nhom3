package db;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.jdbi.v3.core.Jdbi;
import org.jdbi.v3.sqlobject.SqlObjectPlugin;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.util.Properties;

public class JdbiConnector {
    private static final Logger log = LoggerFactory.getLogger(JdbiConnector.class);
    private static Jdbi jdbi;
    private static HikariDataSource dataSource;
    
    public static synchronized Jdbi get(){
        if (jdbi == null) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
            }
            
            HikariConfig config = new HikariConfig();
            config.setDriverClassName("com.mysql.cj.jdbc.Driver");
            config.setJdbcUrl("jdbc:mysql://" + DBProperties.host() + ":" + DBProperties.port() + "/" + DBProperties.database());
            config.setUsername(DBProperties.username());
            config.setPassword(DBProperties.password());
            
            // Tối ưu cấu hình cho MySQL & HikariCP
            config.addDataSourceProperty("cachePrepStmts", "true");
            config.addDataSourceProperty("prepStmtCacheSize", "250");
            config.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");
            config.addDataSourceProperty("useServerPrepStmts", "true");
            config.setMaximumPoolSize(10);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            
            dataSource = new HikariDataSource(config);
            jdbi = Jdbi.create(dataSource);
            
            // Install SqlObjectPlugin to enable @ColumnName annotation mapping
            jdbi.installPlugin(new SqlObjectPlugin());
        }
        return jdbi;
    }

    public static void shutdown() {
        if (dataSource != null) {
            dataSource.close();
        }
    }
    
    static class DBProperties {
        static Properties prop = new Properties();
        
        static {
            try {
                File f = new File("db.properties");
                InputStream is = null;
                if (f.exists()) {
                    is = new FileInputStream(f);
                } else {
                    is = DBProperties.class.getClassLoader().getResourceAsStream("db.properties");
                }
                if (is != null) {
                    prop.load(is);
                } else {
                    throw new FileNotFoundException("property file 'db.properties' not found in the classpath");
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
        
        public static String host() {
            return prop.getProperty("db.host");
        }
        
        public static int port() {
            return Integer.parseInt(prop.getProperty("db.port"));
        }
        
        public static String username() {
            return prop.getProperty("db.username");
        }
        
        public static String password() {
            return prop.getProperty("db.password");
        }
        
        public static String database() {
            return prop.getProperty("db.dbName");
        }
        
    }

    
}
