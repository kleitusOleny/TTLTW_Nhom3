<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng</title>
    <link rel="stylesheet" href="css/cart_style.css">
    <style>
        /* CSS cho Custom Popup */
        .popup-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            display: flex; justify-content: center; align-items: center;
            z-index: 9999;
        }
        .popup-content {
            background: #fff; padding: 25px; border-radius: 8px;
            text-align: center; min-width: 320px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.2);
        }
        #popup-message {
            font-size: 16px; margin-bottom: 20px; color: #333;
        }
        .popup-actions {
            display: flex; justify-content: center; gap: 15px;
        }
        .popup-actions button {
            padding: 10px 20px; border: none; border-radius: 5px;
            cursor: pointer; font-weight: bold; font-size: 14px;
        }
        .btn-primary { background: #d9534f; color: white; border: 2px solid #000000 !important;}
        .btn-primary:hover { background: #c9302c; }
        .btn-secondary { background: #e0e0e0; color: #333; }
        .btn-secondary:hover { background: #ccc; }
    </style>
</head>

<body>

<%@ include file="components/header.jsp" %>

<main>
    <div class="cart-container container">

        <h1 class="cart-title">Giỏ hàng</h1>
        <div class="cart-grid-container">
            <div class="cart-items-column">
                <table class="cart-table">
                    <thead>
                    <tr>
                        <th><input type="checkbox" id="select-all"></th>
                        <th colspan="2">Sản phẩm</th>
                        <th>Giá</th>
                        <th>Số lượng</th>
                        <th>Tạm tính</th>
                        <th></th>
                    </tr>
                    </thead>

                    <tbody>
                    <c:forEach items="${sessionScope.cart.items}" var="ci">
                        <tr class="cart-item-row">
                            <td><input type="checkbox" class="select-product" value="${ci.product.id}"></td>
                            <td class="cart-product-image">
                                <a href="detail?id=${ci.product.id}">
                                    <img src=${ci.product.imageUrl} alt="${ci.product.productName}">
                                </a>
                            </td>
                            <td class="cart-product-name">
                                <a href="detail?id=${ci.product.id}">${ci.product.productName}</a>
                            </td>
                            <td class="cart-product-price">
                                <fmt:setLocale value="vi_VN"/>
                                <c:choose>
                                    <c:when test="${ci.price < ci.product.price}">
                                        <span style="color: #8c3333; font-weight: bold;">
                                            <fmt:formatNumber value="${ci.price}"
                                                              type="currency" currencySymbol="₫"
                                                              maxFractionDigits="0"/>
                                        </span>
                                        <br>
                                        <span style="text-decoration: line-through; color: #999; font-size: 0.9em;">
                                            <fmt:formatNumber value="${ci.product.price}"
                                                              type="currency" currencySymbol="₫"
                                                              maxFractionDigits="0"/>
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:formatNumber value="${ci.price}" type="currency"
                                                          currencySymbol="₫" maxFractionDigits="0"/>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="cart-product-quantity">
                                <div class="quantity-selector">
                                    <form action="update-item" method="post">
                                        <input type="hidden" name="id" value="${ci.product.id}">
                                        <input type="hidden" name="quantity" value="-1">
                                        <button class="quantity-btn">-</button>
                                    </form>

                                    <form action="update-item" method="post">
                                        <input type="hidden" name="id" value="${ci.product.id}">
                                        <input type="number" value="${ci.quantity}"
                                               name="setQuantity" onchange="this.form.submit()">
                                    </form>

                                    <form action="update-item" method="post">
                                        <input type="hidden" name="id" value="${ci.product.id}">
                                        <input type="hidden" name="quantity" value="1">
                                        <button class="quantity-btn">+</button>
                                    </form>
                                </div>
                            </td>
                            <td class="cart-product-subtotal">
                                <fmt:setLocale value="vi_VN"/>
                                <fmt:formatNumber value="${ci.totalPrice}" type="currency"
                                                  currencySymbol="₫" maxFractionDigits="0"/>
                            </td>
                            <td class="cart-product-remove">
                                <form action="delete-cart" method="post">
                                    <input type="hidden" name="id" value="${ci.product.id}">
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
                <div class="cart-actions">
                    <a href="store" class="btn btn-secondary">Tiếp tục xem sản phẩm</a>
                    <button class="btn btn-danger" id="delete-selected">Xóa sản phẩm đã chọn</button>
                </div>
            </div>

            <div class="cart-summary-column">
                <div class="summary-box">
                    <h3 class="summary-title">Tổng cộng</h3>

                    <div class="summary-row">
                        <span>Tạm tính</span>
                        <strong>
                            <fmt:setLocale value="vi_VN"/>
                            <fmt:formatNumber value="${sessionScope.cart.subtotal}" type="currency"
                                              currencySymbol="₫" maxFractionDigits="0"/>
                        </strong>
                    </div>

                    <div class="summary-row">
                        <span>Giao hàng</span>
                        <strong>Miễn phí</strong>
                    </div>

                    <div class="summary-total">
                        <span>Tổng</span>
                        <strong id="final-total-display">
                            <fmt:setLocale value="vi_VN"/>
                            <fmt:formatNumber value="${sessionScope.cart.total}" type="currency"
                                              currencySymbol="₫" maxFractionDigits="0"/>
                        </strong>
                    </div>

                    <a href="checkout" class="btn btn-checkout">Tiến hành thanh toán</a>
                </div>
            </div>

        </div>
    </div>
</main>

<%@ include file="components/footer.jsp" %>

<div id="custom-popup" class="popup-overlay" style="display: none;">
    <div class="popup-content">
        <p id="popup-message"></p>
        <div class="popup-actions">
            <button id="popup-cancel" class="btn btn-secondary" style="display: none;">Hủy</button>
            <button id="popup-confirm" class="btn btn-primary">Đồng ý</button>
        </div>
    </div>
</div>

<script>
    function formatMoney(amount) {
        return new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(amount);
    }

    // Hàm điều khiển Popup
    function showPopup(message, isConfirm, onConfirmCallback) {
        const popup = document.getElementById('custom-popup');
        const msgEl = document.getElementById('popup-message');
        const btnCancel = document.getElementById('popup-cancel');
        const btnConfirm = document.getElementById('popup-confirm');

        msgEl.textContent = message;
        popup.style.display = 'flex';

        if (isConfirm) {
            btnCancel.style.display = 'inline-block';
        } else {
            btnCancel.style.display = 'none';
        }

        btnConfirm.onclick = function() {
            popup.style.display = 'none';
            if (onConfirmCallback) onConfirmCallback();
        };

        btnCancel.onclick = function() {
            popup.style.display = 'none';
        };
    }

    document.addEventListener('DOMContentLoaded', function () {
        const selectAllCheckbox = document.getElementById('select-all');
        const productCheckboxes = document.querySelectorAll('.select-product');
        const deleteSelectedButton = document.getElementById('delete-selected');

        selectAllCheckbox.addEventListener('change', function () {
            productCheckboxes.forEach(checkbox => {
                checkbox.checked = selectAllCheckbox.checked;
            });
        });

        productCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function () {
                const allChecked = Array.from(productCheckboxes).every(cb => cb.checked);
                const someChecked = Array.from(productCheckboxes).some(cb => cb.checked);
                selectAllCheckbox.checked = allChecked;
                selectAllCheckbox.indeterminate = someChecked && !allChecked;
            });
        });

        // Xử lý sự kiện click xóa hàng loạt dùng fetch API
        deleteSelectedButton.addEventListener('click', function () {
            const selectedIds = [];

            productCheckboxes.forEach(checkbox => {
                if (checkbox.checked && checkbox.value) {
                    selectedIds.push(checkbox.value);
                }
            });

            if (selectedIds.length > 0) {
                showPopup('Bạn có chắc chắn muốn xóa ' + selectedIds.length + ' sản phẩm đã chọn khỏi giỏ hàng?', true, function() {

                    const formData = new URLSearchParams();
                    formData.append('listId', selectedIds.join(','));
                    formData.append('ajax', 'true');

                    fetch('${pageContext.request.contextPath}/delete-cart', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: formData.toString()
                    })
                        .then(response => {
                            if (response.ok) {
                                showPopup('Đã xóa ' + selectedIds.length + ' sản phẩm thành công.', false, function() {
                                    window.location.reload();
                                });
                            } else {
                                showPopup('Lỗi: Không thể xóa sản phẩm lúc này.', false);
                            }
                        })
                        .catch(error => {
                            console.error('Error:', error);
                            showPopup('Lỗi kết nối máy chủ.', false);
                        });
                });
            } else {
                showPopup('Vui lòng chọn ít nhất một sản phẩm để xóa.', false);
            }
        });
    });
</script>
</body>
</html>