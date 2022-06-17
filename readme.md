![crud](https://user-images.githubusercontent.com/94108883/174253066-3deda78c-bd66-4085-962c-9fd3b62d2421.gif)


# DB + DAO + Servlet + JSP

Web app per eseguire funzioni CRUD: Create _ Read _ Update _ Delete

L’applicazione è divisa secondo il modello MVC, model-view-controller.

---

Modello o anche detto “JavaBean” è quella classe che ci permette di gestire le creazione di nuovi utenti. La classe deve avere dei metodi che ci permettono di specificare (tramite il metodo set) dati dalla classe, o prendere (tramite il metodo get) dati dalla classe. 

Dalla pagina JSP parte la richiesta dell’utente che va al servlet e successivamente si collegherà alla classe DAO (Data Access Object) la quale ci permette, insieme alla classe User, di gestire tutte le richieste dell’utente.

---

[User.java](http://User.java) - Model

```java
package model; // è nel pacchetto model

public class User {
	private int id;
	private String name;
	private String email;
	private String country;

	public User(int id, String name, String email, String country) {
		super();
		this.id = id;
		this.name = name;
		this.email = email;
		this.country = country;
	}

	public User(String name, String email, String country) {
		super();
		this.name = name;
		this.email = email;
		this.country = country;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

}
```

La classe ha due costruttori ed è possibile tramite l’overload. Se due metodi non hanno la stessa firma, quindi argomenti e tipi diversi, si possono avere con nomi uguali. I due costruttori ci servono nel caso in cui non volessimo specificare l’id nella creazione dell’oggetto user. Questa classe ci permette di creare utenti da poter inviare al nostro database.

---

[UserDAO.java](http://UserDAO.java) - DAO Class.

Questa classe contiene tutti i metodi necessari per le operazioni CRUD. 

```java
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

	// insert user
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

	// update user
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

	// select user by id
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
		} catch (Exception e) {
			e.printStackTrace();
		}
		return user;
	};

	// select all users
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
```

La classe può ottenere informazioni di accesso direttamente dal web server (tomcat) utilizzando una API (JNDI) che ci permette di acquisire un oggetto che contiene, appunto, i dati di accesso al database. Quest’oggetto rappresenta il datasource in tomcat. 

Dobbiamo aggiungere una risorsa al contesto di tomcat, questa risorsa servirà per ottenere l’accesso. E’ possibile aggiungere la risorsa in vari modi: globalmente, solo nell’applicazione o come in questo caso, direttamente nel file `contex.xml` del server così da avere, per tutte le future applicazioni, una fruizione diretta e veloce.

```xml
<Resource 
		name="jdbc/demo" 
		auth="Container"
		type="javax.sql.DataSource" 
		maxTotal="100" 
		maxIdle="30"
		maxWaitMillis="10000" 
		username="****" 
		password="****"
		driverClassName="com.mysql.jdbc.Driver"
		url="jdbc:mysql://localhost:3306/****" />
```

Resource rappresenta l’oggetto nel file .xml contenente tutte le informazioni necessarie per l’accesso e alcune per la configurazione del server.

- name = il nome della risorsa
- auth = specifica il meccanismo di accesso alla risorsa, può essere ‘container’ o ‘application’
- type = specifica la classe che ricercherà questa risorsa
- maxTotal = il massimo numero di connessioni nella pool
- maxIdle = il massimo numero di connessioni inattive da conservare nella pool
- maxWaitMillis = tempo massimo di attesa per ottenere una connessione dal database, superato si genere un’eccezione.
- username = username database
- password = password database
- driverClassName = il driver per ottenere la connessione
- url = il link per accedere al database

```java
	private static final String CONTEXT = "java:/comp/env";
	private static final String DATASOURCE = "jdbc/demo";
```

Nella classe DAO abbiamo definito queste due stringhe. La prima rappresenta il nodo dell’API JNDI che ci permettere di accedere alle risorse. La seconda rappresenta il nome che abbiamo dato al datasource.

```java
	
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
```

Il metodo getConnection ci permette di utilizzare il nostro datasource ritornando una connessione.

Per poter utilizzare l’API JNDI e quindi ritornare correttamente un connessione abbiamo bisogno di creare un contesto nel quale cercare il nodo JNDI nel quale risiede il nostro datasource.

Per prima cosa creiamo un contesto.

Successivamente quello che ci interessa è prendere da questo contesto l’oggetto che rappresenta il login per il nostro database.
Una volta ottenuto possiamo associarlo al metodo `.getConnection()` il quale ritorna la connessione al database.

La documentazione completa [qui](https://docs.oracle.com/cd/E19229-01/819-2783/agj2eres.html).

---

Ora che abbiamo definito la connessione possiamo definire tutti i metodi per le operazioni CRUD, iniziamo con quello dell’inserimento dati:

```java
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
```

Nel metodo inseriamo un argomento di tipo User chiamato ‘user’ che ci permette di prendere i dati che verranno dalla JSP.

Il blocco try-catch in questo caso è definito `[try-with-resource](https://docs.oracle.com/javase/tutorial/essential/exceptions/tryResourceClose.html).` 

Passando argomenti al blocco quest’ultimo chiudere automaticamente la connessione una volta terminato il processo. 

Citando la documentazione:

The `try`-with-resources statement is a `try` statement that declares one or more resources. A *resource* is an object that must be closed after the program is finished with it. The `try`-with-resources statement ensures that each resource is closed at the end of the statement.

Come argomenti passiamo anche il tipo di stringa per il database utilizzando l’interfaccia PreparedStatement e il suo omonimo metodo.

`[prepareStatement](https://docs.oracle.com/javase/7/docs/api/java/sql/PreparedStatement.html)` è un oggetto che permette di inserire una dichiarazione SQL. 
Quando vogliamo attuare qualsiasi operazione nel database dobbiamo prima dichiarare che tipo di operazione fare. Nel nostro primo caso abbiamo 

```java
INSERT_USERS_SQL = "INSERT INTO users" + "name, email, country VALUES()" + "(?,?,?)";
```

Questo vuol dire che quando partirà il metodo, dopo la connessione, verrà passato al database questo comando che gli dirà “inserisci dentro la tabella users questi valori nelle colonne ‘name, email, country’ con i valori che ti darò.

Utilizzo il futuro perché questo tipo di dichiarazione ci permette di lavorare con chiavi dinamiche da poter inviare al server. 

La sintassi prevede l’utilizzo del question mark “?” per tutti le colonne della tabella, in questo caso tre. 

L’interfaccia `prepareStatement` ci offre un metodo proprio per questo: `setString`.

Il primo argomento del metodo è il parametro a cui vogliamo assegnare il valore. Il valore è definito nel secondo argomento. Quindi:

```java
preparedStatement.setString(1, user.getName());
```

Significa che abbiamo selezionato il primo parametro, in questo caso il ‘name’, e gli abbiamo assegnato il valore preso dalla classe ‘User’ tramite il suo getter.

Infine il metodo `preparedStatement.executeUpdate();` il quale esegue e invia al database.

---

Metodo Update:

```java
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
```

Come principio è simile al precedente. La stessa logica nel blocco try-catch e lo stesso argomento ‘user’. 

In questo caso il metodo ritorna un valore boolean perché a noi serve solo sapere se l’operazione è andata a buon fine o meno, recuperare tutti i valori dal database sarà compito di un altro metodo.

Come nel precedente utilizziamo il PreparedStatement per definire il tipo di operazione, poi gli passiamo i vari valori (in questo caso anche l’id).

L’esecuzione avviene con executeUpdate.

Cambiamo il valore di ‘rowUpdated’ il quale ritorna true.

---

Selezionare per id:

```java
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
```

Questo metodo ritorna un nuovo User interrogando il database tramite ID, che è il parametro del metodo .

Come prima cosa definiamo un nuovo user di tipo User vuoto, quindi null.

Poi con il solito blocco try-catch parametrizzato avviamo una connessione e inviamo al DB uno statement di ricerca tramite ID.

Finora abbiamo eseguito delle operazioni verso il database tramite le nostre dichiarazione(statement), in questo caso vogliamo ricevere noi qualcosa dal database e lo facciamo utilizzando il metodo dell’interfaccia PreparedStatement chiamato `executeQuery();`

Questo metodo esegue la query SQL dichiarata (statement) e ritorna un oggetto contenente i dati che abbiamo chiesto.

Per poter creare una variabile dobbiamo utilizzare l’interfaccia `[ResultSet](https://docs.oracle.com/javase/7/docs/api/java/sql/ResultSet.html)` la quale ci restituisce una tabella di dati presi direttamente dal database.

Adesso dobbiamo iterare questo nuovo oggetto e creare un nuovo utente.

Utilizziamo il costrutto while passando come parametro il risultato della chiamata ‘rsResult’ con il metodo nativo `.next()m`

Questo comporta l’iterazione sull’oggetto. Iterato abbiamo un nuovo user che assegneremo alla variabile ‘user’ definita prima, in questo modo abbiamo ottenuto tramite l’id l’user dal database.

---

Selezionare tutti gli utenti.

```java
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
			;

		} catch (Exception e) {
			e.printStackTrace();
		}
		return users;
	};
```

Questo metodo ci permette di ritornare tutti gli utenti dal DB, per poterlo fare dobbiamo utilizzare l’interfaccia List tipizzandola con il tipo User.

Per prima cosa creiamo una nuova lista tipizzata che conterrà un array di User.

Il blocco try-catch è sempre lo stesso. Come per il metodo della ricerca dell’id, ora dobbiamo interrogare il database affinché ci restituisca tutti i dati. Una volta ottenuti e immagazzinati nella variabile ‘rsResult’ dobbiamo iterare per poter aggiungere ogni singolo user all’array.

Dobbiamo recuperare ogni colonna, quindi ‘name’, ecc.

Lo facciamo utilizzando il metodo dell’interfaccia ResultSet, `[getString](https://docs.oracle.com/javase/7/docs/api/java/sql/ResultSet.html)` il quale ci permette di prendere la colonna in base alla stringa che inseriamo come argomento.

Una volta create tutte le nuove variabili creiamo nuovi User popolandoli con questi dati e inserendoli nell’array creato prima.

Alla fine ritorniamo tutti gli users.

---

Infine, eliminare tutti gli users:

```java
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
```

Come per la ricerca tramite gli id ritorniamo una valore true se il processo è andato a buon fine.

Il blocco try-catch resta lo stesso solo utilizziamo il metodo executeUpdate per inviare lo statement al database affinché elimini l’user con l’id che abbiamo specificato nell’argomento del metodo.

---

[UserServlet.java](http://UserServlet.java) - Servlet

Ora creiamo il servlet con il quale possiamo gestire tutte le richieste del cliente. Le richieste e quindi i dati passati dal cliente verranno gestiti da questa classe la quale avrà vari metodi per ogni esigenza. Questi metodi gestiscono i vari dati che saranno inviati alla classe UserDAO.

```java
package web;

import java.io.IOException;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import dao.UserDAO;
import model.User;

/**
 * Servlet implementation class UserServlet
 */
@WebServlet("/")
public class UserServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	private UserDAO userDAO;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public UserServlet() {

		this.userDAO = new UserDAO();

	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		this.doGet(request, response);

	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getServletPath();

		switch (action) {
		case "/new":
			showNewForm(request, response);
			break;
		case "/insert":
			insertUser(request, response);
			break;
		case "/delete":
			deleteUser(request, response);
			break;
		case "/edit":
			showEditForm(request, response);
			break;
		case "/update":
			editUser(request, response);
			break;
		default:
			listUser(request, response);
			break;
		}
	}

	private void showNewForm(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		RequestDispatcher dispatcher = request.getRequestDispatcher("user-form.jsp");
		dispatcher.forward(request, response);
	};

	private void insertUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String country = request.getParameter("country");
		User newuser = new User(name, email, country);
		userDAO.insertUser(newuser);
		response.sendRedirect("list");
	};

	private void deleteUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		userDAO.deleteUser(id);
		response.sendRedirect("list");
	};

	private void showEditForm(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		User existingUser = userDAO.selectUser(id);
		RequestDispatcher dispatcher = request.getRequestDispatcher("user-form.jsp");
		request.setAttribute("user", exstingUser);
		dispatcher.forward(request, response);

	}

	private void editUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String country = request.getParameter("country");
		User bookUser = new User(id, name, email, country);
		userDAO.updateUser(bookUser);
		response.sendRedirect("list");
	}

	private void listUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		List<User> listUser = userDAO.selectAllUser();
		request.setAttribute("listUser", listUser);
		RequestDispatcher dispatcher = request.getRequestDispatcher("user-list.jsp");
		dispatcher.forward(request, response);

	};

}
```

Perché importare le due interfacce User e UserDAO? 
Con user possiamo creare nuovi utenti e quindi tipizzarli, con l’interfaccia UserDAO possiamo passare gli utenti creati nel servlet ai metodi della classe DAO.

---

```java
protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		this.doGet(request, response);
}
```

I due metodi creati automaticamente dell’IDE quando creiamo una servlet sono ‘doGet’ e  ‘doPost’.

Questi metodi implementano entrambe le due interfacce `HttpServletRequest / HttpServletResponse.`

In questo modo abbiamo la possibilità di gestire i dati delle richieste get e post effettuate dall’utente. Come argomenti abbiamo, appunto, ‘request’ e ‘response’.

Nel metodo ‘doPost’ abbiamo aggiunto una chiamata al secondo metodo ‘doGet’ in modo che a prescindere dal tipo i dati saranno gestiti sempre del metodo ‘doGet’.

---

Metodo principale: `.doGet(request,response)`

```java
protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		String action = request.getServletPath();

		switch (action) {
		case "/new":
			showNewForm(request, response);
			break;
		case "/insert":
			insertUser(request, response);
			break;
		case "/delete":
			deleteUser(request, response);
			break;
		case "/edit":
			showEditForm(request, response);
			break;
		case "/update":
			editUser(request, response);
			break;
		default:
			listUser(request, response);
			break;
		}
	}
```

---

```java
String action = request.[getServletPath](https://docs.oracle.com/javaee/6/api/javax/servlet/http/HttpServletRequest.html#getServletPath())();
```

Quando l’utente clicca sul form o su qualche anchor tag genera una parte di url. Questo metodo cattura questa parte.

Quindi abbiamo utilizzato il costrutto switch passando come argomento la variabile ‘action’ la quale contiene dinamicamente il valore di questo url.

Se ad esempio nel form viene cliccato il bottone ‘inserisci utente’, ad esso è collegato l’azione ‘/insert’ la quale, nel costrutto switch chiamerà il metodo ‘insertUser’.

Come azione di default verrà mostrata la lista completa degli utenti.

---

Adesso la creazione di tutti i metodi, partiamo con il primo: 

```java
private void showNewForm(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		RequestDispatcher dispatcher = request.getRequestDispatcher("user-form.jsp");
		dispatcher.forward(request, response);
	};
```

Questo metodo ci permette di aggiungere gli utenti o modificarli. Nella pagina principale non è presente il form di creazione degli utenti ma solo la lista di tutti. Quando l’utente clicca per creare un nuovo utente o modificarlo avvia questo metodo.

```java
RequestDispatcher dispatcher = request.getRequestDispatcher("user-form.jsp");
```

L’interfaccia ‘RequestDispatcher’ definisce un oggetto che riceve la richiesta dell’utente e grazie al metodo ‘getRequestDispatcher’ trasferisce questa richiesta in un’altra pagina, in questo caso l’utente sarà indirizzato verso ‘user-form.jps’. 

Il metodo `dispatcher.forward(request, response)` invia la richiesta dell’utente alla risorsa di destinazione passandogli i dati.

---

Inserimento utente:

```java
private void insertUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String country = request.getParameter("country");
		User newuser = new User(name, email, country);
		userDAO.insertUser(newuser);
		response.sendRedirect("list");
	};
```

Tutti i metodi devono estendere le interfacce HttpServletRequest/HttpServletResponse per gestire le richieste dell’utente.

La prima cosa da fare è recuperare i valori che abbiamo impostato tramite l’attributo ‘name’ nel form di inserimento.

Tramite l’oggetto request e il suo metodo ‘[getParameter](https://docs.oracle.com/javaee/6/api/javax/servlet/ServletRequest.html#getParameter(java.lang.String))’ possiamo  passare una stringa la quale si riferirà al valore nell’attributo name. 

Per ogni proprietà che vogliamo impostare creiamo una variabile apposita nelle quali colleghiamo, rispettivamente, ogni valore.

Una volta avute tutte le proprietà creiamo un nuovo user aggiungendo al costruttore le variabili.

Ora abbiamo un nuovo user che raccoglie tutte le informazioni scritte dall’utente. Dobbiamo fare in modo che il nostro database ottenga queste informazioni. 
La nostra classe UserDAO contiene il metodo proprio per questo, quindi lo chiamiamo con `userDAO.insertUser(newuser)` e quello che farà sarà semplicemente inviare i dati al database.

---

Cancellare utente:

```java
private void deleteUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		userDAO.deleteUser(id);
		response.sendRedirect("list");
	};
```

Nel form colleghiamo all’attributo name l’id il quale viene poi convertito in numero con la funzione parseInt.

L’id successivamente viene inviato al metodo ‘deleteUser’ nella classe UserDAO che si occuperà di dire al database quale riga eliminare.

---

Modificare utente:

```java
private void showEditForm(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		User existingUser = userDAO.selectUser(id);
		RequestDispatcher dispatcher = request.getRequestDispatcher("user-form.jsp");
		request.setAttribute("user", exstingUser);
		dispatcher.forward(request, response);
}
```

Questo metodo ci permette di selezionare uno specifico oggetto dal database, tramite il suo id, inviarlo alla classe DAO e visualizzare i suoi valori nel form.

La prima cosa è recuperare l’id tramite il parametro nell’attributo name del form. Una volta recuperato c’è bisogno di passarlo al metodo ‘parseInt’ che data una stringa ritorna il suo valore in numero.

Una volta recuperato l’id bisogna richiedere l’oggetto con lo stesso id al database. Quello che facciamo è creare un nuovo oggetto User, ‘existingUser’, e lo preleviamo utilizzando il metodo creato nella classe DAO, ‘selectUser’, passando come argomento l’id.

Una volta raccolti i dati dobbiamo passarli alla pagina di form utilizzando il dispatcher. 

Creiamo un oggetto con l’interfaccia RequestDispatcher in cui utilizziamo il metodo ‘getRequestDispatcher’ dell’oggetto request in modo che ci indirizzi alla pagina che vogliamo, in questo caso “user-form.jsp”.

A questa pagina dobbiamo passare l’user che abbiamo selezionato tramite l’id in modo che possa essere visualizzato nella tabella per poi essere modificato.
Per fare questo usiamo un altro metodo dell’oggetto request: `[setAttribute](https://docs.oracle.com/cd/E17802_01/products/products/servlet/2.5/docs/servlet-2_5-mr2/javax/servlet/ServletRequest.html#setAttribute(java.lang.String,%20java.lang.Object))();`

Questo metodo accetta due parametri: il primo è il nome che sarà utilizzato come attributo e il secondo i dati dell’attributo.
Quindi in questo caso abbiamo creato un attributo ‘user’ nel quale passiamo l’oggetto ‘exstingUser’ così da avere ogni volta l’user dal database che può essere modificato.

Infine utilizzando il metodo ‘[forward](https://docs.oracle.com/cd/E17802_01/products/products/servlet/2.5/docs/servlet-2_5-mr2/javax/servlet/RequestDispatcher.html)’ sul dispatcher possiamo passare i due oggetti che contengono i dati dell’utente, ‘request’ e ‘response’.

---

Modificare e inviare i valori del form:

```java
private void editUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		int id = Integer.parseInt(request.getParameter("id"));
		String name = request.getParameter("name");
		String email = request.getParameter("email");
		String country = request.getParameter("country");
		User bookUser = new User(id, name, email, country);
		userDAO.updateUser(bookUser);
		response.sendRedirect("list");
	}
```

Nella pagina di form abbiamo già riempito tuti le righe del form con i valori dell’oggetto da modificare. Ad ogni valore abbiamo anche specificato un attributo name che ci permette di recuperare i valori.

Adesso dobbiamo modificarli nel database.

Ci serve riprendere il valore ID, la logica segue i precedenti metodi.

Successivamente per ogni attributo name nel form associamo nuove variabili che contengano i valori dell’oggetto modificato.

Una volta raccolti tutti i valori abbiamo bisogno di creare un nuovo utente con quest’ultimi. In questo caso utilizzeremo il costruttore di User specificando anche il valore ID.

Il nostro nuovo oggetto ‘bookUser’ verrà inserito nel metodo della classe DAO apposito per aggiornare le righe, ‘.updateUser();’.

---

Visualizzare tutti gli Utenti:

```java
private void listUser(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		List<User> listUser = userDAO.selectAllUser();
		request.setAttribute("listUser", listUser);
		RequestDispatcher dispatcher = request.getRequestDispatcher("user-list.jsp");
		dispatcher.forward(request, response);
};
```

Questo metodo ci permette di visualizzare tutti gli utenti nel database.

Creiamo un oggetto Lista di tipo User e al suo interno richiamiamo il metodo della classe DAO per selezionare tutti gli utenti.
Adesso abbiamo bisogno di distribuire ad un’altra pagina tutti questi users. Utilizziamo il metodo ‘setAttribute’ che ci permette di creare un attributo utilizzabile nella JSP, lo definiamo “listUser” e i dati che avrà al suo interno saranno quelli dell’oggetto listUser.

Una volta fatto questo possiamo utilizzare il Dispatcher per inviare l’utente in una nuova pagina, precisamente in quella chiamata “user-list.jsp”.

Al dispatcher, successivamente, leghiamo un altro metodo che ci permette di inviare i due oggetti della risposta http, request e response così da averli a disposizione anche nella nuova pagina. 

---

**JSP**

Qui le pagine di VIEW. Le pagine JSP combinano linguaggio Java con html. L’utente invierà richieste e riceverà opportune risposte.

Le pagine JSP sono due: “user-list.jsp” - “user-form.jsp”.

Nella prima saranno raccolti e visualizzati tutti gli utenti dal database. Sarà anche possibile eliminare l’utente o modificarlo.

Cliccando su edit saremo trasferiti nella pagina “user-form.jsp” la quale gestisce due mansioni:

- Creazione dell’utente.
- Modifica utente.

Per velocizzare il layout è presente [bootstrap](https://getbootstrap.com/).

Descriviamo tutti i passaggi.

---

user.list.jsp - User List JSP

```java
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>

<head>
<title>Users List</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.0.0/dist/css/bootstrap.min.css"/>
<link rel="icon" type="image/x-icon" href="https://img.icons8.com/ios/344/user--v1.png">
</head>

<body>

	<nav class="navbar navbar-expand-md navbar-dark" style="background-color: black">

		<ul class="navbar-nav">
			<li><a href="<%=request.getContextPath()%>/list" class="nav-link">Users</a></li>
		</ul>
	</nav>

	<br>

	<div class="row">

		<div class="container">
			<h3 class="text-center">List of Users</h3>
			<hr>
			<div class="container text-left">
				<a href="<%=request.getContextPath()%>/new" class="btn btn-success btn-dark">Add New User</a>
			</div>
			<br>
			
			<c:if test="${listUser.size() == 0}">
			<div class="d-flex justify-content-center align-items-center" style="height: 100%;">
			<h6>There is no user, add one.</h6>
			</div>
			</c:if>
			
			<c:if test="${listUser.size() > 0}">
			<table class="table table-bordered">
				<thead>
					<tr>
						<th>ID</th>
						<th>Name</th>
						<th>Email</th>
						<th>Country</th>
						<th>Actions</th>
					</tr>
				</thead>
				<tbody>

					<c:forEach var="user" items="${listUser}">
						<tr>
							<td><c:out value="${user.id}" /></td>
							<td><c:out value="${user.name}" /></td>
							<td><c:out value="${user.email}" /></td>
							<td><c:out value="${user.country}" /></td>
							<td><a href="edit?id=<c:out value='${user.id}' />">Edit</a>
								&nbsp;&nbsp;&nbsp;&nbsp; <a
								href="delete?id=<c:out value='${user.id}' />">Delete</a></td>
						</tr>
					</c:forEach>

				</tbody>
			</table>
			</c:if>
			
			
		</div>
	</div>
</body>

</html>
```

La pagina contiene le direttive principali affinché possiamo aggiungere codice java all’interno. Quello che ci torna utile è la direttiva che ci permette di utilizzare la libreria di java per i tag non standard HTML.

Un esempio è l’utilizzo del tag “c:forEach” con il quale possiamo iterare facilmente un oggetto.

In questa sessione è stato utilizzato per iterare tutti i possibili utenti del database.

La documentazione [qui](https://docs.oracle.com/javaee/5/jstl/1.1/docs/tlddocs/c/tld-summary.html).

Per ogni oggetto visualizzato vengono creati due bottoni: Edit - Delete.
Questi si comportato come il loro nome suggerisce dandoci la possibilità di editare o eliminare la riga selezionata.

In questo caso abbiamo aggiunto un’espressione dinamica all’attributo href del tag anchor.

Nel dettaglio: la parte iniziale è statica, quindi abbiamo “edit?” per editare, “delete?” per eliminare. Il punto di domanda separa la query che verrà fatta al database. Dopo la parte statica c’è quella dinamica definita da un’espressione all’interno del tag c:out (documentazione sopra).

Il funzionamento consiste nel avere un valore che cambia in base all’oggetto che vogliamo eliminare o editare. Possiamo raggiungere la proprietà che ci interessa nell’oggetto attraverso la dot notation.

Ad esempio: `"delete?id=<c:out value='${user.id}' />"` significa che quando clicchiamo su delete verrà attivato il metodo nel servlet il quale prenderà il parametro, l’id, e lo utilizzerà per prendere lo specifico oggetto nel database e eliminarlo.

Inoltre è presente il tag `<c:if>` il quale, come intuibile dal nome, ci permette di utilizzare il costrutto ‘if’ per far mostrare o meno una porzione di pagina. 
In questo caso le espressioni si riferiscono alla lunghezza della lista user, la quale se uguale a 0 mostra una scritta che descrive l’assenza di utenti. Al contrario, se il numero della lista è maggiore di zero, verrà mostrata la tabella con l’utente o i vari utenti.

---

`href="<%=request.getContextPath()%>/new"`

Con il metodo ‘.getContextPath()’ abbiamo la possibilità di stampare la porzione di url in modo dinamico così da evitare di scriverlo ogni volta ed evitare errori. 

La parte di stringa ‘/new’ è collegata al metodo nel UserServlet che permette di associare questa stringa ad un determinato metodo.

In questo caso, cliccando, saremo portati nella pagina di creazione del form.

Documentazione [request](https://docs.oracle.com/javaee/5/api/javax/servlet/http/HttpServletRequest.html#getServletPath()).

![https://i.stack.imgur.com/YAMU7.png](https://i.stack.imgur.com/YAMU7.png)

---

user-form.jsp - Form JSP

```java
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<html>

<head>
<title>Form</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css">
<link rel="icon" type="image/x-icon" href="https://img.icons8.com/ios/344/user--v1.png">
</head>

<body>

		<nav class="navbar navbar-expand-md navbar-dark"
			style="background-color: black">
			<ul class="navbar-nav">
				<li><a href="<%=request.getContextPath()%>/list"class="nav-link">Users</a></li>
			</ul>
		</nav>

<br>
	<div class="container col-md-5">
		<div class="card">
			<div class="card-body">
				<c:if test="${user != null}">
					<form action="update" method="post">
				</c:if>
				<c:if test="${user == null}">
					<form action="insert" method="post">
				</c:if>

			
					<h2>
						<c:if test="${user != null}">
                                    Edit User
                                </c:if>
						<c:if test="${user == null}">
                                    Add New User
                                </c:if>
					</h2>
		

				<c:if test="${user != null}">
					<input type="hidden" name="id" value="<c:out value='${user.id}' />" />
				</c:if>

					<fieldset class="form-group">
						<label>User Name</label> <input type="text"
							value="<c:out value='${user.name}' />" class="form-control"
							name="name" required="required">
					</fieldset>

					<fieldset class="form-group">
						<label>User Email</label> <input type="text"
							value="<c:out value='${user.email}' />" class="form-control"
							name="email">
					</fieldset>

					<fieldset class="form-group">
						<label>User Country</label> <input type="text"
							value="<c:out value='${user.country}' />" class="form-control"
							name="country">
					</fieldset>
				
				<button type="submit" class="btn btn-success btn-dark">Save</button>
				</form>
			</div>
		</div>
	</div>
</body>

</html>
```

La pagina di form si occupa della creazione di nuovi utenti o modifica. E’ presente il costrutto ‘if’ per determinare la presenza o meno di utenti.
Se sono presenti allora la pagina raccoglie l’oggetto dal server che bisogna modificare. I metodi che gestiscono i dati sono nel servlet e nella classe DAO.

Quindi, quando nella pagina principale si clicca su ‘update’, si viene trasportati nella pagina form nella quale sono presenti i valori nel campo. 
