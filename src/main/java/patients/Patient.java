package patients;

/**
 *
 * @版权 : Copyright (c) 2021-2121 鱼鱼工作室
 * @author: Geniuschen
 * @E-mail: 1021753237@qq.com
 * @版本: 1.0
 * @创建日期: 2021年6月16日 上午11:13:31
 * @ClassName Patient
 * @类描述-Description:  病人类
 * @修改记录:
 * @版本: 1.0
 */
public class Patient {
	private String id;// 唯一标识
	private String ad;// 住院号
	private String times;// 住院次数
	private String name;// 姓名
	private String cyDepartment;// 出院科室
	private String cyDate;// 出院日期
	private String zyICD10;// 主要诊断编码
	private String zyICD10name;// 主要诊断名称
	private String zyICD9;// 主要手术操作编码
	private String zyICD9name;// 主要手术操作名称
	private String index;// 分页查询的行号

	public String getindex() {
		return index;
	}

	public void setindex(String index) {
		this.index = index;
	}

	public String getid() {
		return id;
	}

	public void setid(String id) {
		this.id = id;
	}

	public String getad() {
		return ad;
	}

	public void setad(String ad) {
		this.ad = ad;
	}

	public String gettimes() {
		return times;
	}

	public void settimes(String times) {
		this.times = times;
	}

	public String getname() {
		return name;
	}

	public void setname(String name) {
		this.name = name;
	}

	public String getcyDepartment() {
		return cyDepartment;
	}

	public void setcyDepartment(String cyDepartment) {
		this.cyDepartment = cyDepartment;
	}

	public String getcyDate() {
		return cyDate;
	}

	public void setcyDate(String cyDate) {
		this.cyDate = cyDate;
	}

	public String getzyICD10() {
		return zyICD10;
	}

	public void setzyICD10(String zyICD10) {
		this.zyICD10 = zyICD10;
	}

	public String getzyICD10name() {
		return zyICD10name;
	}

	public void setzyICD10name(String zyICD10name) {
		this.zyICD10name = zyICD10name;
	}

	public String getzyICD9() {
		return zyICD9;
	}

	public void setzyICD9(String zyICD9) {
		this.zyICD9 = zyICD9;
	}

	public String getzyICD9name() {
		return zyICD9name;
	}

	public void setzyICD9name(String zyICD9name) {
		this.zyICD9name = zyICD9name;
	}
}
