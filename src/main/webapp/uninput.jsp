<%@page import="pages.Page"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import = "java.util.Date,java.text.SimpleDateFormat,java.util.*,java.sql.*,departments.Department,departments.DepartmentDAO,patients.Patient,patients.PatientDAO"%>
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
  
/*  function view(){
	  alert($('#cydepsel').val());
	  console.log($('#cy1').val());
	  console.log($('#cy2').val());
  }*/
</script>

<title>查询已导出未录入的病历</title>
</head>
<body>
<h3>根据出院科室和出院日期查询已导出未录入的病历:</h3>
<!-- <form action="#" method="POST">-->
<form method="POST" autocomplete="off">
出院科室: <select multiple="multiple" id="cydepsel" name="cydep">
<%
	//获取科室列表
	ArrayList<Department> departments = (ArrayList<Department>)session.getAttribute("departments");
	if(departments == null){
		departments = new DepartmentDAO().queryDepartments();
		session.setAttribute("departments", departments);
	}
	
	//获取在session保存页面数据
	Page oldPage =(Page)session.getAttribute("page");
	Page newPage = new Page();
	
	//获取请求参数，即查询条件
	String[] cydeps = request.getParameterValues("cydep"); 
	String cyDate1 = request.getParameter("cydate1");
	String cyDate2 = request.getParameter("cydate2");
	String pageSize = request.getParameter("pageSize");
	String pageIndex = request.getParameter("pageIndex");
	
	//创建中间变量
	StringBuffer cyDeps = new StringBuffer();
	SimpleDateFormat sFormat = new SimpleDateFormat("yyyy-MM-dd");
	ArrayList<Patient> patients = null;	
	
	//初始化
	if(cyDate1 == null)
		cyDate1="";
	if(cyDate2 == null)
		cyDate2="";
	/*if(cydeps != null)
		for(String cydep : cydeps) 
	System.out.println(cydep);*/
	
	//创建科室列表
	for(int i=0;i<departments.size();i++)  
	{  
		Department department=(Department)departments.get(i); 
		if(department.getfParent() == null) 
			continue;
		out.write("<option value=\""+department.getcyDep()+"\" ");
		if(cydeps!=null && Arrays.asList(cydeps).contains(department.getcyDep()))
			out.write("selected=\"selected\"");
		out.write(">"+department.getcyDep()+"</option>");	
	}
%> 
</select>
<!--  
开始出院日期: <input type="date" name="cydate1" id="cy1"/>
结束出院日期: <input type="date" name="cydate2" id="cy2"/>
-->
开始出院日期: <input type="date" name="cydate1" <%if(!cyDate1.equals("")) out.write("value=\""+cyDate1+"\"");%>/>
结束出院日期: <input type="date" name="cydate2" <%if(!cyDate2.equals("")) out.write("value=\""+cyDate2+"\"");%>/>
分页大小：<select name="pageSize">
<%
	//设置分页大小
	try{
		int pageInt = 0;
		if(pageSize != null)
		pageInt = Integer.parseInt(pageSize);
		for(int i=50;i<=200;i+=50)
		{
			out.write("<option value=\""+i+"\"");
			if(pageInt == i)
			out.write(" selected=\"selected\"");
			out.write(">"+i+"</option>\n");
		}
	}catch(NumberFormatException e){
		e.printStackTrace();
	}
%>
</select>
<%--<%
	//需要查询的页数
	out.write("<input type=\"hidden\" name=\"pageIndex\"");
	if(pageIndex != null)
		out.write(" value="+pageIndex);
	out.write("/>");
%>--%>
<input type="hidden" name="pageIndex"/>
<input type="submit" value="查询" />
</form>
<!-- <input type="button" value="测试" onclick="view();" /> -->
<%
if(cyDate1!=null && cyDate2!=null && cydeps!=null) 
    	try{
    		//拼接出院科室字符串，查询条件
    		for(String cydep : cydeps)
    			cyDeps.append("'").append(cydep).append("',");    
    		if(cyDeps.length()>0)
       			cyDeps=cyDeps.delete(cyDeps.length()-1,cyDeps.length());
    		//校验开始出院日期和结束出院日期是否日期格式
    		Date date = sFormat.parse(cyDate1);
    		cyDate1 = sFormat.format(date);
    		//System.out.println(cyDate1);
   			date = sFormat.parse(cyDate2);
   			Calendar cal = Calendar.getInstance();
   			cal.setTime(date);
   			cal.add(Calendar.DAY_OF_MONTH, 1);
   			cyDate2 = sFormat.format(cal.getTime());   			
   			//System.out.println(cyDeps.toString()+" "+cyDate1+" "+cyDate2);
   			//根据查询条件查询出院患者信息
   			patients=new PatientDAO().queryPatientsBasic(cyDeps.toString(), cyDate1, cyDate2);
    	}catch(Exception e){
    		out.write("<script>$(alert(\"请求参数有误，请重新选择出院日期、出院科室及页面大小。\"));</script>");
    		e.printStackTrace();
    	}
%>             
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
  //System.out.print(patients.size());
  	if(patients!=null)           
  		for(int i=0;i<patients.size();i++){  
  	Patient patient=(Patient)patients.get(i);
  %>  
		<tr>  
			<td><%=i+1%></td>
			<!--<td><%--<%=patient.getid()%>--%></td>-->
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