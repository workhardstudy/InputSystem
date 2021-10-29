package patients;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import pages.Page;
import utils.SqlUtils;

/**
 *
 * @版权 : Copyright (c) 2021-2121 鱼鱼工作室
 * @author: Geniuschen
 * @E-mail: 1021753237@qq.com
 * @版本: 1.0
 * @创建日期: 2021年6月16日 上午11:30:39
 * @ClassName PatientDAO
 * @类描述-Description:  查询病人信息
 * @修改记录:
 * @版本: 1.0
 */
public class PatientDAO {
//-----------------------------------------未修改----------------------------------------------------
	@SuppressWarnings("unchecked")
	public ArrayList<Patient> queryPatients() throws Exception {// 实现对数据库的访问
		String sql = "select top 10 t1.FPRN+cast(t1.FTIMES as varchar) 唯一标识,t1.FPRN 住院号,t1.FTIMES 住院次数,t1.FNAME 姓名,t1.FCYDEPT 出院科室,t1.FCYDATE 出院日期,t2.FICDM 主要诊断编码,t2.FJBNAME 主要诊断名称,t3.FOPCODE 主要手术操作编码,t3.FOP 主要手术操作名称 "
				+ "from tPatientVisit t1 inner join tDiagnose t2 on t1.FPRN=t2.FPRN and t1.FTIMES=t2.FTIMES left join tOperation t3 on t1.FPRN=t3.FPRN and t1.FTIMES=t3.FTIMES "
				+ "where t1.FCYDATE between '2020-1-1' and dateadd(ss,-1,'2020-2-1') and t2.FZDLX='1' and (t3.FPX=1 or t3.FPX is null) order by t1.FPRN asc,t1.FTIMES asc";
		// SQL语句，查询2020年1月份按住院号和住院次数升序的前10名病人信息
		return (ArrayList<Patient>) getResults(sql, "object", "batj").get("patients");
	}

	@SuppressWarnings("unchecked")
	public ArrayList<Patient> queryPatientsBasic(String cyDeps, String cyDate1, String cyDate2) throws Exception {// 实现对数据库的访问
		cyDate2 = "'" + cyDate2 + " 23:59:59.999'";
		String sql = "select row_number() over(order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc) 行号"
				+ ",FPRN+cast(FTIMES as varchar) 唯一标识,FPRN 住院号,FTIMES 住院次数,FNAME 姓名,FCYDEPT 出院科室,convert(varchar,FCYDATE,23) 出院日期"
				+ " from HIS_BA1 where FCYDATE between '" + cyDate1 + "' and " + cyDate2 + " and FCYDEPT in (" + cyDeps
				+ ") and Fifinput=0"
				+ " order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc;";
		// SQL语句，按照出院日期和出院科室查询已导出未录入的病历信息
		return (ArrayList<Patient>) getResults(sql, "object", "batj").get("patients");
	}

	@SuppressWarnings("unchecked")
	public ArrayList<Patient> queryPatientsBasic(Page page) throws Exception {
		// 获取请求参数
		int size = Integer.parseInt(page.getsize());
		int index = page.getindex();
		int count = page.getcount();
		int total = page.gettotal();
		Map<String, Object> data = page.getdata();
		String cyDeps = (String) data.get("cydeps");
		String cyDate1 = (String) data.get("cydate1");
		String cyDate2 = (String) data.get("cydate2");
		cyDate2 = "'" + cyDate2 + " 23:59:59.999'";

		// 设置top和row_number()
		int top = 0;
		int row = (index - 1) * size;
		if (index == total) {
			top = count;
		} else {
			top = index * size;
		}

		// SQL语句，按照出院科室、出院日期、页面大小和选择页数查询已导出未录入的病历信息
		String sql = "select t2.行号,t1.FPRN+cast(t1.FTIMES as varchar) 唯一标识,t1.FPRN 住院号,t1.FTIMES 住院次数,t1.FNAME 姓名,t1.FCYDEPT 出院科室,convert(varchar,t1.FCYDATE,23) 出院日期\r\n"
				+ "from HIS_BA1 t1,(select top " + top
				+ " row_number() over(order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc) 行号,FPRN+cast(FTIMES as varchar) 唯一标识 from HIS_BA1 where FCYDATE between '"
				+ cyDate1 + "' and " + cyDate2 + " and FCYDEPT in (" + cyDeps + ") and Fifinput=0) t2 \r\n"
				+ "where t1.FPRN+cast(t1.FTIMES as varchar)=t2.唯一标识 and t2.行号>" + row + " \r\n"
				+ "order by 出院科室 asc,出院日期 asc,唯一标识 asc;\r\n";

		return (ArrayList<Patient>) getResults(sql, "object", "batj").get("patients");
	}

