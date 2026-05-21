<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán MoMo</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="stylesheet" href="../css/store_style.css">
    <link rel="stylesheet" href="../css/payment_style.css">
    <style>
        .result-container {
            max-width: 600px;
            margin: 50px auto;
            padding: 40px 30px;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            text-align: center;
            border-top: 6px solid #e11b74;
            transition: all 0.3s ease;
        }

        .momo-logo {
            width: 80px;
            height: 80px;
            background: #e11b74;
            border-radius: 20px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 40px;
            font-weight: 900;
            margin-bottom: 25px;
            box-shadow: 0 8px 20px rgba(225, 27, 116, 0.3);
            animation: bounceIn 0.8s ease;
        }

        .result-icon {
            font-size: 55px;
            margin-bottom: 20px;
            display: inline-block;
        }

        .success-icon {
            color: #28a745;
            animation: scaleIn 0.5s ease;
        }

        .error-icon {
            color: #dc3545;
            animation: scaleIn 0.5s ease;
        }

        .result-title {
            font-size: 26px;
            font-weight: 700;
            margin-bottom: 12px;
            color: #333;
        }

        .result-message {
            color: #666;
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 35px;
        }

        .transaction-details {
            text-align: left;
            background: #fcf6f9;
            padding: 24px;
            border-radius: 12px;
            margin-bottom: 35px;
            border: 1px solid #f9e6f0;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
            padding-bottom: 14px;
            border-bottom: 1px dashed #f3d1e2;
        }

        .detail-row:last-child {
            border-bottom: none;
            margin-bottom: 0;
            padding-bottom: 0;
        }

        .detail-label {
            font-weight: 600;
            color: #777;
            font-size: 14px;
        }

        .detail-value {
            color: #333;
            font-weight: 700;
            font-size: 14px;
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
        }

        .btn {
            padding: 12px 28px;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s;
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background: #e11b74;
            color: white;
            box-shadow: 0 4px 15px rgba(225, 27, 116, 0.2);
        }

        .btn-primary:hover {
            background: #c01260;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(225, 27, 116, 0.3);
        }

        .btn-secondary {
            background: #f5f5f5;
            color: #555;
            border: 1px solid #ddd;
        }

        .btn-secondary:hover {
            background: #e8e8e8;
            transform: translateY(-2px);
        }

        @keyframes bounceIn {
            0% { transform: scale(0.3); opacity: 0; }
            50% { transform: scale(1.05); }
            70% { transform: scale(0.9); }
            100% { transform: scale(1); opacity: 1; }
        }

        @keyframes scaleIn {
            0% { transform: scale(0); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }
    </style>
</head>

<body>
    <%@ include file="../components/header.jsp" %>

    <main class="container" style="min-height: 70vh; display: flex; align-items: center; justify-content: center;">
        <div class="result-container">
            <div class="momo-logo">
                <span>m</span>
            </div>

            <c:set var="amount" value="${requestScope.amount}" />
            <c:set var="orderInfo" value="${requestScope.orderInfo}" />
            <c:set var="payDate" value="${requestScope.payDate}" />

            <c:choose>
                <c:when test="${requestScope.transResult}">
                    <div class="result-icon success-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <h1 class="result-title">Thanh toán thành công!</h1>
                    <p class="result-message">Cảm ơn bạn đã mua hàng. Đơn hàng của bạn đã được thanh toán trực tuyến thành công và an toàn qua Ví điện tử MoMo.</p>
                </c:when>
                <c:otherwise>
                    <div class="result-icon error-icon">
                        <i class="fas fa-times-circle"></i>
                    </div>
                    <h1 class="result-title">Thanh toán thất bại</h1>
                    <p class="result-message">Giao dịch qua MoMo không thành công hoặc đã bị hủy. Vui lòng kiểm tra lại số dư ví MoMo của bạn hoặc thử thanh toán lại.</p>
                </c:otherwise>
            </c:choose>

            <div class="transaction-details">
                <div class="detail-row">
                    <span class="detail-label">Phương thức:</span>
                    <span class="detail-value" style="color: #e11b74;">Ví điện tử MoMo</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Mã đơn hàng:</span>
                    <span class="detail-value">#${requestScope.orderId}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Mã giao dịch MoMo:</span>
                    <span class="detail-value">${requestScope.paymentCode}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Số tiền đã trả:</span>
                    <span class="detail-value" style="font-size: 16px; color: #333;">
                        <fmt:setLocale value="vi_VN" />
                        <fmt:formatNumber value="${amount}" type="currency" currencySymbol="₫" maxFractionDigits="0" />
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Nội dung thanh toán:</span>
                    <span class="detail-value">${orderInfo}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Thời gian thực hiện:</span>
                    <span class="detail-value">${payDate}</span>
                </div>
            </div>

            <div class="action-buttons">
                <a href="${pageContext.request.contextPath}/store" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Tiếp tục mua sắm
                </a>
                <a href="${pageContext.request.contextPath}/order-detail?id=${requestScope.orderId}" class="btn btn-primary">
                    <i class="fas fa-file-invoice"></i> Xem chi tiết đơn
                </a>
            </div>
        </div>
    </main>

    <%@ include file="../components/footer.jsp" %>
</body>

</html>
