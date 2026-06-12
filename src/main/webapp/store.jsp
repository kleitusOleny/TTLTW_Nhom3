<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Store</title>
    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
          integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A=="
          crossorigin="anonymous" referrerpolicy="no-referrer"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/store_style.css">
    <style>
        .price-slider-wrapper {
            width: 100%;
            padding: 10px 0;
            position: relative;
        }

        .slider-track-bg {
            width: 100%;
            height: 6px;
            background-color: #e0e0e0;
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            border-radius: 3px;
            z-index: 1;
        }

        .slider-track-progress {
            height: 6px;
            background-color: #8c3333;
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            z-index: 2;
            border-radius: 3px;
        }

        .range-input-container {
            position: relative;
            width: 100%;
        }

        .range-input-container input[type="range"] {
            position: absolute;
            width: 100%;
            top: -3px;
            left: 0;
            height: 6px;
            -webkit-appearance: none;
            background: none;
            pointer-events: none;
            z-index: 3;
        }

        .range-input-container input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            height: 20px;
            width: 20px;
            border-radius: 50%;
            background: #8c3333;
            cursor: pointer;
            pointer-events: auto;
            border: 2px solid #fff;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
        }

        .range-input-container input[type="range"]::-moz-range-thumb {
            height: 20px;
            width: 20px;
            border-radius: 50%;
            background: #8c3333;
            cursor: pointer;
            pointer-events: auto;
            border: 2px solid #fff;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.3);
        }

        .price-values {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            font-size: 15px;
            color: #333;
            font-weight: 500;
        }

        .product-actions {
            display: flex;
            gap: 8px;
            margin-top: 15px;
        }

        .product-actions .add-to-cart-btn,
        .product-actions .buy-now-btn {
            flex: 1 !important;
            display: inline-flex !important;
            align-items: center !important;
            justify-content: center !important;
            gap: 5px !important;
            height: 42px !important;
            padding: 0 8px !important;
            box-sizing: border-box !important;
            font-size: 13px !important;
            font-weight: 600 !important;
            line-height: 1 !important;
            text-transform: uppercase !important;
            text-decoration: none !important;
            border-radius: 5px !important;
            transition: all 0.3s ease !important;
            white-space: nowrap !important;
        }

        .product-actions .add-to-cart-btn {
            background-color: #222 !important;
            color: #fff !important;
            border: 2px solid #222 !important;
        }

        .product-actions .add-to-cart-btn:hover {
            background-color: #fff !important;
            color: #222 !important;
            border-color: #222 !important;
        }

        .product-actions .buy-now-btn {
            background-color: #8c3333 !important;
            color: #fff !important;
            border: 2px solid #8c3333 !important;
        }

        .product-actions .buy-now-btn:hover {
            background-color: #fff !important;
            color: #8c3333 !important;
            border-color: #8c3333 !important;
        }

        @media (max-width: 480px) {
            .product-actions {
                flex-direction: column;
            }
        }
    </style>
</head>

<body>

