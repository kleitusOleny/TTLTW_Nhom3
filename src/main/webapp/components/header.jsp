                                 <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<html>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/index_style.css">
<header class="site-header">
    <div class="header-top">
        <div class="container">
            <div class="header-logo">
                <a href="${pageContext.request.contextPath}/home" class="logo">LOGO</a>
            </div>

            <div class="header-center">
                <form class="search-form" action="${pageContext.request.contextPath}/filter" method="get">
                    <input type="text" name="search" placeholder="Tìm kiếm sản phẩm..."
                           value="${param.search}" required>

                    <c:forEach items="${paramValues}" var="p">
                        <c:if test="${p.key ne 'search' and p.key ne 'page'}">
                            <c:forEach items="${p.value}" var="val">
                                <input type="hidden" name="${p.key}" value="${val}">
                            </c:forEach>
                        </c:if>
                    </c:forEach>

                    <button type="submit" aria-label="Search">
                        <i class="fas fa-search"></i>
                    </button>
                </form>
            </div>

            <div class="header-right">
<%--                <c:if test="${not empty sessionScope.user}">--%>
<%--                    <c:if test="${sessionScope.user.administrator == 1}">--%>
<%--                        <a href="${pageContext.request.contextPath}/dashboard"--%>
<%--                           aria-label="Admin Dashboard"--%>
<%--                           title="Trang quản trị"--%>
<%--                           class="admin-nav-link"> <i class="fas fa-user-shield"></i>--%>
<%--                        </a>--%>
<%--                    </c:if>--%>
<%--                </c:if>--%>
                <c:if test="${empty sessionScope.user}">
                    <c:set var="reqUri" value="${requestScope['jakarta.servlet.forward.request_uri']}"/>
                    <c:if test="${empty reqUri}">
                        <c:set var="reqUri" value="${pageContext.request.requestURI}"/>
                    </c:if>
                    <c:set var="queryString" value="${pageContext.request.queryString}"/>
                    <c:set var="fullRedirectUrl" value="${reqUri}${not empty queryString ? '?' : ''}${queryString}"/>

                    <%-- Remove loginSuccess/registerSuccess from queryString if present --%>
                    <c:if test="${fn:contains(fullRedirectUrl, 'loginSuccess') or fn:contains(fullRedirectUrl, 'registerSuccess')}">
                        <c:url var="fullRedirectUrl" value="${reqUri}">
                            <c:forEach items="${param}" var="p">
                                <c:if test="${p.key != 'loginSuccess' and p.key != 'registerSuccess'}">
                                    <c:param name="${p.key}" value="${p.value}"/>
                                </c:if>
                            </c:forEach>
                        </c:url>
                    </c:if>

                    <%
                        String fullRedirectUrl = (String) pageContext.getAttribute("fullRedirectUrl");
                        if (fullRedirectUrl != null) {
                            // Ensure context path isn't doubled if c:url was used
                            String contextPath = request.getContextPath();
                            if (fullRedirectUrl.startsWith(contextPath + contextPath)) {
                                fullRedirectUrl = fullRedirectUrl.substring(contextPath.length());
                            }
                            pageContext.setAttribute("encodedRedirectUrl", java.net.URLEncoder.encode(fullRedirectUrl, "UTF-8"));
                        }
                    %>
                    <a href="${pageContext.request.contextPath}/login?redirect=${encodedRedirectUrl}" aria-label="Login">
                        <span style="text-decoration-color: red">Đăng nhập</span>
                    </a>
                </c:if>
                <c:if test="${not empty sessionScope.user}">
                    <a href="${pageContext.request.contextPath}/info_users/user_sidebar.jsp"
                       aria-label="Account" title="Thông tin tài khoản">
                        <i class="fas fa-user"></i>
                    </a>
                </c:if>
                <a href="${pageContext.request.contextPath}/my-cart" class="cart-link"
                   aria-label="Cart" title="Giỏ hàng">
                    <i class="fa-solid fa-cart-shopping"></i>
                    <span class="cart-count">${sessionScope.cart.totalQuantity}</span>
                </a>
            </div>
        </div>
    </div>
    <div class="header-nav-bar">
        <div class="container">
            <nav class="header-nav">
                <c:set var="uri" value="${pageContext.request.requestURI}"/>
                <c:set var="current" value="${requestScope.curHeader}"/>
                <ul>
                    <li>
                        <a href="${pageContext.request.contextPath}/home" class=${current.equals("home")
                                ? "active" : '' }>Trang
                            Chủ</a>
                    </li>

                    <li class="has-dropdown">
                        <a href="${pageContext.request.contextPath}/store" class="${current.equals("store") ? "active" : '' }">
                            Rượu Vang
                            <i class="fa-solid fa-caret-down"></i>
                        </a>
                        <div class="mega-menu">
                            <div class="mega-menu-grid">
                                <div class="mega-menu-column">
                                    <h4 class="mega-menu-title">Theo Loại Vang</h4>
                                    <ul class="mega-menu-list">
                                        <c:forEach items="${applicationScope.globalListTypes}" var="type">
                                            <li><a href="${pageContext.request.contextPath}/store?typeId=${type.id}"
                                                   class="mega-menu-link">${type.typeName}</a></li>
                                        </c:forEach>
                                    </ul>
                                </div>

                                <div class="mega-menu-column">
                                    <h4 class="mega-menu-title">Nhãn Hàng Nổi Bật</h4>
                                    <ul class="mega-menu-list">
                                        <c:forEach items="${applicationScope.globalListManufacturers}" var="m">
                                            <li><a href="${pageContext.request.contextPath}/store?manuId=${m.id}"
                                                   class="mega-menu-link">${m.manufacturerName}</a></li>
                                        </c:forEach>
                                    </ul>
                                </div>

                                <div class="mega-menu-column">
                                    <h4 class="mega-menu-title">Theo Tag</h4>
                                    <ul class="mega-menu-list">
                                        <c:forEach items="${applicationScope.globalListTags}" var="tag">
                                            <li><a href="${pageContext.request.contextPath}/store?tagId=${tag.id}"
                                                   class="mega-menu-link">${tag.tagName}</a></li>
                                        </c:forEach>
                                    </ul>
                                </div>

                                <div class="mega-menu-column">
                                    <h4 class="mega-menu-title">Theo Vùng Nổi Bật</h4>
                                    <ul class="mega-menu-list">
                                        <li><a href="#" class="mega-menu-link">Bordeaux (Pháp)</a>
                                        </li>
                                        <li><a href="#" class="mega-menu-link">Tuscany (Ý)</a></li>
                                        <li><a href="#" class="mega-menu-link">Napa Valley (Mỹ)</a>
                                        </li>
                                        <li><a href="#" class="mega-menu-link">Champagne (Pháp)</a>
                                        </li>
                                        <li><a href="#" class="mega-menu-link">Rioja (Tây Ban
                                            Nha)</a></li>
                                        <li><a href="#" class="mega-menu-link">Marlborough (New
                                            Zealand)</a></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </li>


                    <li>
                        <a href="<%= request.getContextPath() %>/blog"
                           class="${fn:contains(uri, 'blog') ? 'active' : ''}">Blog</a>
                    </li>

                    <li>
                        <a href="<%= request.getContextPath() %>/about_us.jsp"
                           class="${fn:contains(uri, 'about_us.jsp') ? 'active' : ''}">About Us</a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</header>
</html>
