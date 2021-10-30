<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import = "java.util.Date,java.text.SimpleDateFormat,java.util.*,java.sql.*
    ,departments.Department,departments.DepartmentDAO,patients.Patient,patients.PatientDAO,pages.Page"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="css/multiple-select.css"/>
<style type="text/css">
	#cydepsel {
  		width: 200px;
	}
	table tr td {
		color: blue;
		text-align: center;
	}
	table tr th{
		color: red;
	}
</style>
<script src="js/jquery-3.6.0.js"></script>
<script src="js/multiple-select.js" type="text/javascript"></script>
<script>
	$(function () {
    	$('#cydepsel').multipleSelect();
  	});
	function query(value){
  		var index=$("#index").val();
  		if(value=='first')
  			$("#index").val("1");
  		else if(value=='last')
  			$("#index").val($("#total").text());
  		else if(value=='previous')
  			$("#index").val(index-1);
  		else if(value=='next')
  			$("#index").val(index+1);
  		else if(value=='skip')
  			$("#index").val($("#skip").val());
  		else 
  			$("#index").val(value);
  		$("form").submit();
  	}
</script>

<title>查询已导出未录入的病历</title>
</head>
<body>
<%
	//获取请求参数，即查询条件
	String[] deps = request.getParameterValues("cydep"); 
	String cyDate1 = request.getParameter("cydate1");
	String cyDate2 = request.getParameter("cydate2");
	String pageSize = request.getParameter("pageSize");
	String pageIndex = request.getParameter("pageIndex");
	
	//创建中间变量
	ArrayList<Patient> patients = null;//存储查询结果
	String cyDeps=null;//存储出院科室字符串
	int size=0;//页面大小
	int index=0;//选择页数
	int count=0;//总记录数
	int total=0;//总页数	
	
	//校验数据类型，并初始化查询条件
	try{
		//初始化页面大小，校验数值型
		if(pageSize != null)
			size = Integer.parseInt(pageSize);
		//初始化查询页数，校验数值型
		if(pageIndex != null)
			index = Integer.parseInt(pageIndex);
		//校验日期类型
		SimpleDateFormat sFormat = new SimpleDateFormat("yyyy-MM-dd");//格式化日期的格式
		Date date=null;
		//初始化开始出院日期，校验日期格式
		if(cyDate1 != null){
			date = sFormat.parse(cyDate1);
			cyDate1 = sFormat.format(date);
		}
		//初始化结束出院日期，校验日期格式
		if(cyDate2 != null){
			date = sFormat.parse(cyDate2);
			//结束出院日期增加一天
			Calendar cal = Calendar.getInstance();
			cal.setTime(date);
			cal.add(Calendar.DAY_OF_MONTH, 1);
			cyDate2 = sFormat.format(cal.getTime()); 
		}
		//初始化出院科室，字符串
		StringBuffer cydeps = new StringBuffer();
		if(deps!=null) 	    	
	    	for(String cydep : deps)
	    		cydeps.append("'").append(cydep).append("',");    
	    if(cydeps.length()>0)
	    	cyDeps=cydeps.delete(cydeps.length()-1,cydeps.length()).toString();
	}catch(Exception e){
		out.write("<script>$(alert(\"请求参数有误，请重新选择出院科室、出院日期、页面大小及查询页数。\"));</script>");
		e.printStackTrace();
	}
	
	
	//重要问题：因为已导出未录入的数据可能时刻改变，所以不适合使用缓存，每次查询都要连接数据库重新查询，以下方法需要改变。
	//获取在session保存的旧页面数据
	Page oldPage =(Page)session.getAttribute("oldPage");
	if(oldPage != null){
		int oldsize = Integer.parseInt(oldPage.getsize());;
		int oldindex = oldPage.getindex();
		Map<String,Object> oldData = oldPage.getdata();
		String oldcydps = (String)oldData.get("cydeps");
		String oldcydate1 = (String)oldData.get("cydate1");
		String oldcydate2 = (String)oldData.get("cydate2");	
		if(oldcydps.equals(cyDeps) && oldcydate1.equals(cyDate1) && oldcydate2.equals(cyDate2)){
			count = oldPage.getcount();
		}else{
			count = new PatientDAO().count(cyDeps, cyDate1, cyDate2);
			//重新设置旧的总记录数
			oldPage.setcount(count);
		}		
		if(oldcydps.equals(cyDeps) && oldcydate1.equals(cyDate1) && oldcydate2.equals(cyDate2) && oldsize==size){
			total = oldPage.gettotal();	
		}else{
			if(count%size==0)
				total=count/size;
			else
				total=count/size+1;
			//重新设置旧的总页数
			oldPage.settotal(total);
		}
		if(oldcydps.equals(cyDeps) && oldcydate1.equals(cyDate1) && oldcydate2.equals(cyDate2) && oldsize==size && oldindex==index){
			patients = (ArrayList<Patient>)oldData.get("patients");
		}else{
			patients = new PatientDAO().queryPatientsBasic(cyDeps,cyDate1,cyDate2,size,index,count,total);
			//重新设置旧的查询结果
			oldData.put("patients", patients);
		}		
		//重新设置旧的页面数据
		if(oldsize!=size)
			oldPage.setsize(pageSize);
		if(oldindex!=index)
			oldPage.setindex(index);
		if(!oldcydps.equals(cyDeps))
			oldData.put("cydeps", cyDeps);
		if(!oldcydate1.equals(cyDate1))
			oldData.put("cydate1", cyDate1);
		if(!oldcydate2.equals(cyDate2))
			oldData.put("cydate2", cyDate2);
		oldPage.setdata(oldData);
	}else if(cyDeps!=null&&cyDate1!=null&&cyDate2!=null
			&&!cyDeps.equals("")&&!cyDate1.equals("")&&!cyDate2.equals("")&&size!=0&&index!=0){
		oldPage = new Page();
		Map<String,Object> oldData = new HashMap<String,Object>();
		PatientDAO patientDAO = new PatientDAO();
		count = patientDAO.count(cyDeps, cyDate1, cyDate2);
		total = (int)Math.ceil(count/size);
		patients = patientDAO.queryPatientsBasic(cyDeps,cyDate1,cyDate2,size,index,count,total);
		//封装页面数据
		oldPage.setsize(pageSize);
		oldPage.setindex(index);
		oldPage.setcount(count);
		oldPage.settotal(total);
		oldData.put("cydeps", cyDeps);
		oldData.put("cydate1", cyDate1);
		oldData.put("cydate2", cyDate2);
		oldData.put("patients", patients);
		oldPage.setdata(oldData);
		//在session保存这次查询的页面数据
		session.setAttribute("oldPage", oldPage);
	}
	
	//获取科室列表数据
	ArrayList<Department> departments = (ArrayList<Department>)session.getAttribute("departments");
	if(departments == null){
		departments = new DepartmentDAO().queryDepartments();
		session.setAttribute("departments", departments);
	}
