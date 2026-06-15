document.addEventListener("DOMContentLoaded", function () {
    // Tìm tất cả các element có yêu cầu phân quyền
    const securedElements = document.querySelectorAll('[data-require-perm]');
    securedElements.forEach(function (el) {
        // Lấy chuỗi quyền yêu cầu
        const requiredPerms = el.getAttribute('data-require-perm').split(',');
        // Kiểm tra xem user có ít nhất 1 quyền trong số các quyền yêu cầu không
        const hasPermission = requiredPerms.some(perm => USER_PERMISSIONS.includes(perm.trim()));
        // Nếu không có quyền nào khớp, xóa sổ element này khỏi cấu trúc HTML
        if (!hasPermission) {
            el.remove();
        }
    });
});