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