%>

<h3>根据出院科室和出院日期查询已导出未录入的病历:</h3>
<form method="POST" autocomplete="off">
出院科室: <select multiple="multiple" id="cydepsel" name="cydep">
<%		
	//创建科室列表
	for(int i=0;i<departments.size();i++)  
	{  
		Department department=(Department)departments.get(i); 
		if(department.getfParent() == null) 
			continue;
		out.write("<option value=\""+department.getcyDep()+"\"");
		//选择的出院科室回显
		if(deps!=null && Arrays.asList(deps).contains(department.getcyDep()))
			out.write(" selected=\"selected\"");
		out.write(">"+department.getcyDep()+"</option>");	
	}
%> 
</select>
开始出院日期: <input type="date" name="cydate1" <%if(cyDate1!=null) out.write("value=\""+cyDate1+"\"");//选择的开始出院日期回显%>/>
结束出院日期: <input type="date" name="cydate2" <%if(cyDate2!=null) out.write("value=\""+cyDate2+"\"");//选择的结束出院日期回显%>/>
分页大小：<select name="pageSize">
<%
	//设置分页大小
		for(int i=50;i<=200;i+=50)
		{
			out.write("<option value=\""+i+"\"");
			//选择的页面大小回显
			if(size == i)
				out.write(" selected=\"selected\"");
			out.write(">"+i+"</option>\n");
		}
%>
</select>
<input type="hidden" name="pageIndex" id="index" value="1"/>
<input type="submit" value="查询" />
</form>         
<br>
<table border="1" align="center">  
	<tr>  
		<th>序号</th>
    	<th>住院号</th> 
        <th>住院次数</th>
        <th>姓名</th> 
        <th>出院科室</th> 
        <th>出院日期</th>   
	</tr>  
<%
	//显示查询结果
  	if(patients!=null)           
  		for(int i=0;i<patients.size();i++){  
  			Patient patient=(Patient)patients.get(i);
%>  
		<tr>  
			<td><%=patient.getindex()%></td>
        	<td><%=patient.getad()%></td>  
        	<td><%=patient.gettimes()%></td>    
        	<td><%=patient.getname()%></td>  
        	<td><%=patient.getcyDepartment()%></td> 
        	<td><%=patient.getcyDate()%></td>                
        </tr>  
<%
	}
%>  
</table>
<%
	//显示分页查询
	if(patients!=null && patients.size()>0){ 
%>
<div>
	<ul>
		<li><a href="javascript:query('first');">首页</a></li>
		<li><a href="javascript:query('previous');">上一页</a></li>
		<%
			int show=6;
			int left=index-show/2;
			int right;
			if(show%2!=0)
				right=index+show/2;
			else
				right=index+show/2-1;
			if(total<=show){
				left=1;
				right=total;
			}else if(left<1){
				left=1;
				right=show;
			}else if(right>total){
				left=total-show+1;
				right=total;
			}											
			for(int i=left;i<=right;i++){
				out.write("<li><a href=\"javascript:query('"+i+"');\"");
				//查询页数回显
				if(i==index)
					out.write(" class='color:red;font-weight:bold;' ");
				out.write(">"+i+"</a></li>");		
			}
		%>
		<li><a href="javascript:query('next');">下一页</a></li>
		<li><a href="javascript:query('last');">尾页</a></li>
		<li><span>跳转到第</span><input type="number" id="skip" min="1" max="<%=total%>"><span>页</span></li>
		<li><input type="button" value="确定" onclick="query('skip')"></li>
	</ul>
	<ul>
		<li><b>总共<i id="total"><%=total%></i>页，一共<i><%=count%></i>条记录</b></li>
	</ul>
</div>
<%
	} 
%>
</body>
</html>