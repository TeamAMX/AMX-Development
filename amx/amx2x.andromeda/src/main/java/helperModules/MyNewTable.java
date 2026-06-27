package sqlConnected;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class MyNewTable {
	public static void main(String[] args) throws IOException, SQLException {
		try {
		Connection conn=DriverManager.getConnection("jdbc:postgresql://localhost:5432/Andromeda", "postgres", "admin@1234");
		String updateQuery="update amxcorepartdata set name=? where objectid=?;";
		PreparedStatement ps=conn.prepareStatement(updateQuery);
		
		try (BufferedReader br = new BufferedReader(new FileReader("D:\\TharunWorkpace\\New folder\\CorePart.txt"))) {
			String line;
			while((line=br.readLine())!=null) {
				String [] data=line.split("\\|");
				ps.setString(1, data[1]);
				ps.setString(2, data[0]);
				ps.executeUpdate();
			}
			System.out.println("successful");
		}
		}catch(Exception e) {
			e.printStackTrace();
		}
	}
}
