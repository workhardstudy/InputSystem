<%@page import="java.io.OutputStream"%>
<%@page import="org.apache.poi.ss.usermodel.Row"%>
<%@page import="org.apache.poi.ss.usermodel.Sheet"%>
<%@page import="org.apache.poi.xssf.usermodel.XSSFWorkbook"%>
<%@page import="org.apache.poi.hssf.usermodel.HSSFWorkbook"%>
<%@page import="org.apache.poi.ss.usermodel.Workbook"%>
<%@page import="patients.PatientDAO"%>
<%@page import="java.util.Map"%>
<%@page import="pages.Page"%>
<%@page import="patients.Patient"%>
<%@page import="java.util.ArrayList"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<%
		String bean = request.getParameter("bean");
		String range = request.getParameter("range");
		String type = request.getParameter("type");
		System.out.println(bean+","+range+","+type);
		if("patient".equals(bean)){
			ArrayList<Patient> patients = null;
			Map<String,Object> oldData = null;
			Page oldPage = (Page)session.getAttribute("oldPage");
			if(oldPage!=null)
				oldData = oldPage.getdata();
			if(oldData!=null)
				if("present".equals(range))
					patients = (ArrayList<Patient>)oldData.get("patients");
				else if("all".equals(range)){
					String cyDeps = (String)oldData.get("cydeps");
					String cyDate1 = (String)oldData.get("cyDate1");
					String cyDate2 = (String)oldData.get("cyDate2");
					patients = new PatientDAO().queryPatientsBasic(cyDeps, cyDate1, cyDate2);
				}
			if(patients!=null){
				String suffix = null;
				Workbook wb = null;
				if("xls".equals(type)){
					wb = new HSSFWorkbook();
					suffix = ".xls";
				}else if("xlsx".equals(type)){
					wb = new XSSFWorkbook();
					suffix = ".xlsx";
				}
				Sheet sheet = wb.createSheet("查询结果");
				Row firstRow = sheet.createRow(0);
				firstRow.createCell(0).setCellValue("序号");
				firstRow.createCell(1).setCellValue("住院号");
				firstRow.createCell(2).setCellValue("住院次数");
				firstRow.createCell(3).setCellValue("姓名");
				firstRow.createCell(4).setCellValue("出院科室");
				firstRow.createCell(5).setCellValue("出院日期");
				for(int i=0;i<patients.size();i++){
					Patient patient = patients.get(i);
					Row row = sheet.createRow(i+1);
					row.createCell(0).setCellValue(patient.getindex());
					row.createCell(1).setCellValue(patient.getad());
					row.createCell(2).setCellValue(patient.gettimes());
					row.createCell(3).setCellValue(patient.getname());
					row.createCell(4).setCellValue(patient.getcyDepartment());
					row.createCell(5).setCellValue(patient.getcyDate());
				}
				String fileName = "查询结果"+suffix;
				response.reset();
				//1.设置文件ContentType类型，这样设置，会自动判断下载文件类型   
				response.setContentType("multipart/form-data");   
				//2.设置文件头：最后一个参数是设置下载文件名(假如我们叫a.pdf)   
				response.setHeader("Content-Disposition", "attachment;fileName="+fileName);   
				wb.write(response.getOutputStream());
				wb.close();
			}
				
		}
	%>
</body>
</html>