<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import = "java.util.Date,java.text.SimpleDateFormat,java.util.*,java.sql.*
    ,departments.Department,departments.DepartmentDAO,patients.Patient,patients.PatientDAO,pages.Page"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="css/multiple-select.css"/>
<style type="text/css">
	table{
		margin:auto;
		border-collapse:collapse;		
	}
	.layout tr th{
		font-size:25px;
		font-weight:bold;	
		padding:15px;
	}
	.layout tr td{
		font-size:18px;		
	}
	.display tr th{
		font-size:20px;
		color: red;
		padding:10px;
	}
	.display tr td {
		border:1px solid black;	
		color: blue;
		text-align: center;
		padding:5px;
	}
	.pageConfig ul{
		list-style:none;
		float:right;
	}
	.pageConfig ul li{
		float:left;
	}
	.pageConfig ul li a{
		color:black;	
	}
	input,select[name="pageSize"]{
		font-size:16px;
	}
	#cydepsel{
		width:180px;
	}
	#skip{
		width:35px;
	}
	#export{
		font-size:18px;	
	}
	#export input{
		border-radius:3px;
		text-align:center;
		cursor:pointer;	
		border:1px solid black;	
	}
	#export ul{
		display:none;
		width: fit-content;
		height:90px;
		overflow-y:auto;
		list-style:none;
		border:1px solid black;		
		background:transparent;
		margin-top:-1px;
		padding:0px;
	}
	#export ul li{
		white-space:nowrap;		
		user-select:none;
		-ms-user-select: none;
		padding:1px 5px 1px 5px;
		cursor:pointer;
	}
	#export ul li:hover{
		background-color:lightgray;
	}
	#export ul li a{
		text-decoration:none;
		color:black;
	}
</style>
<script src="js/jquery-3.6.0.js"></script>
<script src="js/multiple-select.js" type="text/javascript"></script>
<script>
	$(function () {
    	$('#cydepsel').multipleSelect();
    	var elements =$("#export").children("ul").eq(0).children("li").children("a").click(function(){show()});
  	});
	function verify_submit(){
		var cydeps = $("#cydepsel").val();
		var cydate1 = $("input[name='cydate1']").val();
		var cydate2 = $("input[name='cydate2']").val();
		var size = $("select[name='pageSize']").val();
		var index = $("#index").val();
		//判断请求参数是否为空
		if(!String(cydeps)||!cydate1||!cydate2||!size||!index){
			alert("请输入有效参数，请选择出院科室、出院日期、页面大小及查询页数。");
			return false;
		}else
			return true;	
	}
	function query(value){
  		var index=Number($("#index").val());
  		var max=Number($("#total").text());
  		if(value=='first')
  			$("#index").val("1");
  		else if(value=='last')
  			$("#index").val(max);
  		else if(value=='previous')
  			if(index>1)
  				$("#index").val(index-1);
  			else
  				$("#index").val("1");
  		else if(value=='next')
  			if(index<max)
  				$("#index").val(index+1);
  			else
  				$("#index").val(max);
  		else if(value=='skip'){
  			var sikp=$("#skip").val();
  			if(!sikp)
  				return;
  			var skipIndex=Number(sikp);
  			if(skipIndex>=1 && skipIndex<=max)
  				$("#index").val(skipIndex);
  			else
  				$("#index").val("1");
  		}else 
  			$("#index").val(value);
  		$("form").submit();
  	}
	var hidden=true;
	function show(){	
		if(hidden){
			$("#export").children("ul").css("display","block");
			hidden=false;
		}else{
			$("#export").children("ul").css("display","none");
			hidden=true;
		}
	}
