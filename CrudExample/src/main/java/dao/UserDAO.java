package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import model.User;

public class UserDAO {

	private static final String CONTEXT = "java:/comp/env";
	private static final String DATASOURCE = "jdbc/demo";

	private static final String INSERT_USERS_SQL = "INSERT INTO users (name, email, country) VALUES (?,?,?)";
	private static final String SELECT_USER_BY_ID = "select * from users where id=?";
	private static final String SELECT_ALL_USERS = "SELECT * from users";
	private static final String DELETE_USERS_SQL = "DELETE from users where id=?";
	private static final String UPDATE_USERS_SQL = "UPDATE users SET name=?, email=?, country=? where id=?";

	// connection
	protected Connection getConnection() throws SQLException, ClassNotFoundException, NamingException {
		Context initContext = new InitialContext();
		Context envContext = (Context) initContext.lookup(CONTEXT);
		DataSource dsconnection = (DataSource) envContext.lookup(DATASOURCE);
		return dsconnection.getConnection();
	}

	// Inserimento o creazione

	public void insertUser(User user) {
		try (Connection connection = getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(INSERT_USERS_SQL)) {
			preparedStatement.setString(1, user.getName());
			preparedStatement.setString(2, user.getEmail());
			preparedStatement.setString(3, user.getCountry());
			preparedStatement.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}
	};

	// updates

	public boolean updateUser(User user) {
		boolean rowUpdated = false;

		try (Connection connection = getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(UPDATE_USERS_SQL)) {
			preparedStatement.setString(1, user.getName());
			preparedStatement.setString(2, user.getEmail());
			preparedStatement.setString(3, user.getCountry());
			preparedStatement.setInt(4, user.getId());
			preparedStatement.executeUpdate();

			rowUpdated = preparedStatement.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}

		return rowUpdated;
	};

	// seleziona per ID

	public User selectUser(int id) {
		User user = null;

		try (Connection connection = getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(SELECT_USER_BY_ID)) {
			preparedStatement.setInt(1, id);
			ResultSet rsResult = preparedStatement.executeQuery();

			while (rsResult.next()) {
				String name = rsResult.getString("name");
				String email = rsResult.getString("email");
				String country = rsResult.getString("country");
				user = new User(id, name, email, country);

			}
			;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return user;
	};

	// ritorare tutti gli user

	public List<User> selectAllUser() {
		List<User> users = new ArrayList<User>();

		try (Connection connection = getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(SELECT_ALL_USERS)) {
			ResultSet rsResult = preparedStatement.executeQuery();

			while (rsResult.next()) {
				int id = rsResult.getInt("id");
				String name = rsResult.getString("name");
				String email = rsResult.getString("email");
				String country = rsResult.getString("country");
				users.add(new User(id, name, email, country));

			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		return users;
	};

	// delete user

	public boolean deleteUser(int id) {
		boolean rowDeleted = false;

		try (Connection connection = getConnection();
				PreparedStatement preparedStatement = connection.prepareStatement(DELETE_USERS_SQL)) {
			preparedStatement.setInt(1, id);
			rowDeleted = preparedStatement.executeUpdate() > 0;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return rowDeleted;
	};
}
