package sqlConnected;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.security.SecureRandom;
import java.sql.*;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

public class ExcelDataToTableConversion {

    static final String URL      = "jdbc:postgresql://localhost:5432/Andromeda";
    static final String USER     = "postgres";
    static final String PASSWORD = "admin@1234";
    static final String TABLE    = "amxsuppliercompanies";

    static final String EXCEL_PATH = "D:Workbook1.xlsx";

    public static void main(String[] args) {
    	long start = System.nanoTime();

        // Excel column order: type(0), supertype(1), name(2), title(3), parentcompany(4),
        //                     phonenumber(5), faxnumber(6), website(7), email(8),
        //                     state(9), country(10), postalcode(11), address(12),
        //                     standardcost(13), companyid(14)

        String insertSQL = "INSERT INTO " + TABLE +
                " (objectid, name, title, companyid, type, supertype, parentcompany," +
                "  phonenumber, faxnumber, website, email, state, country," +
                "  postalcode, address, standardcost)" +
                " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (
            Connection conn       = DriverManager.getConnection(URL, USER, PASSWORD);
            BufferedInputStream fis   = new BufferedInputStream(new FileInputStream(EXCEL_PATH));
            Workbook workbook     = new XSSFWorkbook(fis);
            PreparedStatement pst = conn.prepareStatement(insertSQL) ) {
        	
            DataFormatter fmt = new DataFormatter();
            Sheet sheet       = workbook.getSheetAt(0);
            int rowCount      = 0;

            conn.setAutoCommit(false);

            for (Row row : sheet) {
                if (row.getRowNum() == 0) continue; 

                try {
                    pst.setString(1,  generateHexId("CMPY"));                  
                    pst.setString(2,  fmt.formatCellValue(row.getCell(2)));     
                    pst.setString(3,  fmt.formatCellValue(row.getCell(3)));      
                    pst.setString(4,  fmt.formatCellValue(row.getCell(14)));     
                    pst.setString(5,  fmt.formatCellValue(row.getCell(0)));      
                    pst.setString(6,  fmt.formatCellValue(row.getCell(1)));      
                    pst.setString(7,  fmt.formatCellValue(row.getCell(4)));      
                    pst.setString(8,  fmt.formatCellValue(row.getCell(5)));      
                    pst.setString(9,  fmt.formatCellValue(row.getCell(6)));     
                    pst.setString(10, fmt.formatCellValue(row.getCell(7)));      
                    pst.setString(11, fmt.formatCellValue(row.getCell(8)));      
                    pst.setString(12, fmt.formatCellValue(row.getCell(9)));     
                    pst.setString(13, fmt.formatCellValue(row.getCell(10)));    
                    pst.setString(14, fmt.formatCellValue(row.getCell(11)));     
                    pst.setString(15, fmt.formatCellValue(row.getCell(12)));     
                    pst.setString(16, fmt.formatCellValue(row.getCell(13)));     

                    pst.addBatch();
                    rowCount++;

                    if (rowCount % 100 == 0) {
                        pst.executeBatch();
                        conn.commit();
                        System.out.println("Committed " + rowCount + " rows...");
                    }

                } catch (Exception rowEx) {
                    System.err.println("Skipping row " + row.getRowNum() + ": " + rowEx.getMessage());
                }
            }

            pst.executeBatch();
            conn.commit();
            System.out.println("Total rows inserted: " + rowCount);
            long end = System.nanoTime(); 
            long durationMs = (end - start) / 1_000_000; 
            System.out.println("Execution time: " + durationMs + " ms (" + (durationMs / 1000.0) + " sec)");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String generateHexId(String suffix) {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < 4; i++) {
            String segment = Integer.toHexString(random.nextInt(0x10000)).toUpperCase();
            while (segment.length() < 4) {
                segment = "0" + segment;
            }
            sb.append(segment);
            if (i < 3) sb.append(".");
        }

        sb.append(".").append(suffix.toUpperCase());
        return sb.toString();
    }
}