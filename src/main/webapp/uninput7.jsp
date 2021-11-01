<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import = "java.util.Date,java.text.SimpleDateFormat,java.util.*,java.sql.*
    ,departments.Department,departments.DepartmentDAO,patients.Patient,patients.PatientDAO,pages.Page"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %> 
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="shortcut icon" type="image/ico" href="favicon.ico"/>  
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
	input[type="text"]{
		width:100px;
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
		//每次提交表格或使用分页按钮查询时，应该检查本次查询条件和上次查询条件是否改变或者本次页面大小是否为all
		//如果条件改变，则重置选择页数为1，这里使用JSP页面进行判断，即在后台使用session保存上次的查询条件进行判断，
		//如果使用javaScript保存上次的查询条件，则可以使用隐藏域保存或者使用cookie保存（需要浏览器支持cookie），
		//前端重置的好处是可以减少服务器的压力，提高性能，坏处是处理方法的代码暴露给用户。
		//如果页面大小为all，则总页数为1，选择页数始终为1，前端重置index
		if(size=="all")
			$("#index").val('1');
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
	String[] deps = request.getParameterValues("cydeps");//选择的出院科室 
	String cyDate1 = request.getParameter("cydate1");//选择的出院日期1
	String cyDate2 = request.getParameter("cydate2");//选择的出院日期2
	String pageSize = request.getParameter("pageSize");//选择的分页大小
	String pageIndex = request.getParameter("pageIndex");//选择的查询页数
	String name = request.getParameter("name");//填写的姓名
	String number = request.getParameter("number");//填写的住院号
	
	//创建中间变量
	ArrayList<Patient> patients = null;//存储查询结果
	String cyDeps=null;//存储出院科室字符串
	int size=0;//页面大小
	int index=1;//选择页数，初始选择第一页
	int count=0;//总记录数
	int total=1;//总页数，默认值只有一页	
		
	//校验数据类型，并初始化查询条件
	try{
		//初始化页面大小，校验数值型
		//if(pageSize != null && !pageSize.equals("all"))
			//size = Integer.parseInt(pageSize);
		//初始化查询页数，校验数值型
		if(pageIndex != null && pageSize != null && !pageSize.equals("all"))
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
		}else
			cyDate2="";
		//初始化出院科室，字符串
		StringBuffer cydeps = new StringBuffer();//缓存拼接出院科室字符串
		if(deps==null || deps.length==0)
			cyDeps="''";
		else{	    	
	    	for(String cydep : deps)
	    		cydeps.append("'").append(cydep).append("',");    
	    	if(cydeps.length()>0)
	    		cyDeps=cydeps.delete(cydeps.length()-1,cydeps.length()).toString();
		}
		//初始化患者姓名
		if(name==null)
			name="";
		//初始化患者住院号
		if(number==null)
			number="";
	}catch(Exception e){
		out.write("<script>$(alert(\"请输入有效参数，请选择出院科室、出院日期、页面大小及查询页数。\"));</script>");
		e.printStackTrace();
	}
	
	//重要问题：因为已导出未录入的数据可能时刻改变，所以查询结果不适合缓存，每次都要连接数据库重新查询。
	//但是上次的查询条件需要缓存，如果查询条件改变，选择页数应该重置为第1页，用session实现。
	//session保存这次的查询结果用于一页查询结果的导出功能。
	if(cyDeps!=null&&cyDate1!=null&&cyDate2!=null&&!cyDeps.equals("''")
	&&!cyDate1.equals("")&&!cyDate2.equals("")&&pageSize!=null){
		//声明旧的查询条件
		Page oldPage = (Page)session.getAttribute("oldPage");
		Map<String,Object> oldData = null;
		String oldcyDeps = null;
		String oldcyDate1 = null;
		String oldcyDate2 = null;
		String oldSize = null;
		String oldName = null;
		String oldNumber = null;
		//获取上次查询条件
		if(oldPage!=null){
			oldData = oldPage.getdata();
			if(oldData!=null){
				oldcyDeps = (String)oldData.get("cydeps");
				oldcyDate1 = (String)oldData.get("cyDate1");
				oldcyDate2 = (String)oldData.get("cyDate2");
				oldName = (String)oldData.get("name");
				oldNumber = (String)oldData.get("number");
			}
			oldSize = oldPage.getsize();
		}	
		
		//比较当前查询条件与上次查询条件，如果查询条件改变，则重置选择页数为第1页。
		if(!pageSize.equals(oldSize)||!cyDeps.equals(oldcyDeps)||!cyDate1.equals(oldcyDate1)
				||!cyDate2.equals(oldcyDate2)||!name.equals(oldName)||!number.equals(oldNumber))
			index=1;
		
		PatientDAO patientDAO = new PatientDAO();
	//录入时导致病案记录发生变化，患者数量可能发生改变，且需要避免不同用户同时修改同一记录出现的错误，应该在录入时增加同步操作。
	//如果是分页查询，则两次查询，第一次按照条件查询总数，第二次按照条件查询患者，如果中间发生录入操作，则两次查询到的患者实际不一定相同。
	//为了保证第一次查询和第二次查询代表的患者一致，使用同步代码块，且和录入使用同一个对象锁，即当前JSP编译的Servlet的对象。
	//由于录入和查询都使用同步操作限制，查询和录入用户多时效率低，但是应该只限当前系统，和广东省病案系统的录入功能独立，造成最终效果不是很好。
	synchronized(this){		
		//是否分页查询，分页查询可以先分页再查询，也可以先查询全部结果在显示分页的结果集，如果使用先分页再查询。
		if(!pageSize.equals("all")){
			//分页查询	
			//按照条件查询总记录数
			count = patientDAO.count(cyDeps, cyDate1, cyDate2,name,number);
			size = Integer.parseInt(pageSize);
			//如果查询条件有效，即总记录数不等于0，则根据条件查询患者信息，否则重置查询页数为第1页。
			if(count!=0){
				//计算总页数
				if(count%size==0)
					total = count/size;
				else
					total = count/size+1;
				//比较当前查询条件与上次查询条件，如果选择页数超界或者查询条件改变，则重置选择页数为第1页。
				//if(index>total||index<1||!pageSize.equals(oldSize)||!cyDeps.equals(oldcyDeps)||!cyDate1.equals(oldcyDate1)
				//	||!cyDate2.equals(oldcyDate2)||!name.equals(oldName)||!number.equals(oldNumber))
				//	index=1;
				//如果选择页数超界，则重置选择页数为第1页
				if(index<1 || index>total)
					index=1;
				patients = patientDAO.queryPatientsBasic(cyDeps,cyDate1,cyDate2,name,number,size,index,count,total);
			}else
				index=1;
		}else{
			//非分页查询
			patients = patientDAO.queryPatientsBasic(cyDeps,cyDate1,cyDate2,name,number);
			//如果页面大小为all，则总页数为1，选择页数始终为1，后台重置index
			//index=1;
		}
	}
		
		//添加重置条件，即查询结果的患者数量为0，则重置选择页数为第1页。
		if(patients==null||patients.size()==0)
			index=1;
		//保存本次查询条件和结果
		if(oldData==null)
			oldData=new HashMap<String,Object>();
		if(oldPage==null)
			oldPage = new Page();
		oldData.put("cydeps", cyDeps);
		oldData.put("cyDate1", cyDate1);
		oldData.put("cyDate2", cyDate2);
		oldData.put("name", name);
		oldData.put("number", number);
		oldData.put("patients", patients);//用于导出结果
		//oldData.put("index", index);
		oldPage.setdata(oldData);
		oldPage.setsize(pageSize);
		session.setAttribute("oldPage", oldPage);
		
		//用于页面最后显示查询结果数量
		//对比前后两次查询条件设在后台，这种重置index在后台，所以使用后台的index，而不是前端传来的pageIndex
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
<!-- 输入患者姓名并回显 -->
<span>姓名：<input type="text" name="name" value="${param.name}"/>&nbsp;</span>
<!-- 输入患者住院号并回显 -->
<span>住院号：<input type="text" name="number" value="${param.number}"/>&nbsp;</span>
<span>分页大小：<select name="pageSize">
	<!-- 设置分页大小，且回显 -->
	<c:choose>
		<c:when test="${param.pageSize ne 'all'}">
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
			<option value="all">全部</option>
		</c:when>
		<c:otherwise>
			<c:forEach begin="50" end="200" step="50" var="i">
				<option value="${i}">${i}</option>
			</c:forEach>
			<option value="all" selected="selected">全部</option>
		</c:otherwise>
	</c:choose>
</select>&nbsp;</span>
<input type="hidden" id="index" name="pageIndex" value="${empty param.pageIndex?1:param.pageIndex}"/>
<input type="submit" value="查询"/>
</form>   
	</td>
	<td>
		<!-- 导出功能的问题：如果是分页查询，这里是先分页后查询并非查询全部结果后显示分页的集合，则导致分页查询，导出全部结果而非本页结果时，
		需要重新查询数据库，因为录入导致病历可能时刻改变，最后查询的数据可能不一致，存在本页查询的结果不在全部导出结果中。
		这里导出结果尽量使用了缓存在session中的patients数据，减少数据库连接，而不是重新查询后再导出结果。-->
		<div id="export">
			<input type="button" value="导出结果" onclick="show()">
			<ul>
			 	<li><a href="export?bean=patient&range=present&type=xls&index=${index}">导出本页为xls文件</a></li>
				<li><a href="export?bean=patient&range=present&type=xlsx&index=${index}">导出本页为xlsx文件</a></li>
				<li><a href="export?bean=patient&range=present&type=csv&index=${index}">导出本页为csv文件</a></li>
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
        		<th>查询时间</th>
        		<th><input type="checkbox" name="input">操作</th>  
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
						<td>${patient.checkDate}</td>
						<!--<td><input type="checkbox" name="selectedPatients"
						 value="${fn:substring(patient.ad,0,fn:length(patient.ad)).concat(patient.times)}">录入</td>
						<td><input type="checkbox" name="input" value="${patient.ad.concat(patient.times)}">录入</td>-->
						<td><input type="checkbox" name="input" value="${patient.id}">录入</td>
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
				总共<span id="total">${total}</span>页，一共${param.pageSize eq "all"?patients.size():count}行，当前选择第${index}页，本页${patients.size()}行。
			</span>
		</td>
	</tr>
</c:if>	
</table>
</body>
</html>