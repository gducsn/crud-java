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
						<label>User Email</label> <input type="text" value="<c:out value='${user.email}' />" class="form-control" name="email">
					</fieldset>

					<fieldset class="form-group">
						<label>User Country</label> 
						<input type="text" value="<c:out value='${user.country}' />" class="form-control" name="country">
					</fieldset>
				
				<button type="submit" class="btn btn-success btn-dark">Save</button>
				</form>
			</div>
		</div>
	</div>
</body>

</html>