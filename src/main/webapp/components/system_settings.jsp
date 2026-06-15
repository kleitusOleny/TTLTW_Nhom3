<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<style>
/* Settings Button and Modal Styles */
.settings-btn-global {
    margin-left: 15px;
    cursor: pointer;
    font-size: 18px;
    color: #333;
    transition: color 0.3s;
}
.settings-btn-global:hover {
    color: #8c3333;
}
.settings-modal-overlay {
    position: fixed;
    top: 0; left: 0; width: 100%; height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 999999;
    display: none;
    justify-content: center;
    align-items: center;
    opacity: 0;
    transition: opacity 0.3s ease;
}
.settings-modal-overlay.active {
    display: flex;
    opacity: 1;
}
.settings-modal-content {
    background: #fff;
    width: 350px;
    border-radius: 12px;
    padding: 25px;
    box-shadow: 0 10px 25px rgba(0,0,0,0.2);
    position: relative;
    transform: translateY(-20px);
    transition: transform 0.3s ease;
    font-family: 'Roboto', sans-serif;
}
.settings-modal-overlay.active .settings-modal-content {
    transform: translateY(0);
}
.settings-modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid #eee;
    padding-bottom: 15px;
    margin-bottom: 20px;
}
.settings-modal-header h3 {
    margin: 0;
    font-size: 18px;
    color: #333;
}
.settings-modal-close {
    cursor: pointer;
    font-size: 20px;
    color: #888;
    background: none;
    border: none;
}
.settings-modal-close:hover {
    color: #333;
}
.setting-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}
.setting-label {
    font-size: 15px;
    color: #555;
    display: flex;
    align-items: center;
    gap: 10px;
}
/* Toggle Switch */
.switch {
    position: relative;
    display: inline-block;
    width: 44px;
    height: 24px;
}
.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}
.slider {
    position: absolute;
    cursor: pointer;
    top: 0; left: 0; right: 0; bottom: 0;
    background-color: #ccc;
    transition: .4s;
    border-radius: 24px;
}
.slider:before {
    position: absolute;
    content: "";
    height: 18px;
    width: 18px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: .4s;
    border-radius: 50%;
}
input:checked + .slider {
    background-color: #8c3333;
}
input:checked + .slider:before {
    transform: translateX(20px);
}
/* Language Select */
.lang-select {
    padding: 6px 12px;
    border-radius: 6px;
    border: 1px solid #ccc;
    font-family: inherit;
    font-size: 14px;
    outline: none;
}
.lang-select:focus {
    border-color: #8c3333;
}

/* Modern Professional Dark Mode (Premium Wine Aesthetic) */
body.dark-theme {
    background-color: #161313 !important; /* Deep warm charcoal */
    color: #fdfaf2 !important; /* Bright cream */
}

/* Header Icons */
body.dark-theme .header-top i,
body.dark-theme .settings-btn-global i,
body.dark-theme .cart-link i {
    color: #ffffff !important;
}

body.dark-theme .site-header, 
body.dark-theme .header-top, 
body.dark-theme .header-nav-bar,
body.dark-theme .footer,
body.dark-theme .settings-modal-content,
body.dark-theme .mega-menu,
body.dark-theme .card,
body.dark-theme .card-custom,
body.dark-theme .product-card,
body.dark-theme .order-card,
body.dark-theme .order-detail,
body.dark-theme .orders-container,
body.dark-theme .cart-container,
body.dark-theme .checkout-container,
body.dark-theme .user-sidebar,
body.dark-theme .product-info-column,
body.dark-theme .product-gallery-column,
body.dark-theme .main-image-container,
body.dark-theme .service-widget,
body.dark-theme .tab-content,
body.dark-theme .review-filter-bar,
body.dark-theme .review-item {
    background-color: #241e1e !important; /* Premium wine surface */
    color: #fdfaf2 !important;
    border-color: #382d2d !important;
}

/* Force text colors to overcome original CSS */
body.dark-theme p,
body.dark-theme li,
body.dark-theme span:not(.price):not(.order-status),
body.dark-theme .product-name a,
body.dark-theme .service-list span,
body.dark-theme .review-content {
    color: #fdfaf2 !important;
}