<%@ include file="components/header.jsp" %>
<main>
    <div class="content-container"
         style="display: grid; grid-template-columns: 280px 1fr; gap: 30px; align-items: start;">
        <aside class="filter-content">
            <h3 class="filter-title">Bộ Lọc Sản Phẩm</h3>
            <form action="filter" method="get">
                <c:if test="${param.promo == 'true' or promo == 'true'}">
                    <input type="hidden" name="promo" value="true">
                </c:if>
                <c:if test="${not empty searchKeyword}">
                    <input type="hidden" name="search" value="${searchKeyword}">
                </c:if>
                <c:if test="${not empty param.search}">
                    <input type="hidden" name="search" value="${param.search}">
                </c:if>
                <%-- 1. LỌC GIÁ --%>
                <fmt:formatNumber var="maxPriceInt" value="${maxPrice}"
                                  maxFractionDigits="0" groupingUsed="false"/>
                <div class="filter-widget">
                    <h4 class="widget-title">Lọc theo giá</h4>
                    <c:set var="minVal" value="0"/>
                    <c:set var="maxVal" value="${maxPriceInt}"/>

                    <c:if test="${not empty selectedPrices && selectedPrices.size() > 0}">
                        <c:set var="priceRange" value="${selectedPrices[0]}"/>
                        <c:set var="parts" value="${fn:split(priceRange, '-')}"/>
                        <c:if test="${fn:length(parts) == 2}">
                            <c:set var="minVal" value="${parts[0]}"/>
                            <c:set var="maxVal"
                                   value="${parts[1] == 'max' ? maxPriceInt : parts[1]}"/>
                        </c:if>
                    </c:if>

                    <div class="price-slider-wrapper">
                        <div class="slider-track-bg"></div>
                        <div class="slider-track-progress" id="visual-track"></div>
                        <div class="range-input-container">
                            <input type="range" id="input-min" min="0" max="${maxPriceInt}"
                                   step="10000" value="${minVal}">
                            <input type="range" id="input-max" min="0" max="${maxPriceInt}"
                                   step="10000" value="${maxVal}">
                        </div>

                        <input type="hidden" name="price" id="hidden-price-filter"
                               value="${minVal}-${maxVal}">
                    </div>

                    <div class="price-values">
                        <span id="min-price-display">0 ₫</span>
                        <span id="max-price-display">
                            <fmt:formatNumber value="${maxPrice}" type="number" maxFractionDigits="0"/>₫
                        </span>
                    </div>

                    <button type="submit" class="btn btn-primary"
                            style="width: 100%; margin-top: 10px;">Áp dụng
                    </button>
                </div>

                <%-- 2. DANH MỤC --%>
                <div class="filter-widget">
                    <h4 class="widget-title">Danh Mục</h4>
                    <ul class="filter-list">
                        <c:forEach var="c" items="${categories}">
                            <c:set var="cid" value="${c.id}"/>
                            <li>
                                <input type="checkbox" id="cat-${c.id}" name="category" value="${c.id}" ${fn:contains(selectedCategories,String.valueOf(cid)) ? 'checked' : '' }>
                                <label for="cat-${c.id}">${c.categoryName}</label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <%-- 3. LOẠI RƯỢU --%>
                <div class="filter-widget">
                    <h4 class="widget-title">Loại Rượu</h4>
                    <ul class="filter-list">
                        <c:forEach var="t" items="${types}">
                            <c:set var="tid" value="${t.id}"/>
                            <li>
                                <input type="checkbox" id="type-${t.id}" name="type" value="${t.id}" ${fn:contains(selectedTypes,String.valueOf(tid)) ? 'checked' : '' }>
                                <label for="type-${t.id}">${t.typeName}</label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <%-- 4. XUẤT XỨ --%>
                <div class="filter-widget">
                    <h4 class="widget-title">Xuất Xứ</h4>
                    <ul class="filter-list">
                        <c:forEach var="o" items="${origins}" varStatus="loop">
                            <li>
                                <input type="checkbox" id="origin-${loop.index}"
                                       name="origin" value="${o}"
                                    ${fn:contains(selectedOrigins, o) ? 'checked' : '' }>
                                <label for="origin-${loop.index}">${o}</label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <%-- 5. NHÀ SẢN XUẤT--%>
                <div class="filter-widget">
                    <h4 class="widget-title">Nhà sản xuất</h4>
                    <ul class="filter-list">
                        <c:forEach var="m" items="${manufacturers}">
                            <c:set var="mid" value="${m.id}"/>
                            <li>
                                <input type="checkbox" id="manu-${m.id}"
                                       name="manufacturer" value="${m.id}"
                                    ${fn:contains(selectedManufacturers,String.valueOf(mid)) ? 'checked' : '' }>
                                <label for="manu-${m.id}">${m.manufacturerName}</label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <%-- 6. DUNG TÍCH --%>
                <div class="filter-widget">
                    <h4 class="widget-title">Dung tích</h4>
                    <ul class="filter-list">
                        <c:forEach var="cap" items="${capacities}" varStatus="loop">
                            <li>
                                <input type="checkbox"
                                       id="cap-${loop.index}"
                                       name="capacity" value="${cap}"
                                    ${fn:contains(selectedCapacities, cap) ? 'checked' : '' }>

                                <label for="cap-${loop.index}">${cap}</label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <div class="filter-widget">
                    <h4 class="widget-title">Tags nổi bật</h4>
                    <ul class="filter-list">
                        <c:forEach var="tag" items="${tags}">
                            <c:set var="tagid" value="${tag.id}"/>
                            <li>
                                <input type="checkbox" id="tag-${tag.id}" name="tag" value="${tag.id}"
                                    ${fn:contains(selectedTags, String.valueOf(tagid)) ? 'checked': '' }>
                                <label for="tag-${tag.id}">${tag.tagName}</label>
                            </li>
                        </c:forEach>
                    </ul>
                </div>

                <button type="submit" class="btn btn-primary"
                        style="width: 100%; margin-top: 10px; border: #000000 2px solid ;">Áp dụng bộ lọc
                </button>

            </form>
        </aside>

        <div class="product-content">
            <div class="shop-content">
                <c:choose>
                    <c:when test="${not empty searchKeyword}">
                        <h3 class="type-wine">Kết quả tìm kiếm cho: "${searchKeyword}"</h3>
                        <p>Tìm thấy ${products.size()} sản phẩm</p>
                    </c:when>
                    <c:otherwise>
                        <h3 class="type-wine">Tất cả sản phẩm</h3>
                    </c:otherwise>
                </c:choose>

                <div class="display-container">
                    <p>Hiển thị kết quả 1-24 trong số</p>
                    <div class="display-mode-container">
                        <form action="${pageContext.request.contextPath}/filter" method="get" id="sortForm">

                            <c:forEach items="${param}" var="p">
                                <c:if test="${p.key != 'sort' && p.key != 'page'}">
                                    <input type="hidden" name="${p.key}" value="${fn:escapeXml(p.value)}">
                                </c:if>
                            </c:forEach>

                            <select id="view-mode" name="sort" onchange="this.form.submit()">
                                <option value="default" ${currentSort == 'default' ? 'selected' : ''}>Thứ tự mặc định</option>
                                <option value="price-asc" ${currentSort == 'price-asc' ? 'selected' : ''}>Giá: Thấp đến Cao</option>
                                <option value="price-desc" ${currentSort == 'price-desc' ? 'selected' : ''}>Giá: Cao đến Thấp</option>
                                <option value="rating" ${currentSort == 'rating' ? 'selected' : ''}>Đánh giá cao nhất</option>
                            </select>
                        </form>
                    </div>
                </div>
            </div>
            <div class="product-grid">

                <c:if test="${empty products}">
                    <p style="text-align: center; width: 100%;">Không tìm thấy sản phẩm nào phù
                        hợp.</p>
                </c:if>
                <c:forEach var="p" items="${products}">
                    <div class="product-card">
                        <div class="product-image" style="position: relative;">
                            <c:set var="isFavorited" value="false" />
                            <c:if test="${not empty userFavouritesList}">
                                <c:forEach var="item" items="${userFavouritesList}">
                                    <c:if test="${item.product_id == p.id}">
                                        <c:set var="isFavorited" value="true" />
                                    </c:if>
                                </c:forEach>
                            </c:if>
                            <form action="${pageContext.request.contextPath}/favorites" method="post" class="wishlist-form" onsubmit="toggleFavorite(event, this)">
                                <input type="hidden" name="action" value="${isFavorited ? 'remove' : 'add'}">
                                <input type="hidden" name="productId" value="${p.id}">
                                <button type="submit" class="wishlist-btn ${isFavorited ? 'active' : ''}"
                                        aria-label="${isFavorited ? 'Xóa khỏi yêu thích' : 'Thêm vào yêu thích'}">
                                    <i class="fa-${isFavorited ? 'solid' : 'regular'} fa-heart"></i>
                                </button>
                            </form>

                            <a href="detail?id=${p.id}" class="product-link">
                                <c:choose>
                                    <c:when test="${not empty p.imageUrl}">
                                        <img src="${p.imageUrl}" alt="${p.productName}">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://via.placeholder.com/300x400?text=Wine"
                                             alt="Chưa có ảnh">
                                    </c:otherwise>
                                </c:choose>
                            </a>

                            <!-- Discount badge -->
                            <c:if test="${p.discountedPrice < p.price}">
                                <c:set var="discountPercent"
                                       value="${((p.price - p.discountedPrice) / p.price) * 100}"/>
                                <div
                                        style="position: absolute; top: 10px; left: 10px; background: #dc3545; color: white; padding: 8px 12px; border-radius: 5px; font-weight: bold; font-size: 14px; z-index: 5; box-shadow: 0 2px 4px rgba(0,0,0,0.2);">
                                    -
                                    <fmt:formatNumber value="${discountPercent}"
                                                      maxFractionDigits="0"/>%
                                </div>
                            </c:if>
                        </div>
                        <div class="product-info">
                            <h3 class="product-name">
                                <a href="detail?id=${p.id}">${p.productName}</a>
                            </h3>

                            <div class="product-extra-details">
                                <ul>
                                    <li><strong>Xuất xứ:</strong> ${p.origin}</li>

                                    <li><strong>Loại:</strong> ${p.typeId}</li>

                                    <li><strong>Nồng độ:</strong> ${p.alcohol}%</li>
                                </ul>
                            </div>

                            <p class="product-producer">Nhà sản xuất: ${p.manufacturerId}</p>

                            <div class="product-rating">
                                <fmt:formatNumber var="roundedRating" value="${p.rating}"
                                                  maxFractionDigits="0"/>

                                <c:forEach begin="1" end="5" var="i">
                                    <c:choose>
                                        <c:when test="${i <= roundedRating}">
                                            <i class="fa-solid fa-star"
                                               style="color: #FFD700;"></i>
                                        </c:when>
                                        <c:otherwise>
                                            <i class="fa-regular fa-star"
                                               style="color: #ccc;"></i>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>

                                <span style="font-size: 12px; color: #666;">(${p.totalReviews})</span>
                            </div>

                            <p class="product-price">
                                <fmt:setLocale value="vi_VN"/>
                                <c:choose>
                                    <c:when test="${p.discountedPrice < p.price}">
                                        <span style="color: #8c3333; font-weight: bold; font-size: 1.1rem; margin-right: 8px;">
                                            <fmt:formatNumber value="${p.discountedPrice}" type="number" maxFractionDigits="0"/>₫
                                        </span>
                                        <span style="text-decoration: line-through; color: #999; font-size: 0.9rem;">
                                            <fmt:formatNumber value="${p.price}" type="number" maxFractionDigits="0"/>₫
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${p.price}" type="number"
                                                          maxFractionDigits="0"/>₫
                                    </c:otherwise>
                                </c:choose>
                            </p>

                            <div class="product-actions">
                                <a href="add-cart?productId=${p.id}&quantity=1"
                                   class="add-to-cart-btn"><i class="fa-solid fa-cart-plus"></i> Thêm giỏ</a>
                                <a href="add-cart?productId=${p.id}&quantity=1&redirect=checkout"
                                   class="buy-now-btn"><i class="fa-solid fa-bolt"></i> Mua ngay</a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
            <nav class="pagination-container" aria-label="Page navigation">

                <%-- Xác định đường dẫn gốc: store hay filter --%>
                <c:set var="baseUrl"
                       value="${requestScope['javax.servlet.forward.servlet_path'] == '/filter' ? 'filter' : 'store'}"/>

                <ul class="pagination">
                    <%-- Nút Previous --%>
                    <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                        <%-- Link: baseUrl + page mới + filterParams cũ --%>
                        <a class="page-link"
                           href="${baseUrl}?page=${currentPage - 1}${filterParams}"
                           aria-label="Previous">
                            <i class="fa-solid fa-angle-left"></i>
                        </a>
                    </li>

                    <%-- Các số trang --%>
                    <c:forEach begin="1" end="${totalPages}" var="i">
                        <li class="page-item ${currentPage == i ? 'active' : ''}">
                            <a class="page-link"
                               href="${baseUrl}?page=${i}${filterParams}">${i}</a>
                        </li>
                    </c:forEach>

                    <%-- Nút Next --%>
                    <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                        <a class="page-link"
                           href="${baseUrl}?page=${currentPage + 1}${filterParams}"
                           aria-label="Next">
                            <i class="fa-solid fa-angle-right"></i>
                        </a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</main>