	@SuppressWarnings("unchecked")
	public ArrayList<Patient> queryPatientsBasic(String cyDeps, String cyDate1, String cyDate2, int size, int index,
			int count, int total) throws Exception {
		// cyDate2 = "dateadd(ss,-1,'" + cyDate2 + "')";
		cyDate2 = "'" + cyDate2 + " 23:59:59.999'";

		// 设置top和row_number()
		int top = 0;
		int row = (index - 1) * size;
		if (index == total) {
			top = count;
		} else {
			top = index * size;
		}

		// SQL语句，按照出院科室、出院日期、页面大小和选择页数查询已导出未录入的病历信息
		String sql = "select t2.行号,t1.FPRN+cast(t1.FTIMES as varchar) 唯一标识,t1.FPRN 住院号,t1.FTIMES 住院次数,t1.FNAME 姓名,t1.FCYDEPT 出院科室,convert(varchar,t1.FCYDATE,23) 出院日期\r\n"
				+ "from HIS_BA1 t1,(select top " + top
				+ " row_number() over(order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc) 行号,FPRN+cast(FTIMES as varchar) 唯一标识 from HIS_BA1 where FCYDATE between '"
				+ cyDate1 + "' and " + cyDate2 + " and FCYDEPT in (" + cyDeps + ") and Fifinput=0) t2 \r\n"
				+ "where t1.FPRN+cast(t1.FTIMES as varchar)=t2.唯一标识 and t2.行号>" + row + " \r\n"
				+ "order by 出院科室 asc,出院日期 asc,唯一标识 asc;\r\n";

		return (ArrayList<Patient>) getResults(sql, "object", "batj").get("patients");
	}

	public int count(String cyDeps, String cyDate1, String cyDate2) {
		// cyDate2 = "dateadd(ss,-1,'" + cyDate2 + "')";
		cyDate2 = "'" + cyDate2 + " 23:59:59.999'";

		// SQL语句，按照出院日期和出院科室查询已导出未录入的病历总数
		String sql = "select count(*) 总记录数 from HIS_BA1 where FCYDATE between '" + cyDate1 + "' and " + cyDate2
				+ " and FCYDEPT in (" + cyDeps + ") and Fifinput=0;";

		return (int) getResults(sql, "number", "batj").get("count");
	}

//---------------------------修改后-------------------------------------------------------
	@SuppressWarnings("unchecked")
	public ArrayList<Patient> queryPatientsBasic(String cyDeps, String cyDate1, String cyDate2, String name,
			String number, String pageSize, int index, int count, int total) throws Exception {
		cyDate2 = "'" + cyDate2 + " 23:59:59.999'";
		String sql = null;
		if (!pageSize.equals("all")) {
			int size = Integer.parseInt(pageSize);
			// 设置top和row_number()
			int top = 0;
			int row = (index - 1) * size;
			if (index == total) {
				top = count;
			} else {
				top = index * size;
			}
			// SQL语句，按照出院科室、出院日期、页面大小和选择页数查询已导出未录入的病历信息
			sql = "select t2.行号,t1.FPRN+cast(t1.FTIMES as varchar) 唯一标识,t1.FPRN 住院号,t1.FTIMES 住院次数,t1.FNAME 姓名,t1.FCYDEPT 出院科室,convert(varchar,t1.FCYDATE,23) 出院日期\r\n"
					+ "from HIS_BA1 t1,(select top " + top
					+ " row_number() over(order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc) 行号,FPRN+cast(FTIMES as varchar) 唯一标识 from HIS_BA1 where FCYDATE between '"
					+ cyDate1 + "' and " + cyDate2 + " and FCYDEPT in (" + cyDeps + ") and FNAME like '%" + name
					+ "%' and FPRN like '%" + number + "%' and Fifinput=0) t2 \r\n"
					+ "where t1.FPRN+cast(t1.FTIMES as varchar)=t2.唯一标识 and t2.行号>" + row + " \r\n"
					+ "order by 出院科室 asc,出院日期 asc,唯一标识 asc;\r\n";
		} else {
			sql = "select row_number() over(order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc) 行号"
					+ ",FPRN+cast(FTIMES as varchar) 唯一标识,FPRN 住院号,FTIMES 住院次数,FNAME 姓名,FCYDEPT 出院科室,convert(varchar,FCYDATE,23) 出院日期"
					+ " from HIS_BA1 where FCYDATE between '" + cyDate1 + "' and " + cyDate2 + " and FCYDEPT in ("
					+ cyDeps + ") and FNAME like '%" + name + "%' and FPRN like '%" + number + "%' and Fifinput=0"
					+ " order by FCYDEPT asc,convert(varchar,FCYDATE,23) asc,FPRN+cast(FTIMES as varchar) asc;";
		}
		return (ArrayList<Patient>) getResults(sql, "object", "batj").get("patients");
	}