body.dark-theme .section,
body.dark-theme .order-body,
body.dark-theme .order-header,
body.dark-theme .product-detail-container,
body.dark-theme .detail-grid-container {
    background-color: transparent !important;
    border-color: #382d2d !important;
}

body.dark-theme h1,
body.dark-theme h2,
body.dark-theme h3,
body.dark-theme h4,
body.dark-theme .product-detail-title {
    color: #ffffff !important; /* Pure white for headings to pop */
    font-family: 'Playfair Display', serif; 
}

body.dark-theme .product-specs-list li {
    border-bottom-color: #382d2d !important;
}
body.dark-theme .product-specs-list span {
    color: #a89a9a !important; /* Soft grey for labels */
}
body.dark-theme .product-specs-list strong {
    color: #fdfaf2 !important; /* Bright cream for values */
}

body.dark-theme .review-filter-bar button.filter-btn {
    background-color: #332a2a !important;
    color: #e8e1d5 !important;
    border-color: #4a3f3f !important;
}
body.dark-theme .review-filter-bar button.filter-btn.active {
    color: #d4af37 !important; /* Champagne gold */
    border-color: #d4af37 !important;
}

body.dark-theme table, 
body.dark-theme th, 
body.dark-theme td {
    background-color: transparent !important;
    color: #fdfaf2 !important;
    border-color: #382d2d !important;
}

body.dark-theme input, 
body.dark-theme select, 
body.dark-theme textarea {
    background-color: #2c2525 !important;
    color: #ffffff !important;
    border-color: #4a3f3f !important;
}

body.dark-theme .search-form {
    background-color: #2c2525 !important;
}

body.dark-theme .search-form input[type="text"],
body.dark-theme .search-form button {
    background-color: transparent !important;
    border-color: transparent !important;
}

body.dark-theme .search-form button i {
    color: #e8c366 !important;
}

body.dark-theme a {
    color: inherit;
}

body.dark-theme .price,
body.dark-theme .total-price,
body.dark-theme strong,
body.dark-theme .product-price span {
    color: #e8c366 !important; /* Brighter gold for better contrast */
}

/* Specific overrides for settings modal */
body.dark-theme .settings-modal-header h3 {
    color: #ffffff !important;
}
body.dark-theme .setting-label {
    color: #fdfaf2 !important;
}
body.dark-theme .settings-modal-close {
    color: #a89a9a !important;
}
body.dark-theme .settings-modal-header {
    border-bottom: 1px solid #382d2d !important;
}

/* ======== MEGA MENU ======== */
body.dark-theme .mega-menu {
    background-color: #1a1515 !important;
    border-top-color: #382d2d !important;
}
body.dark-theme .mega-menu-title {
    color: #fdfaf2 !important;
    border-bottom-color: #382d2d !important;
}
body.dark-theme .mega-menu-link {
    color: #a89a9a !important;
}
body.dark-theme .mega-menu-link:hover {
    color: #e8c366 !important;
}

/* ======== STORE FILTER SIDEBAR ======== */
body.dark-theme .filter-content {
    background-color: transparent !important;
}
body.dark-theme .filter-title,
body.dark-theme .widget-title {
    color: #fdfaf2 !important;
    border-bottom-color: #382d2d !important;
}
body.dark-theme .filter-list label {
    color: #a89a9a !important;
}
body.dark-theme .filter-list label:hover {
    color: #fdfaf2 !important;
}
body.dark-theme .price-values,
body.dark-theme .price-values span,
body.dark-theme #min-price-display,
body.dark-theme #max-price-display {
    color: #e8c366 !important;
}
body.dark-theme .display-container p,
body.dark-theme .type-wine {
    color: #fdfaf2 !important;
}
body.dark-theme .pagination-container a,
body.dark-theme .pagination .page-link {
    color: #e8e1d5 !important;
    background-color: #241e1e !important;
    border-color: #382d2d !important;
}
body.dark-theme .pagination .page-item.active .page-link {
    background-color: #8c3333 !important;
    color: #fff !important;
    border-color: #8c3333 !important;
}
body.dark-theme .pagination .page-item.disabled .page-link {
    color: #666 !important;
    background-color: #1a1515 !important;
}