<%@ include file="components/footer.jsp" %>
<script>
    document.addEventListener("DOMContentLoaded", function () {
        const rangeMin = document.getElementById("input-min");
        const rangeMax = document.getElementById("input-max");
        const visualTrack = document.getElementById("visual-track");
        const displayMin = document.getElementById("min-price-display");
        const displayMax = document.getElementById("max-price-display");
        const hiddenInput = document.getElementById("hidden-price-filter");

        const minLimit = 0;
        const maxLimit = parseInt(rangeMax.max);
        const gap = maxLimit / 20;// Khoảng cách tối thiểu giữa 2 nút

        function formatCurrency(value) {
            return new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(value);
        }

        function updateSlider() {
            let minVal = parseInt(rangeMin.value);
            let maxVal = parseInt(rangeMax.value);

            // Chặn không cho 2 nút kéo qua nhau
            if (maxVal - minVal < gap) {
                if (this === rangeMin) {
                    rangeMin.value = maxVal - gap;
                    minVal = maxVal - gap;
                } else {
                    rangeMax.value = minVal + gap;
                    maxVal = minVal + gap;
                }
            }

            // Tính toán % để vẽ thanh màu đỏ
            // Công thức: left = % của nút min, right = 100% - % của nút max
            let percentMin = (minVal / maxLimit) * 100;
            let percentMax = (maxVal / maxLimit) * 100;

            visualTrack.style.left = percentMin + "%";
            visualTrack.style.width = (percentMax - percentMin) + "%";

            // Hiển thị text
            displayMin.textContent = formatCurrency(minVal);
            displayMax.textContent = formatCurrency(maxVal);

            // Cập nhật input ẩn
            hiddenInput.value = minVal + "-" + maxVal;
        }

        rangeMin.addEventListener("input", updateSlider);
        rangeMax.addEventListener("input", updateSlider);

        updateSlider();
    });
