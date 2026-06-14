<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
            <link rel="stylesheet" href="<%=request.getContextPath()%>/css/my_order_style.css">

            <div class="orders-container">
                <h2>Đơn hàng của tôi</h2>
                
                <c:if test="${not empty sessionScope.successMessage}">
                    <div style="padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: 4px; color: #155724; background-color: #d4edda; border-color: #c3e6cb;">
                        ${sessionScope.successMessage}
                    </div>
                    <c:remove var="successMessage" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.errorMessage}">
                    <div style="padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: 4px; color: #721c24; background-color: #f8d7da; border-color: #f5c6cb;">
                        ${sessionScope.errorMessage}
                    </div>
                    <c:remove var="errorMessage" scope="session"/>
                </c:if>

                <c:if test="${empty orders}">
                    <div class="empty-orders" style="text-align: center; padding: 50px;">
                        <i class="fa-solid fa-box-open" style="font-size: 50px; color: #ccc; margin-bottom: 20px;"></i>
                        <p>Bạn chưa có đơn hàng nào.</p>
                        <button class="btn" onclick="location.href='store'" style="margin-top: 20px;">Mua sắm
                            ngay
                        </button>
                    </div>
                </c:if>

                <c:if test="${not empty orders}">
                    <div class="order-filter">
                        <div class="filter-tabs">
                            <button class="filter-btn active" onclick="filterOrders(this, 'all')">Tất cả</button>
                            <button class="filter-btn" onclick="filterOrders(this, 'Đang xử lý')">Đang xử lý</button>
                            <button class="filter-btn" onclick="filterOrders(this, 'Chuẩn bị đơn hàng')">Chuẩn bị đơn
                                hàng</button>
                            <button class="filter-btn" onclick="filterOrders(this, 'Đang giao hàng')">Đang giao
                                hàng</button>
                            <button class="filter-btn" onclick="filterOrders(this, 'Giao hàng thành công')">Giao hàng
                                thành công</button>
                            <button class="filter-btn" onclick="filterOrders(this, 'Đã hủy')">Đã hủy</button>
                            <button class="filter-btn" onclick="filterOrders(this, 'Thanh toán thất bại')">Thanh toán
                                thất bại</button>
                        </div>
                    </div>

                    <div class="order-list">
                        <c:forEach items="${orders}" var="order">
                            <c:set var="shipOrder" value="${shipOrderMap[order.id]}" />
                            <c:set var="payment" value="${paymentMap[order.id]}" />
                            <c:choose>
                                <c:when test="${payment != null and payment.status == 'Failed'}">
                                    <c:set var="status" value="Thanh toán thất bại" />
                                </c:when>
                                <c:otherwise>
                                    <c:set var="status"
                                        value="${shipOrder != null ? shipOrder.status : 'Đang xử lý'}" />
                                </c:otherwise>
                            </c:choose>

                            <div class="order-card" data-status="${status}">
                                <div class="order-header">
                                    <span class="order-id">#${order.id}</span>
                                    <c:choose>
                                        <c:when test="${status == 'Thanh toán thất bại'}">
                                            <span class="order-status status-cancelled">${status}</span>
                                        </c:when>
                                        <c:when test="${status == 'Đã hủy'}">
                                            <span class="order-status status-cancelled">${status}</span>
                                        </c:when>
                                        <c:when test="${status == 'Đang xử lý' or status == 'Chuẩn bị đơn hàng'}">
                                            <span class="order-status status-pending">${status}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="order-status status-completed">${status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="order-body" style="border-bottom: 1px solid #eee; padding-bottom: 15px; margin-bottom: 15px;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 15px;">
                                        <div>
                                            <p style="margin: 0; color: #555;"><strong>Ngày đặt:</strong> 
                                                <fmt:formatDate value="${order.createAt}" pattern="dd/MM/yyyy HH:mm" />
                                            </p>
                                            <c:if test="${shipOrder != null}">
                                                <p style="margin: 5px 0 0; color: #555;"><strong>Đơn vị giao:</strong> ${not empty shipOrder.carrierName ? shipOrder.carrierName : 'Chưa cập nhật'}
                                                </p>
                                                <p style="margin: 5px 0 0; color: #555;"><strong>Dự kiến giao:</strong> 
                                                    <c:choose>
                                                        <c:when test="${not empty shipOrder.estimatedDeliveryDate}">
                                                            <fmt:formatDate value="${shipOrder.estimatedDeliveryDate}" pattern="dd/MM/yyyy" />
                                                        </c:when>
                                                        <c:otherwise>Chưa cập nhật</c:otherwise>
                                                    </c:choose>
                                                </p>
                                            </c:if>
                                        </div>
                                        <p style="margin: 0; font-size: 16px; text-align: right;"><strong>Tổng tiền:</strong><br/>
                                            <span style="color: #a94442; font-weight: bold; font-size: 18px;">
                                                <fmt:setLocale value="vi_VN" />
                                                <fmt:formatNumber value="${order.totalPrice}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                            </span>
                                        </p>
                                    </div>
                                    
                                    <!-- Hiển thị sản phẩm -->
                                    <div class="order-items-preview" style="background: #fdfdfd; border-radius: 6px; padding: 10px;">
                                        <c:forEach var="item" items="${orderItemsMap[order.id]}">
                                            <div style="display: flex; align-items: center; margin-bottom: 10px; padding-bottom: 10px; border-bottom: 1px dashed #eee;">
                                                <img src="${pageContext.request.contextPath}/${item.url_img}" alt="${item.product_name}" style="width: 60px; height: 60px; object-fit: cover; border-radius: 4px; border: 1px solid #eee; margin-right: 15px;">
                                                <div style="flex-grow: 1;">
                                                    <p style="margin: 0; font-weight: bold; color: #333; font-size: 15px;">${item.product_name}</p>
                                                    <p style="margin: 5px 0 0; color: #777; font-size: 13px;">x${item.quantity}</p>
                                                </div>
                                                <div style="text-align: right; font-weight: 500; color: #a94442;">
                                                    <fmt:setLocale value="vi_VN" />
                                                    <fmt:formatNumber value="${item.unit_price}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="tracking-bar-container" style="padding-top: 10px;">
                                    <div class="tracking-bar">
                                        <c:set var="progressWidth" value="0%" />
                                        <c:choose>
                                            <c:when test="${status == 'Đang giao hàng' || status == 'Đang giao'}">
                                                <c:set var="progressWidth" value="50%" />
                                            </c:when>
                                            <c:when test="${status == 'Giao hàng thành công'}">
                                                <c:set var="progressWidth" value="100%" />
                                            </c:when>
                                        </c:choose>
                                        <div class="tracking-progress" style="width: ${progressWidth};"></div>

                                        <div
                                            class="tracking-step ${status == 'Chuẩn bị đơn hàng' || status == 'Đang giao hàng' || status == 'Đang giao' || status == 'Giao hàng thành công' ? 'active' : ''}">
                                            <div class="step-dot"></div>
                                            <div class="step-label">Đang xử lý</div>
                                        </div>
                                        <div
                                            class="tracking-step ${status == 'Đang giao hàng' || status == 'Đang giao' || status == 'Giao hàng thành công' ? 'active' : ''}">
                                            <div class="step-dot"></div>
                                            <div class="step-label">Đang giao</div>
                                        </div>
                                        <div class="tracking-step ${status == 'Giao hàng thành công' ? 'active' : ''}">
                                            <div class="step-dot"></div>
                                            <div class="step-label">Đã giao</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="order-actions">
                                    <button class="btn"
                                        onclick="location.href='${pageContext.request.contextPath}/order-detail?id=${order.id}'">Xem
                                        chi
                                        tiết
                                    </button>
                                    <form action="${pageContext.request.contextPath}/order-detail" method="POST" style="display:inline;">
                                        <input type="hidden" name="action" value="reorder">
                                        <input type="hidden" name="orderId" value="${order.id}">
                                        <button type="submit" class="btn">Mua lại</button>
                                    </form>
                                    <c:if test="${status == 'Đang xử lý' or status == 'Chuẩn bị đơn hàng'}">
                                        <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                            <input type="hidden" name="action" value="cancelOrder">
                                            <input type="hidden" name="orderId" value="${order.id}">
                                            <button type="submit" class="btn" style="background-color: #dc3545; color: white;">Hủy đơn hàng</button>
                                        </form>
                                    </c:if>
                                    <c:if test="${status == 'Thanh toán thất bại'}">
                                        <c:choose>
                                            <c:when test="${payment.payStrategy == 'PayPal'}">
                                                <button class="btn" style="background-color: #f0ad4e; color: white;"
                                                    onclick="checkPaymentRetry(${order.id}, ${payment.paidAt.time}, 'PayPal', '${pageContext.request.contextPath}')">
                                                    Thanh toán lại (PayPal)
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn" style="background-color: #f0ad4e; color: white;"
                                                    onclick="checkPaymentRetry(${order.id}, ${payment.paidAt.time}, 'VNPay', '${pageContext.request.contextPath}')">
                                                    Thanh toán lại (VNPay)
                                                </button>
                                            </c:otherwise>
                                        </c:choose>
                                    </c:if>
                                    <c:if test="${status == 'Giao hàng thành công'}">
                                        <c:if test="${!order.evaluated}">
                                            <button class="btn"
                                                onclick="location.href='${pageContext.request.contextPath}/evaluate?orderId=${order.id}'">
                                                Đánh giá
                                            </button>
                                        </c:if>
                                        <c:if test="${order.evaluated}">
                                            <button class="btn" style="background-color: #28a745; color: white; cursor: not-allowed;" disabled>
                                                <i class="fa-solid fa-check"></i> Đã đánh giá
                                            </button>
                                        </c:if>
                                        <button class="btn"
                                            onclick="openRefundModal(${order.id})">
                                            Hoàn trả / Hoàn tiền
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </div>

            <!-- Refund Confirmation Modal -->
            <div id="refund-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;">
                <div style="background: white; padding: 30px; border-radius: 8px; max-width: 400px; width: 100%; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                    <i class="fa-solid fa-circle-exclamation" style="font-size: 40px; color: #f0ad4e; margin-bottom: 15px;"></i>
                    <h3 style="margin-bottom: 15px;">Xác nhận hoàn trả</h3>
                    <p style="margin-bottom: 15px; color: #555;">Vui lòng chọn hoặc nhập lý do hoàn trả/hoàn tiền. Quá trình này sẽ cần admin phê duyệt.</p>
                    <select id="refund-reason-select" style="width: 100%; box-sizing: border-box; margin-bottom: 10px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-family: inherit; background-color: #f9f9f9;">
                        <option value="">-- Chọn lý do (Bắt buộc) --</option>
                        <option value="Sản phẩm bị lỗi hoặc không hoạt động">Sản phẩm bị lỗi hoặc không hoạt động</option>
                        <option value="Sản phẩm không giống với mô tả">Sản phẩm không giống với mô tả</option>
                        <option value="Hàng bị hỏng/vỡ trong quá trình vận chuyển">Hàng bị hỏng/vỡ trong quá trình vận chuyển</option>
                        <option value="Giao sai sản phẩm / thiếu số lượng">Giao sai sản phẩm / thiếu số lượng</option>
                        <option value="Thiếu phụ kiện kèm theo">Thiếu phụ kiện kèm theo</option>
                        <option value="Khác">Khác (Vui lòng nhập chi tiết bên dưới)</option>
                    </select>
                    <textarea id="refund-reason" rows="2" style="width: 100%; box-sizing: border-box; margin-bottom: 20px; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-family: inherit;" placeholder="Chi tiết thêm (tuỳ chọn)..."></textarea>
                    <div style="display: flex; justify-content: center; gap: 15px;">
                        <button class="btn" style="background-color: #ccc; color: #333;" onclick="closeRefundModal()">Hủy</button>
                        <button class="btn" style="background-color: #a94442; color: white;" onclick="submitRefund()">Xác nhận</button>
                    </div>
                </div>
            </div>

            <!-- Payment Expired Modal -->
            <div id="payment-expired-modal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); z-index: 9999; justify-content: center; align-items: center;">
                <div style="background: white; padding: 30px; border-radius: 8px; max-width: 400px; width: 100%; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                    <i class="fa-solid fa-clock-rotate-left" style="font-size: 40px; color: #dc3545; margin-bottom: 15px;"></i>
                    <h3 style="margin-bottom: 15px;">Đã quá hạn thanh toán</h3>
                    <p style="margin-bottom: 20px; color: #555; line-height: 1.5;">Đơn hàng này đã vượt quá thời gian cho phép thanh toán lại (12 giờ).<br>Vui lòng đặt một đơn hàng mới.</p>
                    <div style="display: flex; justify-content: center; gap: 15px;">
                        <button class="btn" style="background-color: #ccc; color: #333;" onclick="closePaymentExpiredModal()">Đóng</button>
                        <button class="btn" style="background-color: #8c3333; color: white;" onclick="location.href='${pageContext.request.contextPath}/store'">Đặt hàng mới</button>
                    </div>
                </div>
            </div>

            <script>
                let currentRefundOrderId = null;

                function checkPaymentRetry(orderId, paidAtTime, payStrategy, contextPath) {
                    const now = new Date().getTime();
                    const hoursDiff = (now - paidAtTime) / (1000 * 60 * 60);
                    if (hoursDiff >= 12) {
                        document.getElementById('payment-expired-modal').style.display = 'flex';
                        return;
                    }
                    if (payStrategy === 'PayPal') {
                        location.href = contextPath + '/paypalPayment?orderId=' + orderId;
                    } else {
                        location.href = contextPath + '/payment?orderId=' + orderId;
                    }
                }

                function closePaymentExpiredModal() {
                    document.getElementById('payment-expired-modal').style.display = 'none';
                }

                function openRefundModal(orderId) {
                    currentRefundOrderId = orderId;
                    document.getElementById('refund-reason-select').value = '';
                    document.getElementById('refund-reason').value = '';
                    document.getElementById('refund-modal').style.display = 'flex';
                }

                function closeRefundModal() {
                    currentRefundOrderId = null;
                    document.getElementById('refund-modal').style.display = 'none';
                }

                function submitRefund() {
                    const selectedReason = document.getElementById('refund-reason-select').value;
                    const typedReason = document.getElementById('refund-reason').value.trim();
                    
                    let finalReason = "";
                    if (selectedReason && typedReason) {
                        finalReason = selectedReason + " - " + typedReason;
                    } else if (selectedReason) {
                        finalReason = selectedReason;
                    } else if (typedReason) {
                        finalReason = typedReason;
                    }

                    if (!finalReason) {
                        alert("Vui lòng chọn hoặc nhập lý do hoàn trả!");
                        document.getElementById('refund-reason-select').focus();
                        return;
                    }

                    if (currentRefundOrderId) {
                        const form = document.createElement('form');
                        form.method = 'POST';
                        form.action = '${pageContext.request.contextPath}/orders';
                        
                        const actionInput = document.createElement('input');
                        actionInput.type = 'hidden';
                        actionInput.name = 'action';
                        actionInput.value = 'requestRefund';
                        form.appendChild(actionInput);
                        
                        const idInput = document.createElement('input');
                        idInput.type = 'hidden';
                        idInput.name = 'orderId';
                        idInput.value = currentRefundOrderId;
                        form.appendChild(idInput);
                        
                        const reasonInput = document.createElement('input');
                        reasonInput.type = 'hidden';
                        reasonInput.name = 'reason';
                        reasonInput.value = finalReason;
                        form.appendChild(reasonInput);
                        
                        document.body.appendChild(form);
                        form.submit();
                    }
                }

                function filterOrders(btn, filterValue) {
                    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
                    if (btn) btn.classList.add('active');

                    const orderCards = document.querySelectorAll('.order-card');

                    orderCards.forEach(card => {
                        const status = card.getAttribute('data-status').trim();
                        if (filterValue === 'all' || status === filterValue) {
                            card.style.display = 'block';
                        } else {
                            card.style.display = 'none';
                        }
                    });
                }
            </script>