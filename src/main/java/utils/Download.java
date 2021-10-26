package utils;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.Map;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.BorderExtent;
import org.apache.poi.ss.usermodel.BorderStyle;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.ss.util.PropertyTemplate;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import pages.Page;
import patients.Patient;
import patients.PatientDAO;

//该类用来实现下载文件
public class Download extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@SuppressWarnings("unchecked")
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String bean = request.getParameter("bean");
		String range = request.getParameter("range");
		String type = request.getParameter("type");
		// System.out.println(bean + "," + range + "," + type);
		if ("patient".equals(bean)) {
			String fileName = null;
			String suffix = null;
			ArrayList<Patient> patients = null;
			Map<String, Object> oldData = null;
			Page oldPage = (Page) request.getSession().getAttribute("oldPage");
			if (oldPage != null)
				oldData = oldPage.getdata();
			if (oldData != null)
				if ("present".equals(range)) {
					int index = (int) oldData.get("index");
					fileName = "第" + index + "页";
					patients = (ArrayList<Patient>) oldData.get("patients");
				} else if ("all".equals(range)) {
					fileName = "全部";
					String cyDeps = (String) oldData.get("cydeps");
					String cyDate1 = (String) oldData.get("cyDate1");
					String cyDate2 = (String) oldData.get("cyDate2");
					try {
						patients = new PatientDAO().queryPatientsBasic(cyDeps, cyDate1, cyDate2);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			if (patients != null) {
				// 重要，重置response
				response.reset();
				// 设置字符集
				response.setCharacterEncoding("UTF-8");
				// 设置文件ContentType类型，自动判断下载文件类型
				response.setContentType("application/octet-stream");
				if ("xls".equals(type) || "xlsx".equals(type)) {
					Workbook wb = null;
					if ("xls".equals(type)) {
						wb = new HSSFWorkbook();
						suffix = ".xls";
					} else if ("xlsx".equals(type)) {
						wb = new XSSFWorkbook();
						suffix = ".xlsx";
					}
					fileName = fileName + "查询结果" + suffix;
					// 设置文件头：最后一个参数是设置下载文件名
					response.setHeader("Content-Disposition",
							"attachment;fileName=" + URLEncoder.encode(fileName, "UTF-8"));
					/*
					 * // 设置单元格边框 CellStyle style = wb.createCellStyle();
					 * style.setBorderBottom(BorderStyle.THIN);
					 * style.setBottomBorderColor(IndexedColors.BLACK.getIndex());
					 * style.setBorderLeft(BorderStyle.THIN);
					 * style.setLeftBorderColor(IndexedColors.BLACK.getIndex());
					 * style.setBorderRight(BorderStyle.THIN);
					 * style.setRightBorderColor(IndexedColors.BLACK.getIndex());
					 * style.setBorderTop(BorderStyle.THIN);
					 * style.setTopBorderColor(IndexedColors.BLACK.getIndex()); // 设置表头 Sheet sheet
					 * = wb.createSheet("查询结果"); Row firstRow = sheet.createRow(0); Cell headerIndex
					 * = firstRow.createCell(0); Cell headerAd = firstRow.createCell(1); Cell
					 * headerTimes = firstRow.createCell(2); Cell headerName =
					 * firstRow.createCell(3); Cell headerDepartment = firstRow.createCell(4); Cell
					 * headerDate = firstRow.createCell(5); headerIndex.setCellValue("序号");
					 * headerIndex.setCellStyle(style); headerAd.setCellValue("住院号");
					 * headerAd.setCellStyle(style); headerTimes.setCellValue("住院次数");
					 * headerTimes.setCellStyle(style); headerName.setCellValue("姓名");
					 * headerName.setCellStyle(style); headerDepartment.setCellValue("出院科室");
					 * headerDepartment.setCellStyle(style); headerDate.setCellValue("出院日期");
					 * headerDate.setCellStyle(style); for (int i = 0; i < patients.size(); i++) {
					 * Patient patient = patients.get(i); // System.out.println(patient.getad());
					 * Row row = sheet.createRow(i + 1); Cell index = row.createCell(0); Cell ad =
					 * row.createCell(1); Cell times = row.createCell(2); Cell name =
					 * row.createCell(3); Cell depament = row.createCell(4); Cell date =
					 * row.createCell(5); index.setCellValue(patient.getindex());
					 * index.setCellStyle(style); ad.setCellValue(patient.getad());
					 * ad.setCellStyle(style); times.setCellValue(patient.gettimes());
					 * times.setCellStyle(style); name.setCellValue(patient.getname());
					 * name.setCellStyle(style); depament.setCellValue(patient.getcyDepartment());
					 * depament.setCellStyle(style); date.setCellValue(patient.getcyDate());
					 * date.setCellStyle(style); }
					 */
					// 创建表格并赋值
					Sheet sheet = wb.createSheet("查询结果");
					Row header = sheet.createRow(0);
					header.createCell(0).setCellValue("序号");
					header.createCell(1).setCellValue("住院号");
					header.createCell(2).setCellValue("住院次数");
					header.createCell(3).setCellValue("姓名");
					header.createCell(4).setCellValue("出院科室");
					header.createCell(5).setCellValue("出院日期");
					for (int i = 0; i < patients.size(); i++) {
						Patient patient = patients.get(i);
						Row row = sheet.createRow(i + 1);
						row.createCell(0).setCellValue(patient.getindex());
						row.createCell(1).setCellValue(patient.getad());
						row.createCell(2).setCellValue(patient.gettimes());
						row.createCell(3).setCellValue(patient.getname());
						row.createCell(4).setCellValue(patient.getcyDepartment());
						row.createCell(5).setCellValue(patient.getcyDate());
					}
					// 设置水平排列方式，水平居中
					CellStyle style = wb.createCellStyle();
					style.setAlignment(HorizontalAlignment.CENTER);
					// 设置字体类型和大小，宋体13号
					Font font = wb.createFont();
					font.setFontName("宋体");
					font.setFontHeightInPoints((short) 13);
					style.setFont(font);
					for (Row row : sheet) {
						for (Cell cell : row) {
							cell.setCellStyle(style);
						}
					}
					// 自动调整列宽，根据workbook第一个字符的字体和宽度调整列宽，如果字体改变则改变后的字体不适用，所以要先设置字体类型和大小
					for (int i = 0; i < 6; i++) {
						sheet.autoSizeColumn(i);
					}
					// 如果workbook第一个字符非中文，解决中文的自动调整列宽的问题
					/*
					 * for (int i = 0; i < 6; i++) { int columnWidth = sheet.getColumnWidth(i) /
					 * 256; for (int j = 0; j < sheet.getLastRowNum(); j++) { if (sheet.getRow(j) !=
					 * null && sheet.getRow(j).getCell(i) != null) { int width =
					 * sheet.getRow(j).getCell(i).getStringCellValue().getBytes().length; if
					 * (columnWidth < width) { columnWidth = width; } } } sheet.setColumnWidth(i,
					 * columnWidth * 256); }
					 */
					// 添加边框
					PropertyTemplate pt = new PropertyTemplate();
					pt.drawBorders(new CellRangeAddress(0, patients.size(), 0, 5), BorderStyle.THIN, BorderExtent.ALL);
					pt.applyBorders(sheet);
					// 冻结第一行，即标题行
					sheet.createFreezePane(0, 1, 0, 1);
					// 输出表格
					wb.write(response.getOutputStream());
					wb.close();
				} else if ("csv".equals(type)) {
					suffix = ".csv";
					fileName = fileName + "查询结果" + suffix;
					// 设置文件头：最后一个参数是设置下载文件名
					response.setHeader("Content-Disposition",
							"attachment;fileName=" + URLEncoder.encode(fileName, "UTF-8"));
					/*
					 * @SuppressWarnings("deprecation") CSVPrinter printer =
					 * CSVFormat.RFC4180.withHeader("序号", "住院号", "住院次数", "姓名","出院科室", "出院日期")
					 * .print(response.getWriter());
					 */
					CSVPrinter printer = CSVFormat.RFC4180.print(response.getWriter());
					printer.printRecord("序号", "住院号", "住院次数", "姓名", "出院科室", "出院日期");
					for (Patient patient : patients) {
						printer.printRecord(patient.getindex(), patient.getad(), patient.gettimes(), patient.getname(),
								patient.getcyDepartment(), patient.getcyDate());
					}
					printer.flush();
					printer.close();
				}
			} else {
				// 设置缓存区编码为UTF-8编码格式
				// response.setCharacterEncoding("UTF-8");
				// 在响应中主动告诉浏览器使用UTF-8编码格式来接收数据
				response.setHeader("Content-Type", "text/html;charset=UTF-8");
				// 可以使用封装类简写Content-Type，使用该方法则无需使用setCharacterEncoding
				response.setContentType("text/html;charset=UTF-8");
				PrintWriter out = response.getWriter();
				out.println("<script>alert(\"无查询结果，请重新查询再导出。\");history.back();</script>");
				out.close();
			}
		}
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGet(request, response);
	}

}