</script>
<script>
    document.addEventListener("DOMContentLoaded", function () {

        const isLoggedIn = "${not empty sessionScope.user}" === "true";

        if (!isLoggedIn) {
            const guestFavorites = JSON.parse(localStorage.getItem('guestFavorites')) || [];
            document.querySelectorAll('.wishlist-form').forEach(form => {
                const productId = form.querySelector('input[name="productId"]').value;
                const button = form.querySelector('button');
                const icon = button.querySelector('i');

                if (guestFavorites.includes(productId)) {
                    button.classList.add('active');
                    icon.classList.remove('fa-regular');
                    icon.classList.add('fa-solid');
                }
            });
        }

        if (isLoggedIn) {
            const guestFavorites = JSON.parse(localStorage.getItem('guestFavorites')) || [];
            if (guestFavorites.length > 0) {
                console.log('Syncing guest favorites:', guestFavorites);
                fetch('favorites', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'X-Requested-With': 'XMLHttpRequest'
                    },
                    body: new URLSearchParams({
                        action: 'sync',
                        productIds: guestFavorites.join(',')
                    })
                })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 'success') {
                            console.log('Sync successful');
                            localStorage.removeItem('guestFavorites');
                        }
                    })
                    .catch(err => console.error('Sync failed:', err));
            }
        }
    });

    function toggleFavorite(event, form) {
        event.preventDefault();

        const isLoggedIn = "${not empty sessionScope.user}" === "true";
        const formData = new FormData(form);
        const productId = formData.get('productId');
        const button = form.querySelector('button');
        const icon = button.querySelector('i');
        const wasActive = button.classList.contains('active');

        button.classList.toggle('active');
        if (button.classList.contains('active')) {
            icon.classList.remove('fa-regular');
            icon.classList.add('fa-solid');
        } else {
            icon.classList.remove('fa-solid');
            icon.classList.add('fa-regular');
        }

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function showNotification(message, icon = 'info', requireLogin = false) {
            if (requireLogin) {
                Swal.fire({
                    title: 'Yêu cầu đăng nhập',
                    text: message,
                    icon: 'warning',
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

            // Handle Guest Mode (localStorage)
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

            // Handle Logged In Mode
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
                        // Revert UI on failure
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

        document.addEventListener('DOMContentLoaded', syncGuestFavorites);
    </script>
</body>

</html>