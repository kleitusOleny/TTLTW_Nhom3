<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>Tạo Đơn Hàng Mới</title>
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/admin/admin_css/manage_promotion_style.css">
                    <link rel="stylesheet"
                        href="${pageContext.request.contextPath}/admin/admin_css/create_order_style.css">
                </head>

                <body>
                    <div class="dashboard-container">
                        <nav class="dashboard-sidebar">
                            <ul class="sidebar-items">
                                <div class="group-avatar">
                                    <img src="${pageContext.request.contextPath}/assets/avatar.jpg" class="user-avatar"
                                        id="avatar-modal-btn" />
                                    <ion-icon name="notifications-outline" class="icon-header"
                                        id="notification-modal-btn"></ion-icon>
                                </div>
                                <li><a href="${pageContext.request.contextPath}/dashboard" class="a-with-icon">
                                        <ion-icon name="home-outline"></ion-icon>
                                        Trang Chủ</a></li>
                                <li><a href="${pageContext.request.contextPath}/product-manager" class="a-with-icon">
                                        <ion-icon name="bag-remove-outline"></ion-icon>
                                        Quản Lí Sản Phẩm</a></li>
                                <li><a href="${pageContext.request.contextPath}/accountmanager" class="a-with-icon">
                                        <ion-icon name="people-outline"></ion-icon>
                                        Quản Lí Tài Khoản Khách</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin/manage-orders"
                                        class="a-with-icon selected">
                                        <ion-icon name="cart"></ion-icon>
                                        Quản Lí Đơn Hàng</a></li>
                                <li><a href="${pageContext.request.contextPath}/banner-manager" class="a-with-icon">
                                        <ion-icon name="albums-outline"></ion-icon>
                                        Quản Lí Banner</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin/manage-blog" class="a-with-icon">
                                        <ion-icon name="reader-outline"></ion-icon>
                                        Quản Lí Blog và Tin Tức</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin/manage-promotions"
                                        class="a-with-icon">
                                        <ion-icon name="ticket-outline"></ion-icon>
                                        Quản Lí Mã Giảm Giá</a></li>
                                <li><a href="${pageContext.request.contextPath}/admin/manage-reviews"
                                        class="a-with-icon">
                                        <ion-icon name="star-outline"></ion-icon>
                                        Quản Lí Đánh Giá</a></li>
                                <li><a href="charts.jsp" class="a-with-icon">
                                        <ion-icon name="stats-chart-outline"></ion-icon>
                                        Thống Kê</a></li>
                            </ul>
                            <div class="text">━ Được update tới 2025 ━</div>
                        </nav>

                        <div class="dashboard-content">
                            <main class="dashboard-main-content">
                                <!-- Header -->
                                <div class="page-header-box">
                                    <div class="header-left">
                                        <h2>Tạo Đơn Hàng Mới</h2>
                                        <p class="subtitle">Chọn sản phẩm và nhập thông tin khách hàng để tạo đơn</p>
                                    </div>
                                    <div class="header-right">
                                        <a href="${pageContext.request.contextPath}/admin/manage-orders"
                                            class="btn-back">
                                            <ion-icon name="arrow-back-outline"></ion-icon>
                                            Quay lại danh sách
                                        </a>
                                    </div>
                                </div>

                                <c:if test="${not empty sessionScope.errorMessage}">
                                    <div class="alert alert-error"
                                        style="background: #f8d7da; color: #721c24; padding: 12px 20px; border-radius: 8px; margin-bottom: 15px; display: flex; align-items: center; gap: 10px;">
                                        <ion-icon name="alert-circle-outline"></ion-icon>
                                        ${sessionScope.errorMessage}
                                    </div>
                                    <c:remove var="errorMessage" scope="session" />
                                </c:if>

                                <div class="order-layout">
                                    <!-- Cột trái: Danh sách sản phẩm -->
                                    <div class="products-section">
                                        <div class="section-card">
                                            <div class="section-header">
                                                <h3><ion-icon name="wine-outline"></ion-icon> Danh sách sản phẩm</h3>
                                            </div>

                                            <!-- Form tìm kiếm -->
                                            <form method="get"
                                                action="${pageContext.request.contextPath}/admin/create-order"
                                                class="search-filter-form">
                                                <div class="search-box">
                                                    <ion-icon name="search-outline"></ion-icon>
                                                    <input type="text" name="keyword"
                                                        placeholder="Tìm theo tên, mã sản phẩm..." value="${keyword}">
                                                    <button type="submit" class="btn-search">Tìm kiếm</button>
                                                </div>
                                                <div class="filter-tabs">
                                                    <a href="${pageContext.request.contextPath}/admin/create-order?filterType=all"
                                                        class="filter-tab ${filterType == 'all' || filterType == null ? 'active' : ''}">Tất
                                                        cả</a>
                                                    <a href="${pageContext.request.contextPath}/admin/create-order?filterType=đỏ"
                                                        class="filter-tab ${filterType == 'đỏ' ? 'active' : ''}">Vang
                                                        đỏ</a>
                                                    <a href="${pageContext.request.contextPath}/admin/create-order?filterType=trắng"
                                                        class="filter-tab ${filterType == 'trắng' ? 'active' : ''}">Vang
                                                        trắng</a>
                                                    <a href="${pageContext.request.contextPath}/admin/create-order?filterType=hồng"
                                                        class="filter-tab ${filterType == 'hồng' ? 'active' : ''}">Vang
                                                        hồng</a>
                                                    <a href="${pageContext.request.contextPath}/admin/create-order?filterType=sủi"
                                                        class="filter-tab ${filterType == 'sủi' ? 'active' : ''}">Sparkling</a>
                                                </div>
                                            </form>

                                            <!-- Grid sản phẩm -->
                                            <div class="products-grid">
                                                <c:choose>
                                                    <c:when test="${empty products}">
                                                        <div class="empty-state">
                                                            <ion-icon name="cube-outline"></ion-icon>
                                                            <p>Không tìm thấy sản phẩm nào</p>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <c:forEach items="${products}" var="p">
                                                            <div class="product-card" data-id="${p.id}"
                                                                data-name="${p.productName}" data-price="${p.price}"
                                                                data-image="${p.imageUrl}" data-stock="${p.quantity}">
                                                                <div class="product-image">
                                                                    <c:choose>
                                                                        <c:when test="${not empty p.imageUrl}">
                                                                            <img src="${pageContext.request.contextPath}/${p.imageUrl}"
                                                                                alt="${p.productName}">
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <img src="${pageContext.request.contextPath}/assets/images/no-image.png"
                                                                                alt="No image">
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                    <c:if test="${not empty p.origin}">
                                                                        <span class="origin-badge">${p.origin}</span>
                                                                    </c:if>
                                                                </div>
                                                                <div class="product-info">
                                                                    <h4 class="product-name">${p.productName}</h4>
                                                                    <p class="product-sku">Mã: ${p.id}</p>
                                                                    <div class="product-footer">
                                                                        <div class="price-stock">
                                                                            <span class="price">
                                                                                <fmt:formatNumber value="${p.price}"
                                                                                    type="currency" currencySymbol=""
                                                                                    maxFractionDigits="0" />đ
                                                                            </span>
                                                                            <span class="stock">Còn ${p.quantity}
                                                                                chai</span>
                                                                        </div>
                                                                        <button type="button"
                                                                            class="btn-add add-to-cart-btn"
                                                                            data-product-id="${p.id}"
                                                                            data-product-name="${fn:escapeXml(p.productName)}"
                                                                            data-product-price="${p.price}"
                                                                            data-product-image="${p.imageUrl}"
                                                                            data-product-stock="${p.quantity}">
                                                                            <ion-icon name="add-outline"></ion-icon>
                                                                        </button>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </c:forEach>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Cột phải: Giỏ hàng và thông tin khách -->
                                    <div class="order-sidebar">
                                        <!-- Giỏ hàng -->
                                        <div class="section-card cart-section">
                                            <div class="section-header">
                                                <h3><ion-icon name="cart-outline"></ion-icon> Giỏ hàng</h3>
                                                <span class="cart-count" id="cartCount">0 sản phẩm</span>
                                            </div>
                                            <div class="cart-items" id="cartItems">
                                                <div class="empty-cart">
                                                    <ion-icon name="bag-outline"></ion-icon>
                                                    <p>Chưa có sản phẩm nào</p>
                                                </div>
                                            </div>
                                            <div class="cart-summary">
                                                <div class="summary-row">
                                                    <span>Tạm tính:</span>
                                                    <strong id="subTotal">0đ</strong>
                                                </div>
                                                <div class="summary-row">
                                                    <span>Phí vận chuyển:</span>
                                                    <strong id="shippingFee">0đ</strong>
                                                </div>
                                                <div class="summary-row total">
                                                    <span>Tổng cộng:</span>
                                                    <strong id="grandTotal">0đ</strong>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Form đặt hàng -->
                                        <form id="orderForm"
                                            action="${pageContext.request.contextPath}/admin/submit-order"
                                            method="post">
                                            <input type="hidden" name="cartData" id="cartDataInput">

                                            <!-- Thông tin khách hàng -->
                                            <div class="section-card">
                                                <div class="section-header">
                                                    <h3><ion-icon name="person-outline"></ion-icon> Thông tin khách hàng
                                                    </h3>
                                                </div>
                                                <div class="form-group">
                                                    <label>Họ và tên <span class="required">*</span></label>
                                                    <input type="text" name="customerName" id="customerName" required
                                                        placeholder="Nguyễn Văn A" value="${fullName != null ? fullName : ''}">
                                                </div>
                                                <div class="form-row">
                                                    <div class="form-group">
                                                        <label>Số điện thoại <span class="required">*</span></label>
                                                        <input type="tel" name="customerPhone" id="customerPhone"
                                                            required placeholder="0909 123 456" value="${phone != null ? phone : ''}">
                                                    </div>
                                                    <div class="form-group">
                                                        <label>Email</label>
                                                        <input type="email" name="customerEmail" id="customerEmail"
                                                            placeholder="email@example.com" value="${email != null ? email : ''}">
                                                    </div>
                                                </div>
                                                <div class="form-group">
                                                    <label>Địa chỉ giao hàng <span class="required">*</span></label>
                                                    <textarea name="customerAddress" id="customerAddress" rows="2"
                                                        required
                                                        placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành phố"></textarea>
                                                </div>
                                                <div class="form-group">
                                                    <label>Ghi chú</label>
                                                    <textarea name="orderNote" id="orderNote" rows="2"
                                                        placeholder="Ghi chú cho đơn hàng (tùy chọn)"></textarea>
                                                </div>
                                                <input type="hidden" name="verifiedUserId" id="verifiedUserId" value="${userId != null ? userId : ''}">
                                                <div style="margin-top:10px;">
                                                    <button type="button" id="verifyUserBtn" onclick="verifyUser()"
                                                        style="padding:8px 18px;background:#0872fa;color:#fff;border:none;border-radius:6px;cursor:pointer;font-weight:bold;font-size:13px;">
                                                        <ion-icon name="shield-checkmark-outline"></ion-icon> Xác minh người dùng
                                                    </button>
                                                    
                                                    <c:if test="${found != null}">
                                                        <c:choose>
                                                            <c:when test="${found}">
                                                                <div id="verifyResult" style="margin-top:10px;padding:12px;border-radius:8px;font-size:14px;background-color:#d4edda;border:1px solid #28a745;color:#155724;">
                                                                    <strong>Đã xác minh!</strong> Người dùng: <strong>${fullName}</strong> (ID: ${userId})<br/>Email: ${email} | SĐT: ${phone}
                                                                </div>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <div id="verifyResult" style="margin-top:10px;padding:12px;border-radius:8px;font-size:14px;background-color:#fff3cd;border:1px solid #ffc107;color:#856404;">
                                                                    <strong>Không tìm thấy.</strong> ${message}
                                                                </div>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                    <c:if test="${found == null}">
                                                        <div id="verifyResult" style="margin-top:10px;display:none;padding:12px;border-radius:8px;font-size:14px;"></div>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <div class="section-card">
                                                <div class="section-header">
                                                    <h3><ion-icon name="wallet-outline"></ion-icon> Phương thức thanh
                                                        toán</h3>
                                                </div>
                                                <div class="payment-options">
                                                    <label class="payment-option">
                                                        <input type="radio" name="paymentMethod" value="COD" checked>
                                                        <div class="option-content">
                                                            <ion-icon name="cash-outline"></ion-icon>
                                                            <div>
                                                                <strong>Thanh toán khi nhận hàng (COD)</strong>
                                                                <p>Khách hàng thanh toán khi nhận được hàng</p>
                                                            </div>
                                                        </div>
                                                    </label>
                                                    <label class="payment-option">
                                                        <input type="radio" name="paymentMethod" value="VNPay">
                                                        <div class="option-content">
                                                            <ion-icon name="card-outline"></ion-icon>
                                                            <div>
                                                                <strong>VNPay</strong>
                                                                <p>Thanh toán qua cổng VNPay</p>
                                                            </div>
                                                        </div>
                                                    </label>
                                                </div>
                                            </div>

                                            <!-- Nút submit -->
                                            <div class="submit-section">
                                                <button type="submit" class="btn-submit" id="submitBtn" disabled>
                                                    <ion-icon name="checkmark-circle-outline"></ion-icon>
                                                    <span>Tạo đơn hàng</span>
                                                    <strong id="submitTotal">0đ</strong>
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </main>
                        </div>
                    </div>

                    <script type="module" src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.esm.js"></script>
                    <script nomodule src="https://unpkg.com/ionicons@7.1.0/dist/ionicons/ionicons.js"></script>
                    <script src="${pageContext.request.contextPath}/popup.js"></script>
                    <script>
                        // Chờ DOM load xong
                        document.addEventListener('DOMContentLoaded', function () {
                            // Giỏ hàng
                            const contextPath = '${pageContext.request.contextPath}';
                            const cart = new Map();

                            // Format tiền
                            function formatMoney(value) {
                                return new Intl.NumberFormat('vi-VN').format(value) + 'đ';
                            }

                            // Thêm vào giỏ
                            window.addToCart = function (id, name, price, image, stock) {
                                console.log('Adding to cart:', id, name, price, image, stock);
                                const normalizedPrice = Number(price) || 0;
                                const normalizedStock = Number(stock);

                                let item = cart.get(id);
                                if (!item) {
                                    item = {
                                        id: id,
                                        name: name,
                                        price: normalizedPrice,
                                        image: image || '',
                                        stock: isNaN(normalizedStock) ? 9999 : normalizedStock,
                                        quantity: 0
                                    };
                                }

                                if (item.stock && item.quantity >= item.stock) {
                                    alert('Đã đạt số lượng tối đa trong kho!');
                                    return;
                                }

                                item.quantity++;
                                cart.set(id, item);
                                renderCart();
                                console.log('Cart updated:', cart);
                            };

                            // Cập nhật số lượng
                            window.updateQty = function (id, delta) {
                                const item = cart.get(id);
                                if (!item) return;

                                item.quantity += delta;
                                if (item.quantity <= 0) {
                                    cart.delete(id);
                                } else if (item.stock && item.quantity > item.stock) {
                                    item.quantity = item.stock;
                                }
                                renderCart();
                            };

                            // Xóa khỏi giỏ
                            window.removeFromCart = function (id) {
                                cart.delete(id);
                                renderCart();
                            };

                            // Render giỏ hàng
                            function renderCart() {
                                const cartItems = document.getElementById('cartItems');
                                const cartCount = document.getElementById('cartCount');
                                const subTotal = document.getElementById('subTotal');
                                const grandTotal = document.getElementById('grandTotal');
                                const submitTotal = document.getElementById('submitTotal');
                                const submitBtn = document.getElementById('submitBtn');
                                const cartDataInput = document.getElementById('cartDataInput');

                                if (cart.size === 0) {
                                    cartItems.innerHTML = '<div class="empty-cart"><ion-icon name="bag-outline"></ion-icon><p>Chưa có sản phẩm nào</p></div>';
                                    cartCount.textContent = '0 sản phẩm';
                                    subTotal.textContent = '0đ';
                                    grandTotal.textContent = '0đ';
                                    submitTotal.textContent = '0đ';
                                    submitBtn.disabled = true;
                                    cartDataInput.value = '';
                                    return;
                                }

                                let html = '';
                                let total = 0;
                                let itemCount = 0;

                                cart.forEach((item) => {
                                    const lineTotal = item.price * item.quantity;
                                    total += lineTotal;
                                    itemCount += item.quantity;

                                    let resolvedImage = contextPath + '/assets/images/no-image.png';
                                    if (item.image && item.image.trim() !== '' && item.image !== 'null') {
                                        resolvedImage = item.image.startsWith('/')
                                            ? contextPath + item.image
                                            : contextPath + '/' + item.image;
                                    }

                                    html +=
                                        '<div class="cart-item">' +
                                        '<div class="item-image">' +
                                        '<img src="' + resolvedImage + '" alt="' + item.name + '">' +
                                        '</div>' +
                                        '<div class="item-details">' +
                                        '<h4>' + item.name + '</h4>' +
                                        '<p class="item-price">' + formatMoney(item.price) + '</p>' +
                                        '</div>' +
                                        '<div class="item-qty">' +
                                        '<button type="button" onclick="updateQty(\'' + item.id + '\', -1)">-</button>' +
                                        '<span>' + item.quantity + '</span>' +
                                        '<button type="button" onclick="updateQty(\'' + item.id + '\', 1)">+</button>' +
                                        '</div>' +
                                        '<div class="item-total">' +
                                        '<strong>' + formatMoney(lineTotal) + '</strong>' +
                                        '<button type="button" class="btn-remove" onclick="removeFromCart(\'' + item.id + '\')">' +
                                        '<ion-icon name="trash-outline"></ion-icon>' +
                                        '</button>' +
                                        '</div>' +
                                        '</div>';
                                });

                                cartItems.innerHTML = html;
                                cartCount.textContent = itemCount + ' sản phẩm';
                                subTotal.textContent = formatMoney(total);
                                grandTotal.textContent = formatMoney(total);
                                submitTotal.textContent = formatMoney(total);
                                submitBtn.disabled = false;

                                // Lưu dữ liệu giỏ hàng vào hidden input
                                const cartArray = Array.from(cart.values()).map(item => ({
                                    productId: item.id,
                                    quantity: item.quantity,
                                    unitPrice: item.price
                                }));
                                cartDataInput.value = JSON.stringify(cartArray);
                            }

                            // Gắn sự kiện cho các nút thêm sản phẩm
                            document.querySelectorAll('.add-to-cart-btn').forEach(function (button) {
                                button.addEventListener('click', function (e) {
                                    e.preventDefault();
                                    e.stopPropagation();

                                    const productId = this.getAttribute('data-product-id');
                                    const productName = this.getAttribute('data-product-name');
                                    const productPrice = this.getAttribute('data-product-price');
                                    const productImage = this.getAttribute('data-product-image');
                                    const productStock = this.getAttribute('data-product-stock');

                                    console.log('Button clicked:', productId, productName, productPrice);
                                    addToCart(productId, productName, productPrice, productImage, productStock);
                                });
                            });

                            // Validate form trước khi submit
                            document.getElementById('orderForm').addEventListener('submit', function (e) {
                                if (cart.size === 0) {
                                    e.preventDefault();
                                    alert('Vui lòng thêm ít nhất một sản phẩm vào giỏ hàng!');
                                    return false;
                                }

                                const name = document.getElementById('customerName').value.trim();
                                const phone = document.getElementById('customerPhone').value.trim();
                                const address = document.getElementById('customerAddress').value.trim();

                                if (!name || !phone || !address) {
                                    e.preventDefault();
                                    alert('Vui lòng điền đầy đủ thông tin khách hàng!');
                                    return false;
                                }

                                // Cập nhật cart data trước khi submit
                                const cartArray = Array.from(cart.values()).map(item => ({
                                    productId: item.id,
                                    quantity: item.quantity,
                                    unitPrice: item.price
                                }));
                                document.getElementById('cartDataInput').value = JSON.stringify(cartArray);

                                return true;
                            });

                            // Setup modal
                            if (typeof setupModal === 'function') {
                                setupModal('avatar-promotion-modal', 'avatar-modal-btn', 'close-modal-btn9');
                            }

                            // Phase 2: Xác thực user
                            window.verifyUser = function() {
                                const email = document.getElementById('customerEmail').value.trim();
                                const phone = document.getElementById('customerPhone').value.trim();
                                const resultDiv = document.getElementById('verifyResult');

                                if (!email && !phone) {
                                    resultDiv.style.display = 'block';
                                    resultDiv.style.backgroundColor = '#fff3cd';
                                    resultDiv.style.border = '1px solid #ffc107';
                                    resultDiv.style.color = '#856404';
                                    resultDiv.innerHTML = 'Vui lòng nhập email hoặc số điện thoại để xác minh.';
                                    return;
                                }

                                const params = new URLSearchParams();
                                if (email) params.append('email', email);
                                if (phone) params.append('phone', phone);
                                window.location.href = contextPath + '/admin/verify-user?' + params.toString();
                            };

                            console.log('Create order page initialized');
                        });
                    </script>
                </body>

                </html>