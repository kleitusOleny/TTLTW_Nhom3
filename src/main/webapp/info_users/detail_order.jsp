<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Chi tiết đơn hàng</title>
                <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
                <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet">
                <%-- <link rel="stylesheet" href="../css/store_style.css">--%>
                    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/detail_order_style.css">
            </head>
            <%@ include file="../components/header.jsp" %>

                <body>

                    <div class="order-detail">
                        <h1>Chi tiết đơn hàng #${order.id}</h1>

                        <div class="section info">
                            <h2>Thông tin khách hàng</h2>
                            <p><strong>Họ và tên:</strong> ${shippingAddress.fullName}</p>
                            <p><strong>Email:</strong> ${sessionScope.user.email}</p>
                            <p><strong>Điện thoại:</strong> ${shippingAddress.phoneNumber}</p>
                            <p><strong>Địa chỉ:</strong> ${shippingAddress.addressLine}, ${shippingAddress.ward}, ${shippingAddress.district},
                                ${shippingAddress.city}</p>
                            <p><strong>Ghi chú:</strong> ${order.note}</p>
                            <p><strong>Hình thức thanh toán:</strong> ${payment.payStrategy}</p>
                            <c:if test="${not empty payment.id}">
                                <p><strong>Mã thanh toán:</strong> ${payment.id}</p>
                            </c:if>
                            <c:if test="${not empty shipOrder.trackingNumber}">
                                <p><strong>Mã vận chuyển:</strong> ${shipOrder.trackingNumber}</p>
                            </c:if>
                        </div>

                        <div class="section">
                            <h2>Sản phẩm</h2>
                            <table>
                                <thead>
                                    <tr>
                                        <th>Hình ảnh</th>
                                        <th>Sản phẩm</th>
                                        <th>Số lượng</th>
                                        <th>Đơn giá</th>
                                        <th>Tổng</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${order.items}" var="item">
                                        <c:set var="product" value="${productMap[item.productId]}" />
                                        <tr>
                                            <td><img class="product-img" src="${product.imageUrl}"
                                                    alt="${product.productName}"></td>
                                            <td><strong>${product.productName}</strong></td>
                                            <td>${item.quantity}</td>
                                            <td>
                                                <fmt:setLocale value="vi_VN" />
                                                <fmt:formatNumber value="${item.unitPrice}" type="currency"
                                                    currencySymbol="₫" maxFractionDigits="0" />
                                            </td>
                                            <td>
                                                <fmt:formatNumber value="${item.quantity * item.unitPrice}"
                                                    type="currency" currencySymbol="₫" maxFractionDigits="0" />
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                                <tfoot>
                                    <tr>
                                        <th colspan="4" style="text-align:right">Tổng cộng:</th>
                                        <th>
                                            <fmt:setLocale value="vi_VN" />
                                            <fmt:formatNumber value="${order.totalPrice}" type="currency"
                                                currencySymbol="₫" maxFractionDigits="0" />
                                        </th>
                                    </tr>
                                </tfoot>
                            </table>
                        </div>

                        <div class="section">
                            <h2>Trạng thái đơn hàng</h2>
                            <span class="status completed">${shipOrder != null ? shipOrder.status : (payment.status ==
                                'Failed' ? 'Thanh toán thất bại' : 'Đang xử lý')}</span>

                            <div class="tracking-bar">
                                <c:set var="progressWidth" value="0%" />
                                <c:choose>
                                    <c:when
                                        test="${shipOrder.status == 'Đang giao hàng' || shipOrder.status == 'Đang giao'}">
                                        <c:set var="progressWidth" value="50%" />
                                    </c:when>
                                    <c:when test="${shipOrder.status == 'Giao hàng thành công'}">
                                        <c:set var="progressWidth" value="100%" />
                                    </c:when>
                                </c:choose>
                                <div class="tracking-progress" style="width: ${progressWidth};"></div>

                                <div
                                    class="tracking-step ${shipOrder.status == 'Chuẩn bị đơn hàng' || shipOrder.status == 'Đang giao hàng' || shipOrder.status == 'Đang giao' || shipOrder.status == 'Giao hàng thành công' ? 'active' : ''}">
                                    <div class="step-dot"></div>
                                    <div class="step-label">Đang xử lý</div>
                                </div>
                                <div
                                    class="tracking-step ${shipOrder.status == 'Đang giao hàng' || shipOrder.status == 'Đang giao' || shipOrder.status == 'Giao hàng thành công' ? 'active' : ''}">
                                    <div class="step-dot"></div>
                                    <div class="step-label">Đang giao</div>
                                </div>
                                <div
                                    class="tracking-step ${shipOrder.status == 'Giao hàng thành công' ? 'active' : ''}">
                                    <div class="step-dot"></div>
                                    <div class="step-label">Đã giao</div>
                                </div>
                            </div>
                        </div>

                        <div class="actions">
                            <form action="${pageContext.request.contextPath}/order-detail" method="POST" style="display:inline;">
                                <input type="hidden" name="action" value="reorder">
                                <input type="hidden" name="orderId" value="${order.id}">
                                <button type="submit" class="btn">Mua lại</button>
                            </form>
                            <button class="btn" id="exportPDF">In hóa đơn</button>
                            <c:if test="${shipOrder != null and (shipOrder.status == 'Đang xử lý' or shipOrder.status == 'Chuẩn bị đơn hàng')}">
                                <form action="${pageContext.request.contextPath}/orders" method="POST" style="display:inline;" onsubmit="return confirm('Bạn có chắc chắn muốn hủy đơn hàng này?');">
                                    <input type="hidden" name="action" value="cancelOrder">
                                    <input type="hidden" name="orderId" value="${order.id}">
                                    <button type="submit" class="btn" style="background-color: #dc3545; color: white;">Hủy đơn hàng</button>
                                </form>
                            </c:if>
                            <c:if test="${payment.status == 'Failed'}">
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

                    <%@ include file="../components/footer.jsp" %>
                        <script>
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

                            document.getElementById("exportPDF").addEventListener("click", function () {

                                const element = document.querySelector(".order-detail");

                                const sections = document.querySelectorAll(".order-detail .section");
                                const actions = document.querySelector(".order-detail .actions");

                                let removedSection = null;
                                if (sections[2]) {
                                    removedSection = sections[2];
                                    removedSection.style.display = "none";
                                }

                                let removedActions = null;
                                if (actions) {
                                    removedActions = actions;
                                    removedActions.style.display = "none";
                                }

                                const opt = {
                                    margin: 10,
                                    filename: 'don-hang.pdf',
                                    image: { type: 'jpeg', quality: 0.98 },
                                    html2canvas: { scale: 2, scrollY: 0 },
                                    jsPDF: { unit: 'mm', format: 'a4', orientation: 'portrait' }
                                };

                                html2pdf().from(element).set(opt).save()
                                    .then(() => {
                                        if (removedSection) removedSection.style.display = "";
                                        if (removedActions) removedActions.style.display = "";
                                    });

                            });


                        </script>

                        <script
                            src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
                </body>

            </html>