/* ======== PRODUCT CARDS & PRODUCT GRIDS ======== */
body.dark-theme .product-card {
    background-color: #241e1e !important;
    border-color: #382d2d !important;
}

body.dark-theme .product-card:hover {
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4) !important;
}

body.dark-theme .product-image {
    background-color: #2c2525 !important;
}

body.dark-theme .product-info {
    background-color: #241e1e !important;
}

body.dark-theme .product-name {
    color: #fdfaf2 !important;
}

body.dark-theme .product-name a {
    color: #fdfaf2 !important;
}

body.dark-theme .product-name a:hover {
    color: #e8c366 !important;
}

body.dark-theme .product-producer {
    color: #a89a9a !important;
}

body.dark-theme .product-extra-details,
body.dark-theme .product-extra-details ul li {
    color: #c4b8b8 !important;
}

body.dark-theme .product-rating span {
    color: #a89a9a !important;
}

body.dark-theme .product-price {
    color: #e8c366 !important;
}

body.dark-theme .add-to-cart-btn {
    background-color: #382d2d !important;
    color: #fdfaf2 !important;
    border-color: #4a3f3f !important;
}

body.dark-theme .add-to-cart-btn:hover {
    background-color: #8c3333 !important;
    color: #ffffff !important;
    border-color: #8c3333 !important;
}

body.dark-theme .buy-now-btn {
    background-color: #8c3333 !important;
    color: #ffffff !important;
}

/* ======== SECTION TITLES & SUBTITLES ======== */
body.dark-theme .section-title {
    color: #fdfaf2 !important;
}

body.dark-theme .section-subtitle {
    color: #a89a9a !important;
}

/* ======== FEATURED BRANDS SECTION ======== */
body.dark-theme .featured-brands {
    background-color: #1a1515 !important;
    border-color: #382d2d !important;
}

body.dark-theme .brand-logo-box {
    background-color: #2c2525 !important;
    border-color: #382d2d !important;
}

body.dark-theme .brand-logo-box:hover {
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.3) !important;
}

body.dark-theme .brand-logo-box img {
    filter: grayscale(50%) brightness(1.2) !important;
}

body.dark-theme .brand-logo-box:hover img {
    filter: grayscale(0%) brightness(1) !important;
}

/* ======== BLOG / CẨM NANG SECTION ======== */
body.dark-theme .blog-section {
    background-color: #161313 !important;
}

body.dark-theme .blog-card {
    background-color: #241e1e !important;
    border-color: #382d2d !important;
}

body.dark-theme .blog-card:hover {
    box-shadow: 0 8px 20px rgba(0, 0, 0, 0.4) !important;
}

body.dark-theme .blog-content {
    background-color: #241e1e !important;
}

body.dark-theme .blog-title,
body.dark-theme .blog-title a {
    color: #fdfaf2 !important;
}

body.dark-theme .blog-title a:hover {
    color: #e8c366 !important;
}

body.dark-theme .blog-excerpt {
    color: #a89a9a !important;
}

body.dark-theme .read-more-btn {
    color: #e8c366 !important;
}

/* ======== SERVICE COMMITMENT SECTION ======== */
body.dark-theme .service-commitment-section {
    background-color: #161313 !important;
}

body.dark-theme .service-item h4 {
    color: #fdfaf2 !important;
}

body.dark-theme .service-item p {
    color: #a89a9a !important;
}

body.dark-theme .service-item i {
    color: #e8c366 !important;
}

/* ======== SCROLL BUTTONS ======== */
body.dark-theme .scroll-btn {
    background: rgba(36, 30, 30, 0.95) !important;
    border-color: #382d2d !important;
    color: #fdfaf2 !important;
}

body.dark-theme .scroll-btn:hover {
    background: #8c3333 !important;
    color: #ffffff !important;
    border-color: #8c3333 !important;
}

/* ======== CAROUSEL ======== */
body.dark-theme .carousel-item {
    background-color: #161313 !important;
}