	// 根据条件查询总数，用于分页查询计算开始索引和结束索引。
	public int count(String cyDeps, String cyDate1, String cyDate2, String name, String number) {
		cyDate2 = "'" + cyDate2 + " 23:59:59.999'";
		// SQL语句，按照出院科室、出院日期、姓名和住院号查询已导出未录入的病历总数
		String sql = "select count(*) 总记录数 from HIS_BA1 where FCYDATE between '" + cyDate1 + "' and " + cyDate2
				+ " and FCYDEPT in (" + cyDeps + ") and FNAME like '%" + name + "%' and FPRN like '%" + number
				+ "%' and Fifinput=0;";
		return (int) getResults(sql, "number", "batj").get("count");
	}

//----------------------------获取结果------------------------------------------------------
	private Map<String, Object> getResults(String sql, String type, String db) {
		Map<String, Object> midResult = new SqlUtils().query(sql, db);
		Connection conn = (Connection) midResult.get("connection");
		Statement stat = (Statement) midResult.get("statement");
		ResultSet rSet = (ResultSet) midResult.get("resultSet");
		Map<String, Object> result = new HashMap<String, Object>();
		try {
			if (type == "number") {
				int count = 0;
				while (rSet.next()) {
					count = rSet.getInt("总记录数");
				}
				result.put("count", count);
			}
			if (type == "object") {
				ArrayList<Patient> patients = new ArrayList<Patient>();
				if (rSet != null)
					while (rSet.next()) {
						Patient patient = new Patient();
						patient.setid(rSet.getString("唯一标识"));
						patient.setad(rSet.getString("住院号"));
						patient.settimes(rSet.getString("住院次数"));
						patient.setname(rSet.getString("姓名"));
						patient.setcyDepartment(rSet.getString("出院科室"));
						patient.setcyDate(rSet.getString("出院日期"));
						try {
							patient.setzyICD10(rSet.getString("主要诊断编码"));
							patient.setzyICD10name(rSet.getString("主要诊断名称"));
							patient.setzyICD9(rSet.getString("主要手术操作编码"));
							patient.setzyICD9name(rSet.getString("主要手术操作名称"));
						} catch (Exception e) {
							// 执行到这里说明没有主要诊断编码、主要诊断名称、主要手术操作编码或主要手术操作名称等相关信息。
						}
						try {
							patient.setindex(rSet.getString("行号"));
						} catch (Exception e) {
							// 执行到这里说明没有行号的信息。
						}
						patients.add(patient);
					}
				if (patients.size() <= 0)
					patients = null;
				result.put("patients", patients);
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
				midResult.clear();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return result;
	}
}
