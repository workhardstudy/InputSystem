<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import="patients.Patient" %>  
<%@ page import="patients.PatientDAO" %> 
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">  
  <style type="text/css">  
 #body {  
         background-color: #FFD2BD;       
       }     
  </style>  
        <title>测试页面</title>  

</head>
 <body id="body">  
 	<form>
 		<input type="file" name="export">
 	</form>
        <h1>2020年1月份按住院号和住院次数升序的前10名病人信息如下所示：</h1><br>  
        <%  
        PatientDAO patientDAO=new PatientDAO();  
        ArrayList patients=patientDAO.queryPatients();  
        %>      
        <table  border="1" >  
            <tr >  
                <td >住院号</td>  
                <td>住院次数</td>  
                <td>姓名</td>  
                <td>出院科室</td>  
                <td>出院日期</td> 
                <td>主要诊断编码</td> 
                <td>主要诊断名称</td> 
                <td>主要手术操作编码</td> 
                <td>主要手术操作名称</td>    
            </tr>  
            <%  
            for(int i=0;i<patients.size();i++)  
            {  
                Patient patient=(Patient)patients.get(i);                
            %>  
            <tr>  
                <td><%=patient.getad()%></td>  
                <td><%=patient.gettimes()%></td>    
                <td><%=patient.getname()%></td>  
                <td><%=patient.getcyDepartment()%></td> 
                <td><%=patient.getcyDate()%></td> 
                <td><%=patient.getzyICD10()%></td> 
                <td><%=patient.getzyICD10name()%></td> 
                <td><%=patient.getzyICD9()%></td> 
                <td><%=patient.getzyICD9name()%></td>                 
            </tr>  
            <%  
            }  
            %>  
        </table>  
    </body>  
</html>