/* ======== WISHLIST BUTTON ======== */
body.dark-theme .wishlist-btn {
    background-color: rgba(36, 30, 30, 0.9) !important;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4) !important;
}

body.dark-theme .wishlist-btn:hover {
    background-color: #8c3333 !important;
}

/* ======== DETAIL PAGE: Tư vấn sidebar ======== */
body.dark-theme .service-widget {
    background-color: #241e1e !important;
    border-color: #382d2d !important;
}

body.dark-theme .service-widget .btn,
body.dark-theme .service-widget a.btn {
    background-color: #382d2d !important;
    color: #fdfaf2 !important;
    border-color: #4a3f3f !important;
}

body.dark-theme .service-widget .btn:hover,
body.dark-theme .service-widget a.btn:hover {
    background-color: #4a3f3f !important;
}

/* ======== INLINE STYLE OVERRIDES (for JSP hardcoded colors) ======== */
body.dark-theme [style*="color: #222"],
body.dark-theme [style*="color:#222"] {
    color: #fdfaf2 !important;
}

body.dark-theme [style*="color: #333"],
body.dark-theme [style*="color:#333"] {
    color: #fdfaf2 !important;
}

body.dark-theme [style*="color: #555"],
body.dark-theme [style*="color:#555"] {
    color: #a89a9a !important;
}

body.dark-theme [style*="color: #666"],
body.dark-theme [style*="color:#666"] {
    color: #a89a9a !important;
}

body.dark-theme [style*="color: #777"],
body.dark-theme [style*="color:#777"] {
    color: #a89a9a !important;
}

body.dark-theme [style*="color: #888"],
body.dark-theme [style*="color:#888"] {
    color: #8a7e7e !important;
}

body.dark-theme [style*="color: #999"],
body.dark-theme [style*="color:#999"] {
    color: #8a7e7e !important;
}

/* Bootstrap modal dark mode */
body.dark-theme .modal-content {
    background-color: #241e1e !important;
    border-color: #382d2d !important;
    color: #fdfaf2 !important;
}

body.dark-theme .modal-header {
    border-bottom-color: #382d2d !important;
}

body.dark-theme .modal-footer {
    border-top-color: #382d2d !important;
}

body.dark-theme .btn-close {
    filter: invert(1) !important;
}

/* ======== FLASH SALE / VOUCHER SECTIONS ======== */
body.dark-theme .voucher-card,
body.dark-theme .flash-sale-card {
    background-color: #241e1e !important;
    border-color: #382d2d !important;
}

body.dark-theme .voucher-card:hover,
body.dark-theme .flash-sale-card:hover {
    box-shadow: 0 6px 15px rgba(0, 0, 0, 0.4) !important;
}

/* Hide Google Translate UI */
.goog-te-banner-frame.skiptranslate, .goog-te-gadget-icon {
    display: none !important;
}
body {
    top: 0px !important;
}
#google_translate_element {
    display: none;
}
</style>

<div class="settings-modal-overlay" id="settingsModal">
    <div class="settings-modal-content">
        <div class="settings-modal-header">
            <h3><i class="fas fa-sliders-h" style="margin-right: 8px; color: #8c3333;"></i> Cài đặt hệ thống</h3>
            <button class="settings-modal-close" onclick="closeSettings()">&times;</button>
        </div>
        
        <div class="setting-item">
            <div class="setting-label"><i class="fas fa-moon"></i> Chế độ Tối (Dark Mode)</div>
            <label class="switch">
                <input type="checkbox" id="darkModeToggle" onchange="toggleDarkMode(this.checked)">
                <span class="slider"></span>
            </label>
        </div>

        <div class="setting-item">
            <div class="setting-label"><i class="fas fa-globe"></i> Ngôn ngữ & Tiền tệ</div>
            <select class="lang-select" id="langToggle" onchange="toggleLanguage(this.value)">
                <option value="vi">Tiếng Việt (VND)</option>
                <option value="en">English (USD)</option>
            </select>
        </div>
    </div>
</div>

<div id="google_translate_element"></div>

