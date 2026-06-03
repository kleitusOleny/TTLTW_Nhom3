<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>${product.productName} | Store</title>
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/detail_style.css?v=2">
                </head>

                <body>
                    <%@ include file="components/header.jsp" %>
                        <main>
                            <div class="product-detail-container">
                                <div class="detail-grid-container">
                                    <div class="product-gallery-column">
                                        <div class="main-image-container" style="position: relative;">
                                            <c:choose>
                                                <c:when test="${not empty product.imageUrl}">
                                                    <img src="${product.imageUrl}" alt="${product.productName}"
                                                        id="main-product-image">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="https://via.placeholder.com/300x400?text=Wine"
                                                        alt="Chưa có ảnh" id="main-product-image">
                                                </c:otherwise>
                                            </c:choose>

                                            <c:if test="${product.discountedPrice < product.price}">
                                                <c:set var="discountPercent"
                                                    value="${((product.price - product.discountedPrice) / product.price) * 100}" />
                                                <div
                                                    style="position: absolute; top: 10px; left: 10px; background: #dc3545; color: white; padding: 10px 20px; border-radius: 8px; font-weight: bold; font-size: 18px; box-shadow: 0 2px 5px rgba(0,0,0,0.2);">
                                                    -
                                                    <fmt:formatNumber value="${discountPercent}"
                                                        maxFractionDigits="0" />%
                                                </div>
                                            </c:if>

                                            <div id="lens" class="img-zoom-lens"></div>
                                            <c:set var="isFavorited" value="false" />
                                            <c:if test="${not empty userFavouritesList}">
                                                <c:forEach var="item" items="${userFavouritesList}">
                                                    <c:if test="${item.product_id == product.id}">
                                                        <c:set var="isFavorited" value="true" />
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                            <form action="${pageContext.request.contextPath}/favorites" method="post"
                                                class="wishlist-form" onsubmit="toggleFavorite(event, this)">
                                                <input type="hidden" name="action"
                                                    value="${isFavorited ? 'remove' : 'add'}">
                                                <input type="hidden" name="productId" value="${product.id}">
                                                <button type="submit"
                                                    class="wishlist-btn ${isFavorited ? 'active' : ''}"
                                                    aria-label="${isFavorited ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích'}">
                                                    <i class="fa-${isFavorited ? 'solid' : 'regular'} fa-heart"></i>
                                                </button>
                                            </form>
                                        </div>
                                        <div id="myresult" class="img-zoom-result"></div>
                                    </div>

                                    <div class="product-info-column">
                                        <div
                                            style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                                            <h1 class="product-detail-title">${product.productName}</h1>

                                        </div>

                                        <ul class="product-specs-list">
                                            <li><span>Xuất xứ:</span> <strong>${product.origin}</strong></li>
                                            <li><span>Loại rượu:</span> <strong>${product.typeId}</strong></li>
                                            <li><span>Nồng độ:</span> <strong>${product.alcohol}%</strong></li>
                                            <li><span>Dung tích:</span> <strong>${product.capacity}</strong></li>
                                            <li><span>Nhà sản xuất:</span> <strong>${product.manufacturerId}</strong>
                                            </li>
                                        </ul>

                                        <div class="product-detail-price" style="margin: 20px 0;">
                                            <c:choose>
                                                <c:when test="${product.discountedPrice < product.price}">
                                                    <span
                                                        style="color: #8c3333; font-size: 2rem; font-weight: bold; margin-right: 10px;">
                                                        <fmt:formatNumber value="${product.discountedPrice}"
                                                            type="number" maxFractionDigits="0" />₫
                                                    </span>
                                                    <span
                                                        style="text-decoration: line-through; color: #999; font-size: 1.2rem;">
                                                        <fmt:formatNumber value="${product.price}" type="number"
                                                            maxFractionDigits="0" />₫
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: #8c3333; font-size: 2rem; font-weight: bold;">
                                                        <fmt:formatNumber value="${product.price}" type="number"
                                                            maxFractionDigits="0" />₫
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="product-actions-container">
                                            <div class="quantity-selector">
                                                <button class="quantity-btn" id="decrease-qty">-</button>
                                                <input type="number" id="product-quantity" value="1" min="1">
                                                <button class="quantity-btn" id="increase-qty">+</button>
                                            </div>
                                            <a href="add-cart?productId=${product.id}&quantity=1" id="add-to-cart-link"
                                                class="btn btn-primary add-to-cart-detail">
                                                Thêm vào giỏ hàng
                                            </a>
                                        </div>

                                        <a href="add-cart?productId=${product.id}&quantity=1&redirect=checkout"
                                            id="buy-now-link" class="btn btn-secondary buy-now-detail">Mua ngay</a>

                                        <div class="product-meta">
                                            <div class="meta-item">
                                                <strong>Mã SP:</strong> <span>${product.id}</span>
                                            </div>
                                            <div class="meta-item">
                                                <strong>Danh mục:</strong> <span>${product.categoryId}</span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="product-service-column">
                                        <div class="service-widget">
                                            <h4 class="service-widget-title">Cần tư vấn?</h4>
                                            <p class="service-widget-text">Gọi ngay cho chúng tôi để được hỗ trợ nhanh
                                                nhất!
                                            </p>

                                            <a href="tel:012345678" class="service-contact-link">
                                                <i class="fa-solid fa-phone"></i>
                                                <span>037 420 5336</span>
                                            </a>

                                            <a href="#" class="service-contact-link"> <i
                                                    class="fa-solid fa-comment-dots"></i>
                                                <span>Tư vấn qua Zalo</span>
                                            </a>
                                        </div>

                                        <div class="service-widget">
                                            <h4 class="service-widget-title">Cam kết dịch vụ</h4>
                                            <ul class="service-list">
                                                <li>
                                                    <i class="fa-solid fa-truck-fast"></i>
                                                    <span>Giao hàng nhanh 2H tại TP.HCM.</span>
                                                </li>
                                                <li>
                                                    <i class="fa-solid fa-shield-halved"></i>
                                                    <span>Cam kết 100% sản phẩm chính hãng.</span>
                                                </li>
                                                <li>
                                                    <i class="fa-solid fa-box-open"></i>
                                                    <span>Đổi trả dễ dàng trong vòng 7 ngày.</span>
                                                </li>
                                                <li>
                                                    <i class="fa-solid fa-wine-glass"></i>
                                                    <span>Tư vấn & thử rượu miễn phí tại cửa hàng.</span>
                                                </li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="product-tabs-container">
                                <div class="tab-nav">
                                    <button class="tab-link active" data-tab="tab-description">Mô tả</button>
                                    <button class="tab-link" data-tab="tab-reviews">Đánh giá</button>
                                </div>
                                <div class="tab-content-container">
                                    <div class="tab-content active" id="tab-description">
                                        <h3>Chi tiết sản phẩm</h3>
                                        <p>
                                            <c:out value="${product.detail}" escapeXml="false"
                                                default="Đang cập nhật..." />
                                        </p>
                                    </div>

                                    <div class="tab-content" id="tab-reviews">
                                        <div class="review-actions-bar" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                                            <div class="review-filter-bar" style="background: #fffbf8; border: 1px solid #f9ede5; padding: 20px; border-radius: 2px; display: flex; align-items: center; gap: 15px; flex-wrap: wrap; flex: 1;">
                                                <span style="font-weight: bold; margin-right: 10px;">Lọc theo:</span>
                                                <button class="filter-btn active" data-star="all" onclick="filterReviews('all', this)"
                                                    style="padding: 5px 15px; border: 1px solid rgba(0,0,0,.09); background: #fff; cursor: pointer; border-radius: 2px;">
                                                    Tất cả (${totalReviews})
                                                </button>
                                                <button class="filter-btn" data-star="5" onclick="filterReviews(5, this)"
                                                    style="padding: 5px 15px; border: 1px solid rgba(0,0,0,.09); background: #fff; cursor: pointer; border-radius: 2px;">
                                                    5 Sao (${star5})
                                                </button>
                                                <button class="filter-btn" data-star="4" onclick="filterReviews(4, this)"
                                                    style="padding: 5px 15px; border: 1px solid rgba(0,0,0,.09); background: #fff; cursor: pointer; border-radius: 2px;">
                                                    4 Sao (${star4})
                                                </button>
                                                <button class="filter-btn" data-star="3" onclick="filterReviews(3, this)"
                                                    style="padding: 5px 15px; border: 1px solid rgba(0,0,0,.09); background: #fff; cursor: pointer; border-radius: 2px;">
                                                    3 Sao (${star3})
                                                </button>
                                                <button class="filter-btn" data-star="2" onclick="filterReviews(2, this)"
                                                    style="padding: 5px 15px; border: 1px solid rgba(0,0,0,.09); background: #fff; cursor: pointer; border-radius: 2px;">
                                                    2 Sao (${star2})
                                                </button>
                                                <button class="filter-btn" data-star="1" onclick="filterReviews(1, this)"
                                                    style="padding: 5px 15px; border: 1px solid rgba(0,0,0,.09); background: #fff; cursor: pointer; border-radius: 2px;">
                                                    1 Sao (${star1})
                                                </button>
                                            </div>
                                            <div class="review-sort-bar" style="margin-left: 20px;">
                                                <select id="review-sort-select" onchange="sortReviews(this.value)" style="padding: 10px; border: 1px solid #ddd; border-radius: 4px; outline: none;">
                                                    <option value="latest">Mới nhất</option>
                                                    <option value="highest">Đánh giá Cao nhất</option>
                                                    <option value="lowest">Đánh giá Thấp nhất</option>
                                                </select>
                                            </div>
                                        </div>

                                        <c:if test="${not empty reviews}">
                                            <div class="reviews-list">
                                                <c:forEach var="r" items="${reviews}">
                                                    <div class="review-item" data-star="${r.star}" data-timestamp="${r.createAtDate.time}"
                                                        style="display: flex; align-items: flex-start; padding: 20px 0; border-bottom: 1px solid rgba(0,0,0,.09);">
                                                        <div class="reviewer-avatar"
                                                            style="margin-right: 15px; width: 40px; text-align: center;">
                                                            <i class="fa-solid fa-circle-user"
                                                                style="font-size: 40px; color: #ccc;"></i>
                                                        </div>
                                                        <div class="review-body" style="flex: 1;">
                                                            <div class="reviewer-name"
                                                                style="font-size: 14px; font-weight: bold; color: #333; margin-bottom: 5px;">
                                                                ${r.userName}</div>

                                                            <div class="review-stars"
                                                                style="color: #ee4d2d; font-size: 10px; margin-bottom: 5px;">
                                                                <c:set var="starVal" value="${r.star}" />
                                                                <c:forEach begin="1" end="5" var="i">
                                                                    <c:choose>
                                                                        <c:when test="${i <= starVal}"><i
                                                                                class="fa-solid fa-star"></i></c:when>
                                                                        <c:when test="${i - 0.5 <= starVal}"><i
                                                                                class="fa-solid fa-star-half-stroke"></i>
                                                                        </c:when>
                                                                        <c:otherwise><i class="fa-regular fa-star"
                                                                                style="color: #ddd;"></i></c:otherwise>
                                                                    </c:choose>
                                                                </c:forEach>
                                                            </div>

                                                            <div class="review-meta"
                                                                style="color: rgba(0,0,0,.54); font-size: 12px; margin-bottom: 15px;">
                                                                <fmt:formatDate value="${r.createAtDate}"
                                                                    pattern="yyyy-MM-dd HH:mm" />
                                                            </div>

                                                            <div class="review-content"
                                                                style="font-size: 14px; color: rgba(0,0,0,.87); line-height: 1.4;">
                                                                <div>${r.content}</div>
                                                                <c:if test="${not empty r.imagePath}">
                                                                    <div class="review-image" style="margin-top: 15px;">
                                                                        <img src="${pageContext.request.contextPath}/${r.imagePath}" alt="Review image" style="max-width: 150px; max-height: 150px; border-radius: 4px; border: 1px solid #eee; object-fit: contain;">
                                                                    </div>
                                                                </c:if>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:if>

                                        <script>
                                            function filterReviews(star, btn) {
                                                // Update active button
                                                document.querySelectorAll('.filter-btn').forEach(b => {
                                                    b.style.borderColor = 'rgba(0,0,0,.09)';
                                                    b.style.color = '#333';
                                                    b.classList.remove('active');
                                                });
                                                btn.style.borderColor = '#ee4d2d';
                                                btn.style.color = '#ee4d2d';
                                                btn.classList.add('active');

                                                // Filter items
                                                const items = document.querySelectorAll('.review-item');
                                                items.forEach(item => {
                                                    const itemStar = parseFloat(item.getAttribute('data-star'));
                                                    if (star === 'all') {
                                                        item.style.display = 'flex';
                                                    } else {
                                                        if (Math.floor(itemStar) == star) {
                                                            item.style.display = 'flex';
                                                        } else {
                                                            item.style.display = 'none';
                                                        }
                                                    }
                                                });
                                            }

                                            function sortReviews(sortType) {
                                                const reviewsList = document.querySelector('.reviews-list');
                                                if (!reviewsList) return;
                                                const items = Array.from(reviewsList.querySelectorAll('.review-item'));

                                                items.sort((a, b) => {
                                                    if (sortType === 'highest') {
                                                        return parseFloat(b.getAttribute('data-star')) - parseFloat(a.getAttribute('data-star'));
                                                    } else if (sortType === 'lowest') {
                                                        return parseFloat(a.getAttribute('data-star')) - parseFloat(b.getAttribute('data-star'));
                                                    } else {
                                                        // latest
                                                        return parseInt(b.getAttribute('data-timestamp')) - parseInt(a.getAttribute('data-timestamp'));
                                                    }
                                                });

                                                items.forEach(item => reviewsList.appendChild(item));
                                            }
                                        </script>

                                                                                                                                                                <c:if
                                                                                                                                                                    test="${empty reviews}">
                                                                                                                                                                    <p
                                                                                                                                                                        style="text-align: center; color: #666; padding: 20px;">
                                                                                                                                                                        Hiện
                                                                                                                                                                        chưa
                                                                                                                                                                        có
                                                                                                                                                                        đánh
                                                                                                                                                                        giá
                                                                                                                                                                        nào
                                                                                                                                                                        cho
                                                                                                                                                                        sản
                                                                                                                                                                        phẩm
                                                                                                                                                                        này.
                                                                                                                                                                        Hãy
                                                                                                                                                                        là
                                                                                                                                                                        người
                                                                                                                                                                        đầu
                                                                                                                                                                        tiên
                                                                                                                                                                        đánh
                                                                                                                                                                        giá!
                                                                                                                                                                    </p>
                                                                                                                                                                </c:if>
                                    </div>
                                </div>
                            </div>

                            <section class="related-products-section">
                                <h2 class="section-title">Các Sản Phẩm Khác</h2>
                                <div
                                    style="display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 30px; padding-top: 5px;">
                                    <c:forEach var="r" items="${relatedProducts}">
                                        <div class="product-card">
                                            <div class="product-image" style="position: relative;">
                                                <c:set var="isRelFavorited" value="false" />
                                                <c:if test="${not empty userFavouritesList}">
                                                    <c:forEach var="item" items="${userFavouritesList}">
                                                        <c:if test="${item.product_id == r.id}">
                                                            <c:set var="isRelFavorited" value="true" />
                                                        </c:if>
                                                    </c:forEach>
                                                </c:if>
                                                <form action="${pageContext.request.contextPath}/favorites"
                                                    method="post" class="wishlist-form"
                                                    onsubmit="toggleFavorite(event, this)">
                                                    <input type="hidden" name="action"
                                                        value="${isRelFavorited ? 'remove' : 'add'}">
                                                    <input type="hidden" name="productId" value="${r.id}">
                                                    <button type="submit"
                                                        class="wishlist-btn ${isRelFavorited ? 'active' : ''}"
                                                        aria-label="Yêu thích">
                                                        <i
                                                            class="fa-${isRelFavorited ? 'solid' : 'regular'} fa-heart"></i>
                                                    </button>
                                                </form>
                                                <a href="${pageContext.request.contextPath}/detail?id=${r.id}">
                                                    <img src="${pageContext.request.contextPath}/${r.imageUrl}"
                                                        alt="${r.productName}">
                                                </a>
                                            </div>
                                            <div class="product-info">
                                                <h3 class="product-name"><a
                                                        href="${pageContext.request.contextPath}/detail?id=${r.id}">${r.productName}</a>
                                                </h3>
                                                <p class="product-price">
                                                    <fmt:formatNumber value="${r.price}" type="currency"
                                                        currencySymbol="₫" maxFractionDigits="0" />
                                                </p>
                                                <a href="${pageContext.request.contextPath}/cart?action=add&productId=${r.id}&quantity=1"
                                                    class="add-to-cart-btn">Thêm vào
                                                    giỏ</a>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </section>
                        </main>
                        <%@ include file="components/footer.jsp" %>
                            <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                            <script>
                                function showNotification(message, icon, isLoginRequired = false) {
                                    if (isLoginRequired) {
                                        Swal.fire({
                                            title: 'Cần đăng nhập',
                                            text: message,
                                            icon: 'info',
                                            showCancelButton: true,
                                            confirmButtonColor: '#8c3333',
                                            cancelButtonColor: '#6c757d',
                                            confirmButtonText: 'Đăng nhập ngay',
                                            cancelButtonText: 'Để sau'
                                        }).then((result) => {
                                            if (result.isConfirmed) {
                                                window.location.href = '${pageContext.request.contextPath}/login';
                                            }
                                        });
                                    } else {
                                        Swal.fire({
                                            toast: true,
                                            position: 'top-end',
                                            icon: icon,
                                            title: message,
                                            showConfirmButton: false,
                                            timer: 3000,
                                            timerProgressBar: true
                                        });
                                    }
                                }

                                function toggleFavorite(event, form) {
                                    event.preventDefault();

                                    const isLoggedIn = "${not empty sessionScope.user}" === "true";
                                    const formData = new FormData(form);
                                    const productId = formData.get('productId');
                                    const url = form.getAttribute('action');
                                    const button = form.querySelector('button');
                                    const icon = button.querySelector('i');
                                    const wasActive = button.classList.contains('active');

                                    if (!isLoggedIn) {
                                        let guestFavorites = JSON.parse(localStorage.getItem('guestFavorites')) || [];
                                        const actionInput = form.querySelector('input[name="action"]');
                                        if (wasActive) {
                                            guestFavorites = guestFavorites.filter(id => id !== productId);
                                            button.classList.remove('active');
                                            icon.classList.remove('fa-solid');
                                            icon.classList.add('fa-regular');
                                            if (actionInput) actionInput.value = 'add';
                                        } else {
                                            if (!guestFavorites.includes(productId)) {
                                                guestFavorites.push(productId);
                                            }
                                            button.classList.add('active');
                                            icon.classList.remove('fa-regular');
                                            icon.classList.add('fa-solid');
                                            if (actionInput) actionInput.value = 'remove';
                                        }
                                        localStorage.setItem('guestFavorites', JSON.stringify(guestFavorites));
                                        showNotification(wasActive ? 'Đã xóa khỏi danh sách yêu thích' : 'Đã thêm vào danh sách yêu thích', 'success');
                                        return;
                                    }

                                    const actionToSend = wasActive ? 'remove' : 'add';
                                    formData.set('action', actionToSend);

                                    button.classList.toggle('active');
                                    if (button.classList.contains('active')) {
                                        icon.classList.remove('fa-regular');
                                        icon.classList.add('fa-solid');
                                    } else {
                                        icon.classList.remove('fa-solid');
                                        icon.classList.add('fa-regular');
                                    }

                                    fetch(url, {
                                        method: 'POST',
                                        body: new URLSearchParams(formData),
                                        headers: {
                                            'X-Requested-With': 'XMLHttpRequest',
                                            'Content-Type': 'application/x-www-form-urlencoded'
                                        }
                                    })
                                        .then(response => {
                                            if (response.status === 401) {
                                                showNotification('Vui lòng đăng nhập để thực hiện', 'warning', true);
                                                return null;
                                            }
                                            return response.json();
                                        })
                                        .then(data => {
                                            if (data && data.status === 'success') {
                                                const actionInput = form.querySelector('input[name="action"]');
                                                if (actionInput) actionInput.value = (actionToSend === 'add' ? 'remove' : 'add');
                                                showNotification(data.message || (actionToSend === 'remove' ? 'Đã xóa khỏi yêu thích' : 'Đã thêm vào yêu thích'), 'success');
                                            } else if (data) {
                                                button.classList.toggle('active');
                                                if (button.classList.contains('active')) {
                                                    icon.classList.remove('fa-regular');
                                                    icon.classList.add('fa-solid');
                                                } else {
                                                    icon.classList.remove('fa-solid');
                                                    icon.classList.add('fa-regular');
                                                }
                                                showNotification(data.message || 'Có lỗi xảy ra', 'error');
                                            }
                                        })
                                        .catch(error => {
                                            console.error('Error:', error);
                                            button.classList.toggle('active');
                                            showNotification('Lỗi kết nối máy chủ', 'error');
                                        });
                                }

                                function syncGuestFavorites() {
                                    const isLoggedIn = "${not empty sessionScope.user}" === "true";
                                    if (isLoggedIn) {
                                        const guestFavorites = JSON.parse(localStorage.getItem('guestFavorites')) || [];
                                        if (guestFavorites.length > 0) {
                                            fetch('${pageContext.request.contextPath}/favorites', {
                                                method: 'POST',
                                                headers: {
                                                    'Content-Type': 'application/x-www-form-urlencoded',
                                                    'X-Requested-With': 'XMLHttpRequest'
                                                },
                                                body: new URLSearchParams({ action: 'sync', productIds: guestFavorites.join(',') })
                                            })
                                                .then(r => r.json())
                                                .then(data => { if (data.status === 'success') localStorage.removeItem('guestFavorites'); })
                                                .catch(err => console.error('Sync failed:', err));
                                        }
                                        return;
                                    }

                                    const guestFavorites = JSON.parse(localStorage.getItem('guestFavorites')) || [];
                                    document.querySelectorAll('.wishlist-form').forEach(form => {
                                        const productIdInput = form.querySelector('input[name="productId"]');
                                        if (!productIdInput) return;
                                        const productId = productIdInput.value;
                                        if (guestFavorites.includes(productId)) {
                                            const button = form.querySelector('button');
                                            const icon = button.querySelector('i');
                                            const actionInput = form.querySelector('input[name="action"]');
                                            button.classList.add('active');
                                            icon.classList.remove('fa-regular');
                                            icon.classList.add('fa-solid');
                                            if (actionInput) actionInput.value = 'remove';
                                        }
                                    });
                                }

                                document.addEventListener('DOMContentLoaded', function() {
                                    syncGuestFavorites();

                                    // Xử lý chuyển đổi Tab (Mô tả - Đánh giá)
                                    const tabLinks = document.querySelectorAll('.tab-link');
                                    const tabContents = document.querySelectorAll('.tab-content');

                                    tabLinks.forEach(link => {
                                        link.addEventListener('click', function() {
                                            // Xóa class active ở tất cả các tab
                                            tabLinks.forEach(t => t.classList.remove('active'));
                                            tabContents.forEach(c => c.classList.remove('active'));

                                            // Thêm class active vào tab được click
                                            this.classList.add('active');
                                            
                                            // Hiển thị nội dung tương ứng
                                            const targetId = this.getAttribute('data-tab');
                                            const targetElement = document.getElementById(targetId);
                                            if (targetElement) {
                                                targetElement.classList.add('active');
                                            }
                                        });
                                    });
                                });
                            </script>
                </body>

                </html>