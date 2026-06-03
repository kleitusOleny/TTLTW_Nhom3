<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />
    <link rel="stylesheet" href="<%=request.getContextPath()%>/css/evalute_style.css">
    <%@ include file="../components/header.jsp" %>

        <body>
            <div class="review-container">
                <h1>Đánh giá đơn hàng #${order.id}</h1>

                <c:if test="${not empty param.success}">
                    <div class="alert alert-success"
                        style="background-color: #d4edda; color: #155724; padding: 10px; margin-bottom: 20px; border-radius: 5px;">
                        Cảm ơn bạn đã đánh giá sản phẩm!
                    </div>
                </c:if>

                <c:forEach items="${items}" var="item">
                    <c:set var="product" value="${productMap[item.productId]}" />
                    <div class="product-review">
                        <img src="${product.imageUrl}" alt="${product.productName}"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/img/default.png'">
                        <div class="review-content">
                            <h3>${product.productName}</h3>
                            <c:choose>
                                <c:when test="${evaluatedProductIds != null and evaluatedProductIds.contains(item.productId)}">
                                    <div class="alert alert-success" style="background-color: #e9ecef; color: #495057; padding: 10px; margin-top: 15px; border-radius: 5px; text-align: center;">
                                        <i class="fa-solid fa-check"></i> Bạn đã đánh giá sản phẩm này
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <form action="${pageContext.request.contextPath}/evaluate" method="post" enctype="multipart/form-data">
                                        <input type="hidden" name="orderId" value="${order.id}">
                                        <input type="hidden" name="productId" value="${item.productId}">
                                        <input type="hidden" name="rating" id="rating-${item.productId}" value="5">

                                        <div class="stars" data-product-id="${item.productId}">
                                            <i class="fa-regular fa-star" data-value="1"></i>
                                            <i class="fa-regular fa-star" data-value="2"></i>
                                            <i class="fa-regular fa-star" data-value="3"></i>
                                            <i class="fa-regular fa-star" data-value="4"></i>
                                            <i class="fa-regular fa-star" data-value="5"></i>
                                        </div>

                                        <textarea name="content" placeholder="Viết cảm nhận của bạn..." required></textarea>
                                        
                                        <!-- Thêm phần tải ảnh -->
                                        <div class="image-upload" style="margin-top: 10px; margin-bottom: 10px;">
                                            <label for="image-${item.productId}" style="cursor: pointer; display: inline-flex; align-items: center; gap: 5px; color: #555; font-size: 14px;">
                                                <i class="fa-solid fa-camera"></i> Thêm hình ảnh (tùy chọn)
                                            </label>
                                            <input type="file" id="image-${item.productId}" name="image" accept="image/*" style="display: none;" onchange="previewImage(this, 'preview-${item.productId}')">
                                            <img id="preview-${item.productId}" src="#" alt="Preview" style="display: none; margin-top: 10px; max-width: 150px; max-height: 150px; border-radius: 5px; object-fit: cover; border: 1px solid #ccc;">
                                        </div>

                                        <button type="submit">Gửi đánh giá</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </c:forEach>

                <div style="text-align: center; margin-top: 20px;">
                    <a href="${returnUrl}" class="btn"
                        style="background-color: #666; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">Quay
                        lại đơn hàng</a>
                </div>
            </div>

            <%@ include file="../components/footer.jsp" %>

                <script>
                    function previewImage(input, previewId) {
                        const preview = document.getElementById(previewId);
                        if (input.files && input.files[0]) {
                            const reader = new FileReader();
                            reader.onload = function (e) {
                                preview.src = e.target.result;
                                preview.style.display = 'block';
                            }
                            reader.readAsDataURL(input.files[0]);
                        } else {
                            preview.style.display = 'none';
                        }
                    }

                    document.addEventListener('DOMContentLoaded', function () {
                        const starContainers = document.querySelectorAll('.stars');

                        starContainers.forEach(container => {
                            const stars = container.querySelectorAll('i');
                            const productId = container.getAttribute('data-product-id');
                            const ratingInput = document.getElementById('rating-' + productId);

                            stars.forEach((star, index) => {
                                star.addEventListener('mousemove', function (e) {
                                    const rect = this.getBoundingClientRect();
                                    const isLeftHalf = e.clientX - rect.left < rect.width / 2;
                                    const value = index + (isLeftHalf ? 0.5 : 1);
                                    highlightStars(container, value);
                                });

                                star.addEventListener('click', function (e) {
                                    const rect = this.getBoundingClientRect();
                                    const isLeftHalf = e.clientX - rect.left < rect.width / 2;
                                    const value = index + (isLeftHalf ? 0.5 : 1);
                                    ratingInput.value = value;
                                    updateStars(container, value);
                                });
                            });

                            container.addEventListener('mouseleave', function () {
                                const currentValue = parseFloat(ratingInput.value);
                                updateStars(container, currentValue);
                            });

                            // Initialize with 5 stars
                            updateStars(container, 5);
                        });

                        function updateStars(container, value) {
                            const stars = container.querySelectorAll('i');
                            stars.forEach((star, index) => {
                                star.className = 'fa-regular fa-star'; // Reset
                                star.style.color = '#ccc';

                                if (value >= index + 1) {
                                    star.className = 'fa-solid fa-star';
                                    star.style.color = '#ffc107';
                                } else if (value >= index + 0.5) {
                                    star.className = 'fa-solid fa-star-half-stroke';
                                    star.style.color = '#ffc107';
                                }
                            });
                        }

                        function highlightStars(container, value) {
                            updateStars(container, value);
                        }
                    });
                </script>

        </body>

    </html>