<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
                <link rel="stylesheet" href="<%= request.getContextPath() %>/css/favorites_style.css">

                <div class="favorites-container">
                    <div class="favorites-header">
                        <h2><i class="fa-solid fa-heart"></i> Sản phẩm yêu thích của tôi</h2>
                        <span class="text-muted" id="favorites-count">${fn:length(favouritesList)} sản phẩm</span>
                    </div>

                    <c:choose>
                        <c:when test="${empty favouritesList}">
                            <div class="empty-favorites">
                                <i class="fa-regular fa-heart"></i>
                                <p>Danh sách yêu thích của bạn đang trống.</p>
                                <a href="${pageContext.request.contextPath}/store" class="btn-shop">Tiếp tục mua sắm</a>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="favorites-grid">
                                <c:forEach var="fav" items="${favouritesList}">
                                    <div class="product-card" id="fav-item-${fav.favourite_id}">
                                        <c:if test="${fav.discount_value != null}">
                                            <div class="discount-badge">
                                                <c:choose>
                                                    <c:when test="${fn:toUpperCase(fav.discount_type) == 'PERCENT'}">
                                                        -
                                                        <fmt:formatNumber value="${fav.discount_value}"
                                                            maxFractionDigits="0" />%
                                                    </c:when>
                                                    <c:otherwise>
                                                        Giảm
                                                        <fmt:formatNumber value="${fav.discount_value}"
                                                            maxFractionDigits="0" />₫
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:if>

                                        <button class="remove-fav-btn"
                                            onclick="removeFavorite('${fav.favourite_id}', '${fav.product_id}')"
                                            title="Xóa khỏi yêu thích">
                                            <i class="fa-solid fa-trash-can"></i>
                                        </button>

                                        <div class="product-image">
                                            <a href="${pageContext.request.contextPath}/detail?id=${fav.product_id}">
                                                <c:choose>
                                                    <c:when test="${not empty fav.image_url}">
                                                        <img src="${pageContext.request.contextPath}/${fav.image_url}"
                                                            alt="${fav.product_name}">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="https://via.placeholder.com/200x250?text=Wine"
                                                            alt="No image">
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                        </div>

                                        <div class="product-info">
                                            <h3 class="product-name">
                                                <a
                                                    href="${pageContext.request.contextPath}/detail?id=${fav.product_id}">${fav.product_name}</a>
                                            </h3>

                                            <div class="product-rating">
                                                <c:set var="rating" value="${fav.rating != null ? fav.rating : 0}" />
                                                <fmt:formatNumber var="roundedRating" value="${rating}"
                                                    maxFractionDigits="0" />
                                                <c:forEach begin="1" end="5" var="i">
                                                    <c:choose>
                                                        <c:when test="${i <= roundedRating}">
                                                            <i class="fa-solid fa-star"></i>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <i class="fa-regular fa-star"></i>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:forEach>
                                                <span
                                                    style="font-size: 12px; color: #999; margin-left: 5px;">(${fav.total_reviews
                                                    != null ? fav.total_reviews : 0})</span>
                                            </div>

                                            <div class="product-price">
                                                <c:set var="price" value="${fav.price}" />
                                                <c:set var="discountedPrice" value="${price}" />
                                                <c:if test="${fav.discount_value != null}">
                                                    <c:choose>
                                                        <c:when
                                                            test="${fn:toUpperCase(fav.discount_type) == 'PERCENT'}">
                                                            <c:set var="discountedPrice"
                                                                value="${price * (1 - fav.discount_value / 100.0)}" />
                                                        </c:when>
                                                        <c:when test="${fn:toUpperCase(fav.discount_type) == 'AMOUNT'}">
                                                            <c:set var="discountedPrice"
                                                                value="${price - fav.discount_value}" />
                                                        </c:when>
                                                    </c:choose>
                                                </c:if>

                                                <fmt:setLocale value="vi_VN" />
                                                <fmt:formatNumber value="${discountedPrice}" type="number"
                                                    maxFractionDigits="0" />₫
                                                <c:if test="${discountedPrice < price}">
                                                    <span class="old-price">
                                                        <fmt:formatNumber value="${price}" type="number"
                                                            maxFractionDigits="0" />₫
                                                    </span>
                                                </c:if>
                                            </div>

                                            <a href="${pageContext.request.contextPath}/add-cart?productId=${fav.product_id}&quantity=1"
                                                class="add-to-cart-mini">
                                                <i class="fa-solid fa-cart-shopping me-1"></i> Thêm vào giỏ
                                            </a>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- SweetAlert2 -->
                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

                <script>
                    function removeFavorite(favouriteId, productId) {
                        Swal.fire({
                            title: 'Xác nhận xóa?',
                            text: "Bạn có chắc chắn muốn xóa sản phẩm này khỏi danh sách yêu thích?",
                            icon: 'warning',
                            showCancelButton: true,
                            confirmButtonColor: '#8c3333',
                            cancelButtonColor: '#6c757d',
                            confirmButtonText: 'Đồng ý',
                            cancelButtonText: 'Hủy bỏ',
                            reverseButtons: true,
                            background: '#fff',
                            borderRadius: '12px'
                        }).then((result) => {
                            if (result.isConfirmed) {
                                const formData = new URLSearchParams();
                                formData.append('action', 'remove');
                                formData.append('favouriteId', favouriteId);
                                formData.append('productId', productId);

                                fetch('${pageContext.request.contextPath}/favorites', {
                                    method: 'POST',
                                    body: formData,
                                    headers: {
                                        'X-Requested-With': 'XMLHttpRequest',
                                        'Content-Type': 'application/x-www-form-urlencoded'
                                    }
                                })
                                    .then(response => response.json())
                                    .then(data => {
                                        if (data.status === 'success') {
                                            const item = document.getElementById('fav-item-' + favouriteId);
                                            if (item) {
                                                item.style.opacity = '0';
                                                item.style.transform = 'scale(0.8)';
                                                setTimeout(() => {
                                                    item.remove();
                                                    
                                                    // Update count
                                                    const countSpan = document.getElementById('favorites-count');
                                                    const sidebarCountBadge = document.getElementById('sidebar-fav-count');
                                                    const currentCount = document.querySelectorAll('.product-card').length;
                                                    
                                                    if (countSpan) {
                                                        countSpan.textContent = currentCount + ' sản phẩm';
                                                    }
                                                    
                                                    if (sidebarCountBadge) {
                                                        sidebarCountBadge.textContent = currentCount;
                                                        if (currentCount <= 0) {
                                                            sidebarCountBadge.style.display = 'none';
                                                        } else {
                                                            sidebarCountBadge.style.display = 'inline-block';
                                                        }
                                                    }

                                                    Swal.fire({
                                                        icon: 'success',
                                                        title: 'Đã xóa!',
                                                        text: 'Sản phẩm đã được xóa khỏi danh sách yêu thích.',
                                                        showConfirmButton: false,
                                                        timer: 1500,
                                                        background: '#fff',
                                                        borderRadius: '12px'
                                                    });

                                                    // Check if empty
                                                    if (document.querySelectorAll('.product-card').length === 0) {
                                                        setTimeout(() => location.reload(), 1500);
                                                    }
                                                }, 300);
                                            }
                                        } else {
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Lỗi',
                                                text: 'Có lỗi xảy ra khi xóa sản phẩm.',
                                                background: '#fff',
                                                borderRadius: '12px'
                                            });
                                        }
                                    })
                                    .catch(error => {
                                        console.error('Error:', error);
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Lỗi hệ thống',
                                            text: 'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
                                            background: '#fff',
                                            borderRadius: '12px'
                                        });
                                    });
                            }
                        });
                    }
                </script>