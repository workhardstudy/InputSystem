package departments;

/**
 *
 * @版权 : Copyright (c) 2021-2121 鱼鱼工作室
 * @author: Geniuschen
 * @E-mail: 1021753237@qq.com
 * @版本: 1.0
 * @创建日期: 2021年6月24日 下午4:19:23
 * @ClassName Department
 * @类描述-Description:  TODO(这里用一句话描述这个方法的作用)
 * @修改记录:
 * @版本: 1.0
 */
public class Department {
	private String cyDep;// 科室名称
	private String fParent;// 父科室

	public String getcyDep() {
		return cyDep;
	}

	public void setcyDep(String cyDep) {
		this.cyDep = cyDep;
	}

	public String getfParent() {
		return fParent;
	}

	public void setfParent(String fParent) {
		this.fParent = fParent;
	}
}
