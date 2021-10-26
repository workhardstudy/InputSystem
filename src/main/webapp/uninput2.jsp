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
    	$('#cydepsel').multipleSelect()
  	})
</script>

<title>查询已导出未录入的病历</title>
</head>
<body>
<h3>根据出院科室和出院日期查询已导出未录入的病历:</h3>
<form method="POST" autocomplete="off">
出院科室: <select multiple="multiple" id="cydepsel" name="cydep">
<%
	//获取请求参数，即查询条件
	String[] cydeps = request.getParameterValues("cydep"); 
	String cyDate1 = request.getParameter("cydate1");
	String cyDate2 = request.getParameter("cydate2");
	String pageSize = request.getParameter("pageSize");
	String pageIndex = request.getParameter("pageIndex");
	
	//创建中间变量
	ArrayList<Patient> patients = null;//存储查询结果
	StringBuffer cyDeps = new StringBuffer();//存储出院科室字符串
	SimpleDateFormat sFormat = new SimpleDateFormat("yyyy-MM-dd");//格式化日期的格式
	Date date=null;
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
		if(cydeps!=null) 	    	
	    	for(String cydep : cydeps)
	    		cyDeps.append("'").append(cydep).append("',");    
	    if(cyDeps.length()>0)
	       	cyDeps=cyDeps.delete(cyDeps.length()-1,cyDeps.length());
	}catch(Exception e){
		out.write("<script>$(alert(\"请求参数有误，请重新选择出院科室、出院日期、页面大小及查询页数。\"));</script>");
		e.printStackTrace();
	}
	
	//封装请求参数，同时用于保存查询结果
	Page newPage=new Page();
	newPage.setsize(size);
	newPage.setindex(index);
	Map<String,Object> newData=new HashMap<String,Object>();
	newData.put("cydeps", cydeps.toString());
	newData.put("cydate1", cyDate1);
	newData.put("cydate2", cyDate2);
	newPage.setdata(newData);
	
	//获取在session保存的旧页面数据
	Page oldPage =(Page)session.getAttribute("oldPage");
	if(oldPage != null){
		int oldsize = oldPage.getsize();
		int oldindex = oldPage.getindex();
		Map<String,Object> oldData = oldPage.getdata();
		String oldcydps = (String)oldData.get("cydeps");
		String oldcydate1 = (String)oldData.get("cydate1");
		String oldcydate2 = (String)oldData.get("cydate2");	
		if(oldcydps.equals(cyDeps.toString()) && oldcydate1.equals(cyDate1) && oldcydate2.equals(cyDate2)){
			count = oldPage.getcount();
		}else{
			count = new PatientDAO().count(cyDeps.toString(), cyDate1, cyDate2);
		}		
		if(oldcydps.equals(cyDeps.toString()) && oldcydate1.equals(cyDate1) && oldcydate2.equals(cyDate2) && oldsize==size){
			total = oldPage.gettotal();	
		}else{
			System.out.println("测试total：");
			System.out.println(count/size+count%size==0?0:1);
			System.out.println((int)Math.ceil(count/size));
			
			total = (int)Math.ceil(count/size);
		}
		newPage.setcount(count);
		newPage.settotal(total);
		if(oldcydps.equals(cyDeps.toString()) && oldcydate1.equals(cyDate1) && oldcydate2.equals(cyDate2) && oldsize==size && oldindex==index){
			patients = (ArrayList<Patient>)oldData.get("patients");
		}else{
			patients = new PatientDAO().queryPatientsBasic(newPage);
		}
		newData.put("patients", patients);
	}else{
		PatientDAO patientDAO = new PatientDAO();
		count = patientDAO.count(cyDeps.toString(), cyDate1, cyDate2);
		total = (int)Math.ceil(count/size);	
		newPage.setcount(count);
		newPage.settotal(total);
		patients = patientDAO.queryPatientsBasic(newPage);
		newData.put("patients", patients);
		//在session保存这次查询的页面数据
		session.setAttribute("oldPage", newPage);
	}
	
	
	//获取科室列表数据
	ArrayList<Department> departments = (ArrayList<Department>)session.getAttribute("departments");
	if(departments == null){
		departments = new DepartmentDAO().queryDepartments();
		session.setAttribute("departments", departments);
	}
	
	//创建科室列表
	for(int i=0;i<departments.size();i++)  
	{  
		Department department=(Department)departments.get(i); 
		if(department.getfParent() == null) 
			continue;
		out.write("<option value=\""+department.getcyDep()+"\"");
		//选择的出院科室回显
		if(cydeps!=null && Arrays.asList(cydeps).contains(department.getcyDep()))
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
<input type="hidden" name="pageIndex"/>
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
<div>
	<ul>
		<%
			
			
		%>
	</ul>
</div>
</body>
</html>