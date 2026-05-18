<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Trang Thanh Toán</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
            integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A=="
            crossorigin="anonymous" referrerpolicy="no-referrer" async />
        <link rel="stylesheet" href="css/store_style.css">
        <link rel="stylesheet" href="css/payment_style.css?v=3">
    </head>

    <body>
        <%@ include file="components/header.jsp" %>
        <div class="toast-container" id="toastContainer"></div>

            <main class="container">
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div class="alert alert-danger"
                        style="color: red; background-color: #f8d7da; border-color: #f5c6cb; padding: 10px; margin-bottom: 15px; border-radius: 5px;">
                        ${sessionScope.errorMessage}
                    </div>
                    <c:remove var="errorMessage" scope="session" />
                </c:if>
                <div class="cart-details">
                    <table>
                        <thead>
                            <tr>
                                <th>HÌNH ẢNH</th>
                                <th>SẢN PHẨM</th>
                                <th>GIÁ</th>
                                <th>SỐ LƯỢNG</th>
                                <th>TỔNG</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.order.items}" var="oi">
                                <c:set var="product" value="${requestScope.productMap[oi.productId]}" />
                                <tr class="cart-item-row">
                                    <td class="cart-product-image">
                                        <a><img src=${product.imageUrl} alt="${product.productName}"></a>
                                    </td>
                                    <td class="cart-product-name">
                                        <a>${product.productName}</a>
                                    </td>
                                    <td class="cart-product-price">
                                        <fmt:setLocale value="vi_VN" />
                                        <fmt:formatNumber value="${oi.unitPrice}" type="currency" currencySymbol="₫"
                                            maxFractionDigits="0" />
                                    </td>
                                    <td class="cart-product-quantity">
                                        <div class="quantity-selector">${oi.quantity}</div>
                                    </td>
                                    <td class="cart-product-subtotal">
                                        <fmt:setLocale value="vi_VN" />
                                        <fmt:formatNumber value="${oi.quantity * oi.unitPrice}" type="currency"
                                            currencySymbol="₫" maxFractionDigits="0" />
                                    </td>
                                    <td class="cart-product-remove">
                                        <form action="delete-cart" method="post">
                                            <input type="hidden" name="id" value="${product.id}">
                                            <input type="hidden" name="redirect" value="checkout">
                                            <input type="hidden" name="cartType" value="${sessionScope.checkoutType}">
                                            <button class="remove-item-btn" aria-label="Xóa sản phẩm"
                                                style="border: 0; background: white">
                                                <i class="fa-solid fa-trash-can"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
                <dialog id="pageDialog">
                    <button id="closeDialog" aria-label="Đóng">&times;</button>
                    <iframe src="${pageContext.request.contextPath}/address?view=popup"
                        style="width: 100%; height: 100%; border: none;"></iframe>
                </dialog>
                <form id="checkoutForm" class="payment-form" action="" method="post">
                    <input type="hidden" name="totalBill" value="${requestScope.order.totalPrice}">
                    <input type="hidden" name="shipping_carrier" id="shipping_carrier_input"
                           value="<c:choose><c:when test='${requestScope.shippingFee > 0}'>ghn</c:when><c:otherwise></c:otherwise></c:choose>">
                    <input type="hidden" name="shipping_fee" id="shipping_fee_input" value="${requestScope.shippingFee}">
                    <div class="billing-details">
                        <div class="billing-header">
                            <h2>THÔNG TIN THANH TOÁN</h2>
                            <button type="button" class="btn-edit-info">Thay đổi thông tin</button>
                        </div>
                        <div id="user-info">
                            <c:choose>
                                <c:when test="${not empty shippingAddress}">
                                    <p><strong>Họ và tên:</strong> <span
                                            id="display-fullname">${shippingAddress.fullName}</span></p>
                                    <p><strong>Địa chỉ giao hàng:</strong> <span
                                            id="display-address">${shippingAddress.addressLine},
                                            ${shippingAddress.ward},
                                            ${shippingAddress.district},
                                            ${shippingAddress.city}</span></p>
                                    <p><strong>Số điện thoại:</strong> <span
                                            id="display-phone">${shippingAddress.phoneNumber}</span></p>
                                    <p><strong>Địa chỉ email:</strong> <span
                                            id="display-email">${sessionScope.user.email}</span></p>
                                </c:when>
                                <c:otherwise>
                                    <div
                                        style="padding: 20px; background-color: #fff3cd; border: 1px solid #ffc107; border-radius: 5px; margin-bottom: 15px;">
                                        <p style="color: #856404; margin: 0 0 10px 0;"><strong><i
                                                    class="fas fa-exclamation-triangle"></i> Bạn chưa có địa chỉ giao
                                                hàng</strong></p>
                                        <p style="color: #856404; margin: 0 0 10px 0;">Vui lòng thêm địa chỉ để tiếp tục
                                            đặt hàng.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <h2>THÔNG TIN BỔ SUNG</h2>
                        <p>
                            <label for="notes">Ghi chú về đơn hàng, ví dụ: thời gian hay chỉ dẫn địa điểm giao hàng
                                chi
                                tiết hơn.</label>
                            <textarea id="notes" name="notes"></textarea>
                        </p>
                        <div class="cart-actions">
                            <a href="${pageContext.request.contextPath}/store" class="continue-shopping"> TIẾP TỤC
                                XEM SẢN PHẨM</a>
                        </div>
                    </div>
                    <div class="order-summary">
                        <h2>ĐƠN HÀNG CỦA BẠN</h2>
                        <div class="discount-section">
                            <div class="discount-toggle" id="discount-toggle-btn">
                                <h3><i class="fas fa-tags" style="margin-right: 10px; color: #8c3333;"></i>Mã giảm giá
                                </h3>
                                <i class="fas fa-chevron-down"></i>
                            </div>

                            <div class="discount-content" id="discount-content-area">
                                <!-- Shipping Discount -->
                                <div class="discount-group">
                                    <label for="shipping-discount-select"><i class="fas fa-truck"
                                            style="margin-right: 5px; color: #555;"></i> Mã vận chuyển</label>
                                    <c:choose>
                                        <c:when test="${not empty shippingDiscounts}">
                                            <select id="shipping-discount-select" class="discount-select">
                                                <option value="">-- Chọn mã vận chuyển --</option>
                                                <c:forEach items="${shippingDiscounts}" var="d">
                                                    <option value="${d.discountCode}"
                                                        ${currentCart.shippingDiscount.discountCode==d.discountCode
                                                        ? 'selected' : '' }>
                                                        ${d.discountCode} - Giảm
                                                        <fmt:formatNumber value="${d.discountValue}" type="currency"
                                                            currencySymbol="₫" maxFractionDigits="0" />
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="no-discount-msg">Không có mã vận chuyển khả dụng</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Voucher Discount -->
                                <div class="discount-group">
                                    <label for="voucher-discount-select"><i class="fas fa-ticket-alt"
                                            style="margin-right: 5px; color: #555;"></i> Voucher của bạn</label>
                                    <c:choose>
                                        <c:when test="${not empty userVouchers}">
                                            <select id="voucher-discount-select" class="discount-select">
                                                <option value="">-- Chọn voucher --</option>
                                                <c:forEach items="${userVouchers}" var="d">
                                                    <option value="${d.discountCode}"
                                                        ${currentCart.voucherDiscount.discountCode==d.discountCode
                                                        ? 'selected' : '' }>
                                                        ${d.discountCode} - Giảm
                                                        <c:choose>
                                                            <c:when
                                                                test="${fn:toUpperCase(d.discountType) == 'PERCENT'}">
                                                                <fmt:formatNumber value="${d.discountValue}"
                                                                    type="number" maxFractionDigits="0" />%
                                                            </c:when>
                                                            <c:otherwise>
                                                                <fmt:formatNumber value="${d.discountValue}"
                                                                    type="currency" currencySymbol="₫"
                                                                    maxFractionDigits="0" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </option>
                                                </c:forEach>
                                            </select>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="no-discount-msg">Bạn chưa có voucher nào</div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Loyalty Discount -->
                                <div class="discount-group">
                                    <label><i class="fas fa-crown" style="margin-right: 5px; color: #c8a165;"></i> Khách
                                        hàng thân thiết</label>
                                    <div id="loyalty-discount-display"
                                        class="${currentCart.loyaltyDiscountAmount > 0 ? '' : 'inactive'}">
                                        <c:if test="${currentCart.loyaltyDiscountAmount > 0}">
                                            <div style="display: flex; align-items: center;">
                                                <i class="fas fa-check-circle"
                                                    style="margin-right: 8px; font-size: 18px;"></i>
                                                <div>
                                                    <div>Đã áp dụng ưu đãi thành viên</div>
                                                    <div style="font-size: 13px; font-weight: normal;">Giảm
                                                        <fmt:formatNumber value="${currentCart.loyaltyDiscountAmount}"
                                                            type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                        <c:if test="${currentCart.loyaltyDiscountAmount <= 0}">
                                            <div style="display: flex; align-items: center;">
                                                <i class="fas fa-info-circle"
                                                    style="margin-right: 8px; font-size: 18px;"></i>
                                                <div>Chưa đủ điều kiện áp dụng</div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <table>
                            <tbody>
                                <tr>
                                    <th>Số lượng</th>
                                    <td>${requestScope.order.items.size()}</td>
                                </tr>
                                <tr>
                                    <th>Tổng phụ</th>
                                    <td>
                                        <fmt:formatNumber value="${requestScope.currentCart.subtotal}" type="currency"
                                            currencySymbol="₫" maxFractionDigits="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <th>Khuyến mãi</th>
                                    <td>-
                                        <fmt:formatNumber value="${requestScope.discountAmount}" type="currency"
                                            currencySymbol="₫" maxFractionDigits="0" />
                                    </td>
                                </tr>
                                <tr>
                                    <th>Phí vận chuyển <span id="summary-carrier-label" style="font-weight:normal;color:#666;">(<c:choose><c:when test="${requestScope.shippingFee > 0 && requestScope.ghnFee > 0}">GHN</c:when><c:when test="${requestScope.shippingFee > 0 && requestScope.ghtkFee > 0}">GHTK</c:when><c:otherwise>--</c:otherwise></c:choose>)</span></th>
                                    <td id="summary-shipping-fee">
                                        <c:choose>
                                            <c:when test="${requestScope.shippingFee > 0}">
                                                <fmt:formatNumber value="${requestScope.shippingFee}" type="currency"
                                                    currencySymbol="₫" maxFractionDigits="0" />
                                            </c:when>
                                            <c:when test="${not empty requestScope.shippingError}">
                                                <span style="color:#dc3545;font-size:13px;">${requestScope.shippingError}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#888;font-size:13px;">Chưa có địa chỉ giao hàng</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Tổng thanh toán</th>
                                    <td><strong>
                                            <fmt:formatNumber value="${requestScope.order.totalPrice + requestScope.shippingFee + (not empty requestScope.excessDiscount ? requestScope.excessDiscount : 0)}" type="currency"
                                                currencySymbol="₫" maxFractionDigits="0" />
                                        </strong></td>
                                </tr>
                            </tbody>
                        </table>

                        <style>
                            .carrier-options-list {
                                display: flex;
                                flex-direction: column;
                                gap: 12px;
                                margin-top: 10px;
                            }
                            .carrier-option.disabled {
                                opacity: 0.6;
                                cursor: not-allowed;
                                background-color: #fafafa;
                                pointer-events: none;
                            }
                        </style>

                        <!-- Thông tin vận chuyển (GHN & GHTK) -->
                        <div class="shipping-carrier-section">
                            <h3>Đơn vị vận chuyển</h3>
                            <div class="carrier-options-list">
                                <!-- Option GHN -->
                                <div class="carrier-option <c:choose><c:when test='${requestScope.ghnFee > 0}'>selected</c:when><c:otherwise>disabled</c:otherwise></c:choose>" id="carrier-ghn-option" onclick="selectCarrier('ghn', ${requestScope.ghnFee})">
                                    <input type="radio" id="carrier-ghn" name="shipping_carrier_radio" value="ghn" <c:choose><c:when test='${requestScope.ghnFee > 0}'>checked</c:when><c:otherwise>disabled</c:otherwise></c:choose>>
                                    <label style="display:flex;align-items:center;gap:14px;width:100%;margin:0;cursor:pointer;">
                                        <div class="carrier-icon" style="background:#8c3333;color:#fff;"><i class="fas fa-truck"></i></div>
                                        <div class="carrier-info" style="flex:1;">
                                            <div class="carrier-name" style="font-weight:bold;">Giao Hàng Nhanh (GHN)</div>
                                            <div class="carrier-detail" style="font-size:12px;color:#666;" id="ghn-detail-text">
                                                <c:choose>
                                                    <c:when test="${requestScope.ghnFee > 0}">
                                                        Nhận hàng nhanh chóng từ đối tác GHN
                                                    </c:when>
                                                    <c:when test="${not empty requestScope.shippingError}">
                                                        <span style="color:#dc3545;">${requestScope.shippingError}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        Chưa có địa chỉ giao hàng
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="carrier-fee" id="ghn-fee-display" style="font-weight:bold;color:#8c3333;">
                                            <c:choose>
                                                <c:when test="${requestScope.ghnFee > 0}">
                                                    <fmt:formatNumber value="${requestScope.ghnFee}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                </c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </label>
                                </div>

                                <!-- Option GHTK -->
                                <div class="carrier-option <c:choose><c:when test='${requestScope.ghnFee <= 0 && requestScope.ghtkFee > 0}'>selected</c:when><c:when test='${requestScope.ghtkFee > 0}'></c:when><c:otherwise>disabled</c:otherwise></c:choose>" id="carrier-ghtk-option" onclick="selectCarrier('ghtk', ${requestScope.ghtkFee})">
                                    <input type="radio" id="carrier-ghtk" name="shipping_carrier_radio" value="ghtk" <c:choose><c:when test='${requestScope.ghnFee <= 0 && requestScope.ghtkFee > 0}'>checked</c:when></c:choose> <c:choose><c:when test='${requestScope.ghtkFee > 0}'></c:when><c:otherwise>disabled</c:otherwise></c:choose>>
                                    <label style="display:flex;align-items:center;gap:14px;width:100%;margin:0;cursor:pointer;">
                                        <div class="carrier-icon" style="background:#1b75bb;color:#fff;"><i class="fas fa-shipping-fast"></i></div>
                                        <div class="carrier-info" style="flex:1;">
                                            <div class="carrier-name" style="font-weight:bold;">Giao Hàng Tiết Kiệm (GHTK)</div>
                                            <div class="carrier-detail" style="font-size:12px;color:#666;" id="ghtk-detail-text">
                                                <c:choose>
                                                    <c:when test="${requestScope.ghtkFee > 0}">
                                                        Tiết kiệm chi phí với đối tác GHTK
                                                    </c:when>
                                                    <c:otherwise>
                                                        Không khả dụng cho tuyến đường này
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                        <div class="carrier-fee" id="ghtk-fee-display" style="font-weight:bold;color:#1b75bb;">
                                            <c:choose>
                                                <c:when test="${requestScope.ghtkFee > 0}">
                                                    <fmt:formatNumber value="${requestScope.ghtkFee}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                </c:when>
                                                <c:otherwise>--</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="payment-methods">
                            <h3>Phương thức thanh toán</h3>
                            <div class="selected-payment-display">
                                <span id="selected-payment-text">Chọn phương thức thanh toán</span>
                                <i class="fas fa-chevron-down"></i>
                            </div>
                            <div class="payment-options-list">
                                <div class="payment-option" data-value="cod">
                                    <input type="radio" id="cod" name="payment_method" value="cod">
                                    <label for="cod">
                                        <div class="payment-icon">
                                            <i class="fas fa-money-bill-wave"></i>
                                        </div>
                                        <div class="payment-info">
                                            <div class="payment-name">Thanh toán khi nhận hàng</div>
                                            <div class="payment-desc">Thanh toán trực tiếp khi nhận hàng</div>
                                        </div>
                                    </label>
                                </div>
                                <div class="payment-option" data-value="ewallet">
                                    <input type="radio" id="ewallet" name="payment_method" value="ewallet">
                                    <label for="ewallet">
                                        <div class="payment-icon">
                                            <i class="fas fa-mobile-alt"></i>
                                        </div>
                                        <div class="payment-info">
                                            <div class="payment-name">Ví điện tử (VNPay)</div>
                                            <div class="payment-desc">Thanh toán qua VNPay - Chờ tối đa 12 giờ</div>
                                        </div>
                                    </label>
                                </div>
                            </div>
                        </div>
                        <c:choose>
                            <c:when test="${requestScope.isLegalAge}">
                                <div class="age-verification" style="color:green;">
                                    <input type="checkbox" id="age-verify" name="age-verify" checked disabled>
                                    <label for="age-verify"><i class="fas fa-check-circle"></i> Bạn đã đủ tuổi hợp pháp để mua rượu (xác nhận từ ngày sinh).</label>
                                    <input type="hidden" name="age-verified" value="true">
                                </div>
                            </c:when>
                            <c:when test="${not empty sessionScope.user.birthDay}">
                                <div class="age-warning-box">
                                    <i class="fas fa-exclamation-triangle"></i>
                                    <span>Bạn chưa đủ 18 tuổi theo ngày sinh đã đăng ký. Không thể mua sản phẩm này.</span>
                                </div>
                                <div class="age-verification" style="display:none;">
                                    <input type="checkbox" id="age-verify" name="age-verify">
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="age-warning-box">
                                    <i class="fas fa-info-circle"></i>
                                    <span>Vui lòng cập nhật ngày sinh trong hồ sơ để xác nhận đủ tuổi mua hàng.</span>
                                </div>
                                <div class="age-verification">
                                    <input type="checkbox" id="age-verify" name="age-verify" required>
                                    <label for="age-verify">Tôi xác nhận tôi đã đủ tuổi hợp pháp để mua rượu.</label>
                                </div>
                            </c:otherwise>
                        </c:choose>
                        <div class="group-button">
                            <button type="button" class="button-cancel" onclick="window.history.back()">HỦY</button>
                            <button type="button" class="button" id="place-order-btn">ĐẶT HÀNG</button>
                        </div>
                    </div>
                </form>
            </main>

            <%@ include file="components/footer.jsp" %>
                <script>
                    /* ========== Toast Notification System ========== */
                    function showToast(type, title, message) {
                        const container = document.getElementById('toastContainer');
                        const icons = { error:'fa-times-circle', success:'fa-check-circle', warning:'fa-exclamation-triangle', info:'fa-info-circle' };
                        const toast = document.createElement('div');
                        toast.className = 'toast toast-' + type;
                        toast.innerHTML = '<div class="toast-icon"><i class="fas ' + (icons[type]||icons.info) + '"></i></div>'
                            + '<div class="toast-body"><div class="toast-title">' + title + '</div><div class="toast-message">' + message + '</div></div>'
                            + '<button class="toast-close" onclick="this.parentElement.remove()">&times;</button>';
                        container.appendChild(toast);
                        setTimeout(function(){ if(toast.parentElement) toast.remove(); }, 4500);
                    }


                    document.addEventListener('DOMContentLoaded', function () {
                        // Hidden inputs already pre-filled server-side; reinforce here for safety
                        var svrFee = parseFloat('${requestScope.shippingFee}') || 0;
                        var ghnFee = parseFloat('${requestScope.ghnFee}') || 0;
                        var ghtkFee = parseFloat('${requestScope.ghtkFee}') || 0;

                        if (ghnFee > 0) {
                            document.getElementById('shipping_carrier_input').value = 'ghn';
                            document.getElementById('shipping_fee_input').value = ghnFee;
                        } else if (ghtkFee > 0) {
                            document.getElementById('shipping_carrier_input').value = 'ghtk';
                            document.getElementById('shipping_fee_input').value = ghtkFee;
                        } else {
                            document.getElementById('shipping_carrier_input').value = '';
                            document.getElementById('shipping_fee_input').value = '0';
                        }

                        const ageVerifyCheckbox = document.getElementById('age-verify');
                        const placeOrderBtn = document.getElementById('place-order-btn');
                        const selectedPaymentDisplay = document.querySelector('.selected-payment-display');
                        const paymentOptionsList = document.querySelector('.payment-options-list');
                        const paymentOptions = document.querySelectorAll('.payment-option');

                        const paymentNames = {
                            'cod': 'Thanh toán khi nhận hàng',
                            'ewallet': 'Ví điện tử (VNPay)'
                        };

                        const savedPaymentMethod = sessionStorage.getItem('selectedPaymentMethod');
                        if (savedPaymentMethod) {
                            const option = document.querySelector('.payment-option[data-value="' + savedPaymentMethod + '"]');
                            if (option) {
                                option.querySelector('input[type="radio"]').checked = true;
                                document.getElementById('selected-payment-text').textContent = paymentNames[savedPaymentMethod];
                                paymentOptions.forEach(function(opt){ opt.classList.remove('selected'); });
                                option.classList.add('selected');
                            }
                        }

                        // Discount Handling
                        const shippingSelect = document.getElementById('shipping-discount-select');
                        const voucherSelect = document.getElementById('voucher-discount-select');
                        const discountToggleBtn = document.getElementById('discount-toggle-btn');
                        const discountContentArea = document.getElementById('discount-content-area');

                        if (discountToggleBtn) {
                            discountToggleBtn.addEventListener('click', function () {
                                this.classList.toggle('active');
                                discountContentArea.classList.toggle('show');
                            });
                        }

                        function applyDiscount(type, code) {
                            fetch('${pageContext.request.contextPath}/cart/apply-discount', {
                                method: 'POST',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                                body: 'type=' + type + '&code=' + code
                            })
                            .then(function(r){ return r.json(); })
                            .then(function(data){
                                if (data.success) { window.location.reload(); }
                                else { showToast('error','Lỗi', data.message); window.location.reload(); }
                            })
                            .catch(function(err){
                                showToast('error','Lỗi','Có lỗi xảy ra khi áp dụng mã giảm giá');
                            });
                        }

                        if (shippingSelect) { shippingSelect.addEventListener('change', function(){ applyDiscount('shipping', this.value); }); }
                        if (voucherSelect) { voucherSelect.addEventListener('change', function(){ applyDiscount('voucher', this.value); }); }

                        selectedPaymentDisplay.addEventListener('click', function () {
                            var chevron = this.querySelector('i');
                            paymentOptionsList.classList.toggle('show');
                            chevron.style.transform = paymentOptionsList.classList.contains('show') ? 'rotate(180deg)' : 'rotate(0deg)';
                        });

                        paymentOptions.forEach(function(option){
                            option.addEventListener('click', function () {
                                var value = this.getAttribute('data-value');
                                this.querySelector('input[type="radio"]').checked = true;
                                document.getElementById('selected-payment-text').textContent = paymentNames[value];
                                paymentOptions.forEach(function(opt){ opt.classList.remove('selected'); });
                                this.classList.add('selected');
                                paymentOptionsList.classList.remove('show');
                                selectedPaymentDisplay.querySelector('i').style.transform = 'rotate(0deg)';
                                sessionStorage.setItem('selectedPaymentMethod', value);
                            });
                        });
                    });
                </script>
                <script>
                    const dialog = document.getElementById("pageDialog");
                    const openBtn = document.querySelector(".btn-edit-info");
                    const closeBtn = document.getElementById("closeDialog");

                    openBtn.addEventListener("click", (e) => {
                        e.preventDefault();
                        dialog.showModal();
                    });

                    closeBtn.addEventListener("click", () => {
                        dialog.close();
                        // Không reload trang nếu đã nhận address qua postMessage
                        if (!closeBtn._addressSelected) {
                            window.location.reload();
                        }
                        closeBtn._addressSelected = false;
                    });

                    /* ========== Dynamic Carrier Selection & Recalculation ========== */
                    let ghnCalculatedFee = parseFloat('${requestScope.ghnFee}') || 0;
                    let ghtkCalculatedFee = parseFloat('${requestScope.ghtkFee}') || 0;

                    function selectCarrier(carrier, fee) {
                        if (fee <= 0) return; // Do not allow selecting disabled carriers

                        // Update hidden form inputs
                        document.getElementById('shipping_carrier_input').value = carrier;
                        document.getElementById('shipping_fee_input').value = fee;

                        // Update selected visual states in UI
                        const ghnOpt = document.getElementById('carrier-ghn-option');
                        const ghtkOpt = document.getElementById('carrier-ghtk-option');
                        const ghnRadio = document.getElementById('carrier-ghn');
                        const ghtkRadio = document.getElementById('carrier-ghtk');

                        if (carrier === 'ghn') {
                            if(ghnOpt) ghnOpt.classList.add('selected');
                            if(ghtkOpt) ghtkOpt.classList.remove('selected');
                            if(ghnRadio) ghnRadio.checked = true;
                        } else {
                            if(ghtkOpt) ghtkOpt.classList.add('selected');
                            if(ghnOpt) ghnOpt.classList.remove('selected');
                            if(ghtkRadio) ghtkRadio.checked = true;
                        }

                        // Update summary carrier label
                        const labelEl = document.getElementById('summary-carrier-label');
                        if (labelEl) labelEl.textContent = '(' + carrier.toUpperCase() + ')';

                        // Update summary shipping fee cell
                        const feeFormatted = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(fee);
                        const feeCell = document.getElementById('summary-shipping-fee');
                        if (feeCell) feeCell.innerHTML = feeFormatted;

                        // Recalculate and update Grand Total
                        const subtotal = parseFloat('${requestScope.order.totalPrice}') || 0;
                        const shippingDiscountValue = parseFloat('${currentCart.shippingDiscount.discountValue}') || 0;
                        let excessDiscount = 0;
                        if (shippingDiscountValue > fee) {
                            excessDiscount = shippingDiscountValue - fee;
                        }
                        const total = subtotal + fee + excessDiscount;
                        const totalRows = document.querySelectorAll('table tbody tr, .order-summary tbody tr');
                        totalRows.forEach(row => {
                            const th = row.querySelector('th');
                            if (th && th.textContent.includes('Tổng thanh toán')) {
                                const td = row.querySelector('td strong');
                                if (td) td.textContent = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(total);
                            }
                        });
                    }

                    /* ========== Tính lại phí ship khi chọn địa chỉ mới (Cả hai hãng) ========== */
                    function recalcShipping(city, district, ward) {
                        const ghnDetail = document.getElementById('ghn-detail-text');
                        const ghtkDetail = document.getElementById('ghtk-detail-text');
                        
                        const ghnFeeDisplay = document.getElementById('ghn-fee-display');
                        const ghtkFeeDisplay = document.getElementById('ghtk-fee-display');
                        
                        const ghnOpt = document.getElementById('carrier-ghn-option');
                        const ghtkOpt = document.getElementById('carrier-ghtk-option');

                        // Show loading state
                        if (ghnDetail) { ghnDetail.style.color = '#888'; ghnDetail.textContent = 'Đang tính phí ship GHN...'; }
                        if (ghtkDetail) { ghtkDetail.style.color = '#888'; ghtkDetail.textContent = 'Đang tính phí ship GHTK...'; }

                        const params = new URLSearchParams({
                            city: city,
                            district: district,
                            ward: ward,
                            weight: '500'
                        });

                        fetch('${pageContext.request.contextPath}/api/shipping-by-address?' + params.toString())
                        .then(r => r.json())
                        .then(result => {
                            if (result.status === 'success') {
                                const ghn = result.ghn || { status: 'error', message: 'Lỗi' };
                                const ghtk = result.ghtk || { status: 'error', message: 'Lỗi' };

                                let ghnFee = 0;
                                let ghtkFee = 0;

                                // Update GHN
                                if (ghn.status === 'success') {
                                    ghnFee = parseFloat(ghn.fee) || 0;
                                    ghnCalculatedFee = ghnFee;
                                    if (ghnDetail) { ghnDetail.style.color = '#28a745'; ghnDetail.textContent = 'Nhận hàng nhanh chóng từ đối tác GHN'; }
                                    if (ghnFeeDisplay) ghnFeeDisplay.innerHTML = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(ghnFee);
                                    if (ghnOpt) ghnOpt.classList.remove('disabled');
                                } else {
                                    ghnCalculatedFee = 0;
                                    if (ghnDetail) { ghnDetail.style.color = '#dc3545'; ghnDetail.textContent = ghn.message || 'Không khả dụng cho tuyến đường này'; }
                                    if (ghnFeeDisplay) ghnFeeDisplay.innerHTML = '--';
                                    if (ghnOpt) ghnOpt.classList.add('disabled');
                                }

                                // Update GHTK
                                if (ghtk.status === 'success') {
                                    ghtkFee = parseFloat(ghtk.fee) || 0;
                                    ghtkCalculatedFee = ghtkFee;
                                    if (ghtkDetail) { ghtkDetail.style.color = '#28a745'; ghtkDetail.textContent = 'Tiết kiệm chi phí với đối tác GHTK'; }
                                    if (ghtkFeeDisplay) ghtkFeeDisplay.innerHTML = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(ghtkFee);
                                    if (ghtkOpt) ghtkOpt.classList.remove('disabled');
                                } else {
                                    ghtkCalculatedFee = 0;
                                    if (ghtkDetail) { ghtkDetail.style.color = '#dc3545'; ghtkDetail.textContent = ghtk.message || 'Không khả dụng cho tuyến đường này'; }
                                    if (ghtkFeeDisplay) ghtkFeeDisplay.innerHTML = '--';
                                    if (ghtkOpt) ghtkOpt.classList.add('disabled');
                                }

                                // Auto select the best available carrier (prefer GHN if both are available)
                                if (ghnFee > 0) {
                                    selectCarrier('ghn', ghnFee);
                                    showToast('success', 'Phí vận chuyển', 'Đã cập nhật phí ship GHN: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(ghnFee));
                                } else if (ghtkFee > 0) {
                                    selectCarrier('ghtk', ghtkFee);
                                    showToast('success', 'Phí vận chuyển', 'Đã cập nhật phí ship GHTK: ' + new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(ghtkFee));
                                } else {
                                    // Reset inputs
                                    document.getElementById('shipping_fee_input').value = '0';
                                    document.getElementById('shipping_carrier_input').value = '';
                                    if (ghnOpt) ghnOpt.classList.remove('selected');
                                    if (ghtkOpt) ghtkOpt.classList.remove('selected');
                                    showToast('warning', 'Phí vận chuyển', 'Không có đơn vị vận chuyển nào khả dụng cho địa chỉ này.');
                                }
                            } else {
                                throw new Error(result.message);
                            }
                        })
                        .catch(err => {
                            console.error('Shipping calc error:', err);
                            showToast('error', 'Lỗi', 'Không thể tính phí vận chuyển cho địa chỉ này');
                            if (ghnDetail) { ghnDetail.style.color = '#dc3545'; ghnDetail.textContent = 'Lỗi tính phí ship'; }
                            if (ghtkDetail) { ghtkDetail.style.color = '#dc3545'; ghtkDetail.textContent = 'Lỗi tính phí ship'; }
                            if (ghnOpt) ghnOpt.classList.add('disabled');
                            if (ghtkOpt) ghtkOpt.classList.add('disabled');
                        });
                    }

                    window.addEventListener('message', function (event) {
                        if (event.data.type === 'SELECT_ADDRESS') {
                            const data = event.data.data;

                            // Cập nhật hiển thị thông tin
                            const fullnameEl = document.getElementById('display-fullname');
                            const phoneEl = document.getElementById('display-phone');
                            const addressEl = document.getElementById('display-address');
                            if (fullnameEl) fullnameEl.textContent = data.fullName || '';
                            if (phoneEl) phoneEl.textContent = data.phone || '';
                            if (addressEl) addressEl.textContent = data.address || '';

                            dialog.close();
                            closeBtn._addressSelected = true;

                            // Tính lại phí ship nếu có đủ thông tin địa chỉ
                            if (data.city && data.district && data.ward) {
                                recalcShipping(data.city, data.district, data.ward);
                            } else {
                                showToast('warning', 'Địa chỉ', 'Địa chỉ thiếu thông tin Quận/Huyện. Vui lòng cập nhật.');
                            }
                        }
                    });
                </script>
    </body>