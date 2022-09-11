import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class Main {
    public static void main(String[] args) {
        Connection conn = null;

        try {
            conn = DriverManager.getConnection("jdbc:sqlite:Chinook_Sqlite.sqlite");

            String query = "SELECT * FROM artist LIMIT 5";
            Statement statement = conn.createStatement();
            ResultSet resultSet = statement.executeQuery(query);

            while (resultSet.next()) {
                int id = resultSet.getInt("ArtistId");
                String name = resultSet.getString("Name");
                System.out.println(id + "\t" + name);
            }

        } catch (SQLException e) {
            System.err.println(e.getMessage());
        } finally {
            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                System.err.println(e.getMessage());
            }
        }
    }
}