</script>
<title>查询已导出未录入的病历</title>
</head>
<body>
<%
	//获取请求参数，即查询条件
	String[] deps = request.getParameterValues("cydeps"); 
	String cyDate1 = request.getParameter("cydate1");
	String cyDate2 = request.getParameter("cydate2");
	String pageSize = request.getParameter("pageSize");
	String pageIndex = request.getParameter("pageIndex");
	
	//创建中间变量
	ArrayList<Patient> patients = null;//存储查询结果
	String cyDeps=null;//存储出院科室字符串
	int size=0;//页面大小
	int index=1;//选择页数
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
		//初始化开始出院日期，校验日期格式
		if(cyDate1 != null && !cyDate1.equals("")){
			Date date = sFormat.parse(cyDate1);
			cyDate1 = sFormat.format(date);
		}else
			cyDate1="";
		//初始化结束出院日期，校验日期格式
		if(cyDate2 != null && !cyDate2.equals("")){
			Date date = sFormat.parse(cyDate2);
			cyDate2 = sFormat.format(date);
			//结束出院日期增加一天
			//Calendar cal = Calendar.getInstance();
			//cal.setTime(date);
			//cal.add(Calendar.DAY_OF_MONTH, 1);
			//cyDate2 = sFormat.format(cal.getTime()); 			
		}else
			cyDate2="";
		//初始化出院科室，字符串
		StringBuffer cydeps = new StringBuffer();//缓存拼接出院科室字符串
		if(deps!=null) 	    	
	    	for(String cydep : deps)
	    		cydeps.append("'").append(cydep).append("',");    
	    if(cydeps.length()>0)
	    	cyDeps=cydeps.delete(cydeps.length()-1,cydeps.length()).toString();
	}catch(Exception e){
		out.write("<script>$(alert(\"请输入有效参数，请选择出院科室、出院日期、页面大小及查询页数。\"));</script>");
		e.printStackTrace();
	}
	
	//重要问题：因为已导出未录入的数据可能时刻改变，所以查询结果不适合缓存，每次都要连接数据库重新查询。
	//但是上次的查询条件需要缓存，如果查询条件改变，选择页数应该重置为第1页，用session实现。
	//session保存这次的查询结果用于一页查询结果的导出功能。
	if(cyDeps!=null&&cyDate1!=null&&cyDate2!=null&&!cyDeps.equals("")
	&&!cyDate1.equals("")&&!cyDate2.equals("")&&size>0){
		//声明旧的查询条件
		Page oldPage = (Page)session.getAttribute("oldPage");
		Map<String,Object> oldData = null;
		String oldcyDeps = null;
		String oldcyDate1 = null;
		String oldcyDate2 = null;
		int oldSize = 0;
		//获取上次查询条件
		if(oldPage!=null){
			oldData = oldPage.getdata();
			if(oldData!=null){
				oldcyDeps = (String)oldData.get("cydeps");
				oldcyDate1 = (String)oldData.get("cyDate1");
				oldcyDate2 = (String)oldData.get("cyDate2");
			}
			oldSize = oldPage.getsize();
		}	
		//按照条件查询总记录数
		PatientDAO patientDAO = new PatientDAO();
		count = patientDAO.count(cyDeps, cyDate1, cyDate2);
		//如果查询条件有效，即总记录数不等于0，则根据条件查询患者信息，否则重置查询页数为第1页。
		if(count!=0){
			//计算总页数
			if(count%size==0)
				total = count/size;
			else
				total = count/size+1;
			//比较当前查询条件与上次查询条件，如果选择页数超界或者查询条件改变，则重置选择页数为第1页。
			if(index>total||index<1||size!=oldSize||!cyDeps.equals(oldcyDeps)
					||!cyDate1.equals(oldcyDate1)||!cyDate2.equals(oldcyDate2))
				index=1;
			patients = patientDAO.queryPatientsBasic(cyDeps,cyDate1,cyDate2,size,index,count,total);
			//下一步几乎不会发生，为了以防万一，添加重置条件，即查询结果的患者数量为0，则重置选择页数为第1页。
			if(patients==null||patients.size()==0)
				index=1;
		}else
			index=1;
		if(oldData==null)
			oldData=new HashMap<String,Object>();
		if(oldPage==null)
			oldPage = new Page();
		oldData.put("cydeps", cyDeps);
		oldData.put("cyDate1", cyDate1);
		oldData.put("cyDate2", cyDate2);
		oldData.put("patients", patients);
		oldData.put("index", index);
		oldPage.setdata(oldData);
		oldPage.setsize(size);
		session.setAttribute("oldPage", oldPage);
		
		pageContext.setAttribute("index", index);
		pageContext.setAttribute("count", count);
		pageContext.setAttribute("total", total);
		pageContext.setAttribute("patients", patients);
	}
	
	//获取科室列表数据，科室数据不会轻易改变，可以使用缓存，用session实现。
	ArrayList<Department> departments = (ArrayList<Department>)session.getAttribute("departments");
	if(departments == null){
		departments = new DepartmentDAO().queryDepartments();
		session.setAttribute("departments", departments);
	}
%>
<table class="layout">
	<tr>
		<th>根据出院科室和出院日期查询已导出未录入的病历</th>
	</tr>
	<tr>
		<td>	
