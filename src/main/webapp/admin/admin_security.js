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

// Auto inject mobile header for admin dashboard
document.addEventListener("DOMContentLoaded", function () {
    if (!document.querySelector('.admin-mobile-header')) {
        const container = document.querySelector('.dashboard-container') || document.body;
        
        const header = document.createElement('div');
        header.className = 'admin-mobile-header';
        
        const toggle = document.createElement('div');
        toggle.className = 'admin-mobile-toggle';
        toggle.innerHTML = '<ion-icon name="menu-outline"></ion-icon>';
        
        const logo = document.createElement('div');
        logo.className = 'admin-mobile-logo';
        logo.innerText = 'ADMIN DASHBOARD';
        
        const rightSpace = document.createElement('div');
        rightSpace.style.width = '28px'; // To center the logo
        
        header.appendChild(toggle);
        header.appendChild(logo);
        header.appendChild(rightSpace);
        
        if (container.firstChild) {
            container.insertBefore(header, container.firstChild);
        } else {
            container.appendChild(header);
        }
        
        toggle.addEventListener('click', function() {
            const sidebar = document.querySelector('.dashboard-sidebar');
            if(sidebar) {
                sidebar.classList.toggle('active-mobile');
            }
        });
        
        // click outside to close
        document.addEventListener('click', function(e) {
            const sidebar = document.querySelector('.dashboard-sidebar');
            if (sidebar && sidebar.classList.contains('active-mobile') && !sidebar.contains(e.target) && !header.contains(e.target)) {
                sidebar.classList.remove('active-mobile');
            }
        });
    }
    
    // Add table-responsive class wrapper to all raw tables inside .dashboard-main-content
    const mainContent = document.querySelector('.dashboard-main-content');
    if (mainContent) {
        const tables = mainContent.querySelectorAll('table');
        tables.forEach(table => {
            if (!table.parentElement.classList.contains('table-responsive')) {
                const wrapper = document.createElement('div');
                wrapper.className = 'table-responsive';
                wrapper.style.width = '100%';
                wrapper.style.overflowX = 'auto';
                wrapper.style.WebkitOverflowScrolling = 'touch';
                table.parentNode.insertBefore(wrapper, table);
                wrapper.appendChild(table);
            }
        });
    }
});

