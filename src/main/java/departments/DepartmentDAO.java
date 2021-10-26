package departments;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Map;

import utils.SqlUtils;

/**
 *
 * @版权 : Copyright (c) 2021-2121 鱼鱼工作室
 * @author: Geniuschen
 * @E-mail: 1021753237@qq.com
 * @版本: 1.0
 * @创建日期: 2021年6月24日 下午5:11:58
 * @ClassName DepartmentDAO
 * @类描述-Description:  TODO(这里用一句话描述这个方法的作用)
 * @修改记录:
 * @版本: 1.0
 */
public class DepartmentDAO {
	public ArrayList<Department> queryDepartments() throws Exception {
		String sql = "select FKsName 科室名称,Fparent 父科室 from tWorkroom where FType=2 and FnoUsed=0 order by FPx asc;";
		return getResults(sql, "batj");
	}

	private ArrayList<Department> getResults(String sql, String db) {
		Map<String, Object> result = new SqlUtils().query(sql, db);
		Connection conn = (Connection) result.get("connection");
		Statement stat = (Statement) result.get("statement");
		ResultSet rSet = (ResultSet) result.get("resultSet");
		ArrayList<Department> departments = new ArrayList<Department>();
		try {
			while (rSet.next()) {
				Department department = new Department();
				department.setcyDep(rSet.getString("科室名称"));
				department.setfParent(rSet.getString("父科室"));
				departments.add(department);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (rSet != null) {
					rSet.close();
				}
				if (stat != null) {
					stat.close();
				}
				if (conn != null) {
					conn.close();
				}
				result.clear();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return departments;
	}
}
