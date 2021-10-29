package pages;

import java.util.Map;

/**
 *
 * @版权 : Copyright (c) 2021-2121 鱼鱼工作室
 * @author: Geniuschen
 * @E-mail: 1021753237@qq.com
 * @版本: 1.0
 * @创建日期: 2021年7月9日 上午8:34:25
 * @ClassName Page
 * @类描述-Description:  TODO(这里用一句话描述这个方法的作用)
 * @修改记录:
 * @版本: 1.0
 */
public class Page {
	private String size;// 页面大小
	private int index;// 查询页数
	private int count;// 总记录数
	private int total;// 总页数
	private String name;// 姓名
	private String number;// 住院号
	private Map<String, Object> data;// 页面数据，保存页面自定义的查询条件及查询结果

	public void setsize(String size) {
		this.size = size;
	}

	public String getsize() {
		return size;
	}

	public void settotal(int total) {
		this.total = total;
	}

	public int gettotal() {
		return total;
	}

	public void setindex(int index) {
		this.index = index;
	}

	public int getindex() {
		return index;
	}

	public void setcount(int count) {
		this.count = count;
	}

	public int getcount() {
		return count;
	}

	public void setname(String name) {
		this.name = name;
	}

	public String getname() {
		return name;
	}

	public void setnumber(String number) {
		this.number = number;
	}

	public String getnumber() {
		return number;
	}

	public void setdata(Map<String, Object> data) {
		this.data = data;
	}

	public Map<String, Object> getdata() {
		return data;
	}
}