<form method="POST" autocomplete="off" onsubmit="return verify_submit()">
<!-- 创建科室列表，且回显 -->
<c:set var="cydepsStr" value="${fn:join(paramValues.cydeps,',')}" scope="page"/>
<span>出院科室：<select multiple="multiple" id="cydepsel" name="cydeps">
	<c:forEach items="${sessionScope.departments}" var="department">
		<c:if test="${(department.fParent ne null) and (department.fParent ne 'NULL')}">
			<c:choose>
				<c:when test="${fn:contains(cydepsStr,department.cyDep)}">
					<option value="${department.cyDep}" selected="selected">${department.cyDep}</option>
				</c:when>
				<c:otherwise>
					<option value="${department.cyDep}">${department.cyDep}</option>
				</c:otherwise>
			</c:choose>
		</c:if>
	</c:forEach>
</select>&nbsp;</span>
<!-- 选择的开始出院日期回显 -->
<span>开始出院日期：<input type="date" name="cydate1" value="${param.cydate1}"/>&nbsp;</span>
<!-- 选择的结束出院日期回显 -->
<span>结束出院日期：<input type="date" name="cydate2" value="${param.cydate2}"/>&nbsp;</span>
<span>分页大小：<select name="pageSize">
	<!-- 设置分页大小，且回显 -->
	<c:forEach begin="50" end="200" step="50" var="i">
		<c:choose>
			<c:when test="${param.pageSize eq i}">
				<option value="${i}" selected="selected">${i}</option>
			</c:when>
			<c:otherwise>
				<option value="${i}">${i}</option>
			</c:otherwise>
		</c:choose>
	</c:forEach>
</select>&nbsp;</span>
<input type="hidden" id="index" name="pageIndex" value="${empty param.pageIndex?1:param.pageIndex}"/>
<input type="submit" value="查询"/>
</form>   
	</td>
	<td>
		<div id="export">
			<input type="button" value="导出结果" onclick="show()">
			<ul>
			 	<li><a href="export?bean=patient&range=present&type=xls">导出本页为xls文件</a></li>
				<li><a href="export?bean=patient&range=present&type=xlsx">导出本页为xlsx文件</a></li>
				<li><a href="export?bean=patient&range=present&type=csv">导出本页为csv文件</a></li>
				<li><a href="export?bean=patient&range=all&type=xls">全部导出为xls文件</a></li>
				<li><a href="export?bean=patient&range=all&type=xlsx">全部导出为xlsx文件</a></li>
				<li><a href="export?bean=patient&range=all&type=csv">全部导出为csv文件</a></li>			
			</ul>
		</div>	
	</td>
</tr>      
<tr>
	<td>
		<table class="display">  
			<tr>  
				<th>序号</th>
    			<th>住院号</th> 
        		<th>住院次数</th>
       		 	<th>姓名</th> 
        		<th>出院科室</th> 
        		<th>出院日期</th>   
			</tr>  
			<!-- 显示查询结果 -->
			<c:if test="${patients ne null}">	
				<c:forEach items="${patients}" var="patient">
					<tr>
						<td>${patient.index}</td>
						<td>${patient.ad}</td>
						<td>${patient.times}</td>
						<td>${patient.name}</td>
						<td>${patient.cyDepartment}</td>
						<td>${patient.cyDate}</td>
					</tr>
				</c:forEach>	
			</c:if>
		</table>
	</td>
</tr>
<!-- 显示分页查询 -->
<c:if test="${patients ne null}">
	<tr>
		<td>
			<div class="pageConfig">
				<ul>
					<li><a href="javascript:query('first');">首页</a>&nbsp;</li>
					<li><a href="javascript:query('previous');">上一页</a>&nbsp;</li>
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
								out.write(" style='color:red;font-weight:bold'");
							out.write(">"+i+"</a>&nbsp;</li>");		
						}
					%>
					<li><a href="javascript:query('next');">下一页</a>&nbsp;</li>
					<li><a href="javascript:query('last');">尾页</a>&nbsp;&nbsp;</li>
					<li>跳转到第<input type="number" id="skip" min="1" max="${total}"/>页&nbsp;</li>
					<li><input type="button" value="确定" onclick="query('skip')"/></li>
				</ul>
			</div>	
		</td>
	</tr>
	<tr>
		<td align="right">
			<span>
				总共<span id="total">${total}</span>页，一共${count}行，当前选择第${index}页，本页${patients.size()}行。
			</span>
		</td>
	</tr>
</c:if>	
</table>
</body>
</html>