package utils;

import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

/**
 *
 * @版权 : Copyright (c) 2021-2121 鱼鱼工作室
 * @author: Geniuschen
 * @E-mail: 1021753237@qq.com
 * @版本: 1.0
 * @创建日期: 2021年7月8日 下午9:52:15
 * @ClassName SqlUtils
 * @类描述-Description:  SQL语句工具类
 * @修改记录:
 * @版本: 1.0
 */
public class SqlUtils {
	public Map<String, Object> query(String sql, String db) {
		Connection conn = null;
		Statement stat = null;
		ResultSet rs = null;
		Map<String, Object> result = new HashMap<String, Object>();
		try {
			// String driverName = "com.microsoft.sqlserver.jdbc.SQLServerDriver"; //
			// 加载JDBC驱动
			// String dbURL = "jdbc:sqlserver://192.168.2.105:1433;databaseName=bagl_java;";
			// 设置连接服务器和数据库的地址
			// String userName = "bakcx"; // 用户名
			// String userPwd = "bakcx";

			// String dbURL = "jdbc:sqlserver://192.168.110.128:1433;databaseName=DWQueue;";
			// String userName = "sa"; // 用户名
			// String userPwd = "sa+123";

			// 从配置文件与相应的数据库连接，并查询数据
			String path = this.getClass().getResource("").getPath();
			if ("batj".equals(db)) {
				path = path + "../../../config/batjUser.properties";
			}
			// System.out.println(path);
			FileInputStream fip = new FileInputStream(path);
			InputStreamReader reader = new InputStreamReader(fip, "UTF-8");
			StringBuffer cache = new StringBuffer();
			while (reader.ready()) {
				cache.append((char) reader.read());
			}
			reader.close();
			fip.close();
			String driverName = cache.substring(cache.indexOf("driver=") + 7);
			driverName = driverName.substring(0, driverName.indexOf(";"));
			String server = cache.substring(cache.indexOf("connection=") + 11);
			server = server.substring(0, server.indexOf(";"));
			String dataBase = cache.substring(cache.indexOf("database=") + 9);
			dataBase = dataBase.substring(0, dataBase.indexOf(";"));
			String dbURL = server + ";databaseName=" + dataBase;
			String userName = cache.substring(cache.indexOf("username=") + 9);
			userName = userName.substring(0, userName.indexOf(";"));
			String userPwd = cache.substring(cache.indexOf("password=") + 9);
			userPwd = userPwd.substring(0, userPwd.indexOf(";"));
			// System.out.println(driverName + "," + dbURL + "," + userName + "," +
			// userPwd);

			Class.forName(driverName);
			conn = DriverManager.getConnection(dbURL, userName, userPwd);// 获取连接
			if (conn != null) {
				System.out.println("Connection Successful!"); // 如果连接成功 控制台输出
			} else {
				System.out.println("Connection fail!");
			}

			stat = conn.createStatement();
			rs = stat.executeQuery(sql);// 定义ResultSet类，用于接收获取的数据
			result.put("connection", conn);
			result.put("statement", stat);
			result.put("resultSet", rs);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
}
