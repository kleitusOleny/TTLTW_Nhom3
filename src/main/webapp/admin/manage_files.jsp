<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <title>Quản Lý File & Hình Ảnh</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/admin/admin_css/manage_reviews_style.css">
    <style>
        .file-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            padding: 20px 0;
        }
        .file-item {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 10px;
            text-align: center;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .file-item img {
            max-width: 100%;
            height: 150px;
            object-fit: cover;
            border-radius: 4px;
            margin-bottom: 10px;
        }
        .file-item p {
            margin: 5px 0;
            font-size: 13px;
            color: #555;
            word-wrap: break-word;
        }
        .btn-delete {
            background-color: #ff4d4f;
            color: white;
            border: none;
            padding: 5px 15px;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 10px;
        }
        .btn-delete:hover {
            background-color: #ff7875;
        }
    </style>
</head>

<body>
    <div class="dashboard-container">
        <nav class="dashboard-sidebar">
            <ul class="sidebar-items">
                <div class="group-avatar">
                    <%@ include file="/admin/components/avatar.jsp" %>
                        <%@ include file="/admin/components/notify_icon.jsp" %>
                </div>
                <c:set var="activePage" value="files" scope="request" />
                <%@ include file="/admin/components/sidebar_items_component.jsp" %>
            </ul>
            <div class="text">━ Được update tới 2025 ━</div>
        </nav>
        <div class="dashboard-content">
            <main class="dashboard-main-content">
                <div class="button-group" style="display: flex; flex-direction: column; align-items: flex-start; gap: 15px;">
                    <h2>Quản lí thư viện hình ảnh</h2>
                    <c:if test="${not empty sessionScope.successMsg}">
                        <div style="color: green;">${sessionScope.successMsg}</div>
                        <c:remove var="successMsg" scope="session"/>
                    </c:if>


                    <!-- Form upload -->
                    <div style="background: #f9f9f9; padding: 15px; border-radius: 8px; border: 1px solid #ddd; width: 100%;">
                        <form action="${pageContext.request.contextPath}/admin/manage-files" method="post" enctype="multipart/form-data" style="display: flex; align-items: center; gap: 15px;">
                            <input type="hidden" name="action" value="upload">
                            
                            <div>
                                <label for="folderSelect" style="font-weight: bold; margin-right: 5px;">Thư mục:</label>
                                <select id="folderSelect" name="folder" style="padding: 5px; border-radius: 4px;">
                                    <option value="reviews" ${currentFolder == 'reviews' ? 'selected' : ''}>reviews (Đánh giá)</option>
                                    <option value="products" ${currentFolder == 'products' ? 'selected' : ''}>products (Sản phẩm)</option>
                                    <option value="blogs" ${currentFolder == 'blogs' ? 'selected' : ''}>blogs (Bài viết)</option>
                                    <option value="avatars" ${currentFolder == 'avatars' ? 'selected' : ''}>avatars (Ảnh đại diện)</option>
                                </select>
                            </div>

                            <input type="file" name="image" required accept="image/*" style="padding: 5px;">
                            
                            <button type="submit" style="background: #1890ff; color: white; border: none; padding: 8px 15px; border-radius: 4px; cursor: pointer;">
                                <ion-icon name="cloud-upload-outline"></ion-icon> Tải lên
                            </button>
                        </form>
                    </div>

                    <!-- Lọc theo thư mục (Tabs) -->
                    <div style="display: flex; gap: 10px; margin-top: 10px;">
                        <strong>Đang xem: </strong>
                        <a href="${pageContext.request.contextPath}/admin/manage-files?folder=reviews" style="color: ${currentFolder == 'reviews' ? '#ee4d2d' : '#333'}; font-weight: ${currentFolder == 'reviews' ? 'bold' : 'normal'}; text-decoration: none;">/reviews</a> | 
                        <a href="${pageContext.request.contextPath}/admin/manage-files?folder=products" style="color: ${currentFolder == 'products' ? '#ee4d2d' : '#333'}; font-weight: ${currentFolder == 'products' ? 'bold' : 'normal'}; text-decoration: none;">/products</a> | 
                        <a href="${pageContext.request.contextPath}/admin/manage-files?folder=blogs" style="color: ${currentFolder == 'blogs' ? '#ee4d2d' : '#333'}; font-weight: ${currentFolder == 'blogs' ? 'bold' : 'normal'}; text-decoration: none;">/blogs</a> | 
                        <a href="${pageContext.request.contextPath}/admin/manage-files?folder=avatars" style="color: ${currentFolder == 'avatars' ? '#ee4d2d' : '#333'}; font-weight: ${currentFolder == 'avatars' ? 'bold' : 'normal'}; text-decoration: none;">/avatars</a>
                    </div>
                </div>
                <div class="file-grid">
                    <c:choose>
                        <c:when test="${not empty filesList}">
                            <c:forEach items="${filesList}" var="file">
                                <div class="file-item">
                                    <img src="${pageContext.request.contextPath}/${file.path}" alt="${file.name}">
                                    <p><strong>${file.name}</strong></p>
                                    <p>Dung lượng: ${file.size}</p>
                                    <form action="${pageContext.request.contextPath}/admin/manage-files" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn xóa file này không? File sẽ bị xóa vĩnh viễn khỏi server!');">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="folder" value="${currentFolder}">
                                        <input type="hidden" name="imagePath" value="${file.path}">
                                        <button type="submit" class="btn-delete">
                                            <ion-icon name="trash-outline"></ion-icon> Xóa
                                        </button>
                                    </form>
                                </div>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <p>Không có file nào trong thư mục.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
            </main>
        </div>
    </div>
    
    <!-- Scripts cho giao diện -->
    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
</body>

</html>