<script type="text/javascript">
    // --- Dark Mode Logic ---
    function applyDarkMode() {
        const isDark = localStorage.getItem('theme') === 'dark';
        document.getElementById('darkModeToggle').checked = isDark;
        if (isDark) {
            document.body.classList.add('dark-theme');
        } else {
            document.body.classList.remove('dark-theme');
        }
    }

    function toggleDarkMode(isDark) {
        if (isDark) {
            localStorage.setItem('theme', 'dark');
        } else {
            localStorage.setItem('theme', 'light');
        }
        applyDarkMode();
    }

    // --- Language & Currency Logic ---
    const EXCHANGE_RATE = 25000;

    function applyLanguageAndCurrency() {
        const lang = localStorage.getItem('app_lang') || 'vi';
        document.getElementById('langToggle').value = lang;
        
        if (lang === 'en') {
            convertCurrencyToUSD();
            triggerGoogleTranslate('en');
        } else {
            triggerGoogleTranslate('vi');
            // Currency is already in VND from server. If they switch back, page reloads.
        }
    }

    function toggleLanguage(lang) {
        localStorage.setItem('app_lang', lang);
        // Reload to let the server render original VND, then script converts
        window.location.reload();
    }

    function triggerGoogleTranslate(targetLang) {
        const translateSelect = document.querySelector('.goog-te-combo');
        if (translateSelect) {
            translateSelect.value = targetLang;
            translateSelect.dispatchEvent(new Event('change'));
        }
    }

    function googleTranslateElementInit() {
        new google.translate.TranslateElement({
            pageLanguage: 'vi', 
            includedLanguages: 'en,vi',
            autoDisplay: false
        }, 'google_translate_element');
        
        // Wait a bit for widget to initialize before triggering if needed
        setTimeout(() => {
            const lang = localStorage.getItem('app_lang') || 'vi';
            if (lang === 'en') {
                triggerGoogleTranslate('en');
            }
        }, 1000);
    }

    function convertCurrencyToUSD() {
        const walk = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
        let node;
        const regex = /([\d.,]+)\s*(₫|VND)/g;
        const nodesToReplace = [];
        
        while (node = walk.nextNode()) {
            // Ignore script and style tags
            if (node.parentElement && (node.parentElement.tagName === 'SCRIPT' || node.parentElement.tagName === 'STYLE')) {
                continue;
            }
            if (regex.test(node.nodeValue)) {
                nodesToReplace.push(node);
            }
        }
        
        nodesToReplace.forEach(node => {
            node.nodeValue = node.nodeValue.replace(regex, function(match, p1) {
                let numStr = p1.replace(/\./g, '').replace(/,/g, '');
                let num = parseFloat(numStr);
                if (!isNaN(num)) {
                    let usd = num / EXCHANGE_RATE;
                    return '$' + usd.toFixed(2);
                }
                return match;
            });
        });

        // Also fix placeholder inputs if any
        document.querySelectorAll('input[placeholder]').forEach(input => {
            let placeholder = input.getAttribute('placeholder');
            if (placeholder && regex.test(placeholder)) {
                input.setAttribute('placeholder', placeholder.replace(regex, function(match, p1) {
                    let numStr = p1.replace(/\./g, '').replace(/,/g, '');
                    let num = parseFloat(numStr);
                    if (!isNaN(num)) {
                        return '$' + (num / EXCHANGE_RATE).toFixed(2);
                    }
                    return match;
                }));
            }
        });
    }

    // --- Modal Logic ---
    function openSettings() {
        document.getElementById('settingsModal').classList.add('active');
    }

    function closeSettings() {
        document.getElementById('settingsModal').classList.remove('active');
    }

    // Close on overlay click
    document.getElementById('settingsModal').addEventListener('click', function(e) {
        if (e.target === this) {
            closeSettings();
        }
    });

    // Run on load
    document.addEventListener('DOMContentLoaded', () => {
        applyDarkMode();
        
        // We wait a brief moment for dynamic content to finish loading (like carts)
        setTimeout(() => {
            applyLanguageAndCurrency();
        }, 300);
    });
</script>
<script type="text/javascript" src="https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
