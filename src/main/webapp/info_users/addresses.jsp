<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/address_style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css"
            integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A=="
            crossorigin="anonymous" referrerpolicy="no-referrer" />
        <!-- jQuery & Select2 -->
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
        <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
        <style>
            .autocomplete-wrapper {
                position: relative;
                width: 100%;
                display: flex;
                align-items: center;
            }
            .autocomplete-input {
                padding-left: 45px !important; /* Space for search icon */
                padding-right: 40px !important; /* Space for arrow */
                background: #f8fafc !important;
                border: 2px solid #edf2f7 !important;
                border-radius: 12px !important;
                height: 52px !important;
                font-size: 15px !important;
                font-weight: 500 !important;
                transition: all 0.3s ease !important;
                color: #2d3436 !important;
            }
            .autocomplete-input:focus {
                background: #fff !important;
                border-color: #c7a17a !important; /* secondary-color */
                box-shadow: 0 0 0 4px rgba(199, 161, 122, 0.1) !important;
                outline: none !important;
            }
            .search-icon {
                position: absolute;
                left: 18px;
                color: #8c3333; /* primary-color */
                font-size: 14px;
                pointer-events: none;
                z-index: 10;
            }
            .dropdown-arrow {
                position: absolute;
                right: 18px;
                color: #a0aec0;
                font-size: 12px;
                pointer-events: none;
                transition: transform 0.3s ease;
                z-index: 10;
            }
            .autocomplete-input:focus ~ .dropdown-arrow {
                transform: rotate(180deg);
                color: #c7a17a;
            }
            .suggestions-container {
                position: absolute;
                top: calc(100% + 5px);
                left: 0;
                right: 0;
                background: #fff;
                border: 1px solid #edf2f7;
                border-radius: 16px;
                max-height: 280px;
                overflow-y: auto;
                z-index: 2000;
                box-shadow: 0 10px 25px rgba(0,0,0,0.08);
                display: none;
                padding: 8px;
                animation: slideUpModal 0.3s ease-out;
            }
            @keyframes slideUpModal {
                from { opacity: 0; transform: translateY(10px); }
                to { opacity: 1; transform: translateY(0); }
            }
            .suggestion-item {
                padding: 12px 15px;
                cursor: pointer;
                border-radius: 10px;
                transition: all 0.2s;
                font-size: 14px;
                display: flex;
                align-items: center;
                gap: 12px;
                color: #2d3436;
                margin-bottom: 2px;
            }
            .suggestion-item i {
                color: #c7a17a;
                font-size: 14px;
                opacity: 0.8;
            }
            .suggestion-item:hover, .suggestion-item.active {
                background: #fdf8f3;
                color: #8c3333;
                transform: translateX(5px);
            }
            .suggestion-item b {
                color: #8c3333;
                font-weight: 700;
            }
            .form-group label {
                font-weight: 700 !important;
                color: #2d3436 !important;
            }
        </style>
        <div id="address-card">
            <h2>Địa chỉ của tôi</h2>
            <c:if test="${not empty sessionScope.error}">
                <div class="alert alert-danger auto-hide">${sessionScope.error}</div>
                <c:remove var="error" scope="session" />
            </c:if>

            <c:if test="${not empty sessionScope.success}">
                <div class="alert alert-success auto-hide">${sessionScope.success}</div>
                <c:remove var="success" scope="session" />
            </c:if>
            <div class="address-list">
                <c:forEach var="addr" items="${addressList}">
                    <div class="address-card" data-fullname="${addr.fullName}" data-phone="${addr.phoneNumber}"
                        data-address="${addr.addressLine}, ${addr.ward}, ${addr.city}">

                        <div class="address-card-info">
                            <div class="info-item">
                                <span class="info-label">Người nhận:</span>
                                <span class="info-value">
                                    <strong>${addr.fullName}</strong>
                                    <c:if test="${addr.isDefault}">
                                        <span class="badge-default" style="margin-left: 8px;">Mặc định</span>
                                    </c:if>
                                </span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Số điện thoại:</span>
                                <span class="info-value">${addr.phoneNumber}</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Địa chỉ:</span>
                                <span class="info-value">${addr.addressLine}, ${addr.ward}, ${addr.district},
                                    ${addr.city}</span>
                            </div>
                        </div>

                        <div class="address-card-actions">
                            <div class="action-row">
                                <c:if test="${not addr.isDefault}">
                                    <form action="${pageContext.request.contextPath}/address" method="post"
                                        style="display:inline;">
                                        <input type="hidden" name="action" value="default">
                                        <input type="hidden" name="id" value="${addr.id}">
                                        <button type="submit" class="btn-default">Đặt mặc định</button>
                                    </form>
                                </c:if>
                                <button class="btn-icon edit-btn" data-id="${addr.id}" data-name="${addr.fullName}"
                                    data-phone="${addr.phoneNumber}" data-city="${addr.city}" data-ward="${addr.ward}"
                                    data-district="${addr.district}" data-address="${addr.addressLine}"
                                    title="Chỉnh sửa">
                                    <i class="fa-solid fa-pen-to-square"></i>
                                </button>
                                <form action="${pageContext.request.contextPath}/address" method="post"
                                    style="display:inline;"
                                    onsubmit="return confirm('Bạn có chắc chắn muốn xóa địa chỉ này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${addr.id}">
                                    <button type="submit" class="btn-icon delete-btn" title="Xóa">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>

            <!-- ADD -->
            <button class="add-address-btn" id="add-address-btn">
                <i class="fa-solid fa-plus"></i> Thêm địa chỉ mới
            </button>
        </div>

        <div id="addressModal" class="modal">
            <div class="modal-content">
                <div class="modal-header">
                    <h3>Địa chỉ mới</h3>
                    <span class="cancel-btn">&times;</span>
                </div>

                <form id="addressForm" action="${pageContext.request.contextPath}/address" method="post" novalidate>
                    <input type="hidden" name="action" id="formAction" value="add">
                    <input type="hidden" name="id" id="addressId">
                    <input type="hidden" name="view" value="${view}">

                    <div class="form-group" id="addr_group-fullName">
                        <label>Họ và tên</label>
                        <input type="text" id="addr_fullName" name="fullName" class="editable-input"
                            placeholder="VD: Nguyễn Văn A" required>
                        <span id="addr_error-fullName" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-phone">
                        <label>Số điện thoại</label>
                        <input type="text" id="addr_phone" name="phone" class="editable-input"
                            placeholder="VD: 0912345678" required>
                        <span id="addr_error-phone" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-city">
                        <label>Tỉnh/Thành phố</label>
                        <div class="autocomplete-wrapper">
                            <i class="fa-solid fa-magnifying-glass search-icon"></i>
                            <input type="text" id="addr_city" name="city" class="editable-input autocomplete-input" 
                                   placeholder="Tìm kiếm Tỉnh/Thành phố..." required autocomplete="off">
                            <input type="hidden" id="addr_provinceId" name="provinceId">
                            <i class="fa-solid fa-chevron-down dropdown-arrow"></i>
                            <div id="provincesSuggestions" class="suggestions-container"></div>
                        </div>
                        <span id="addr_error-city" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-district">
                        <label>Quận/Huyện</label>
                        <div class="autocomplete-wrapper">
                            <i class="fa-solid fa-location-dot search-icon"></i>
                            <input type="text" id="addr_district" name="district" class="editable-input autocomplete-input" 
                                   placeholder="Chọn Quận/Huyện..." required disabled autocomplete="off">
                            <input type="hidden" id="addr_districtId" name="districtId">
                            <i class="fa-solid fa-chevron-down dropdown-arrow"></i>
                            <div id="districtsSuggestions" class="suggestions-container"></div>
                        </div>
                        <span id="addr_error-district" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-ward">
                        <label>Phường/Xã</label>
                        <div class="autocomplete-wrapper">
                            <i class="fa-solid fa-map-pin search-icon"></i>
                            <input type="text" id="addr_ward" name="ward" class="editable-input autocomplete-input" 
                                   placeholder="Chọn Phường/Xã..." required disabled autocomplete="off">
                            <input type="hidden" id="addr_wardId" name="wardId">
                            <i class="fa-solid fa-chevron-down dropdown-arrow"></i>
                            <div id="wardsSuggestions" class="suggestions-container"></div>
                        </div>
                        <span id="addr_error-ward" class="error-msg"></span>
                    </div>

                    <div class="form-group" id="addr_group-addressLine">
                        <label>Địa chỉ chi tiết</label>
                        <input type="text" id="addr_addressLine" name="addressLine" class="editable-input"
                            placeholder="Số nhà, tên đường..." required>
                        <span id="addr_error-addressLine" class="error-msg"></span>
                    </div>

                    <button type="submit" class="add-address-btn" id="submitBtn">
                        <i class="fa-solid fa-save"></i> <span id="submitText">Lưu địa chỉ</span>
                    </button>
                </form>
            </div>
        </div>

        <script src="<%= request.getContextPath() %>/preventspace.js"></script>
        <script>
            function setStatus(id, isValid, message = "") {
                const input = document.getElementById('addr_' + id);
                const group = document.getElementById('addr_group-' + id);
                const errorSpan = document.getElementById('addr_error-' + id);
                if (!input || !group || !errorSpan) return;

                if (isValid) {
                    group.classList.remove("has-error");
                    group.classList.add("has-success");
                    errorSpan.textContent = "";
                } else {
                    group.classList.remove("has-success");
                    group.classList.add("has-error");
                    errorSpan.textContent = message;
                }
            }

            const validators = {
                fullName: () => {
                    const el = document.getElementById("addr_fullName");
                    const val = el.value.trim();
                    const namePattern = /^[\p{L}]+( [\p{L}]+)*$/u;
                    const isValid = val.length >= 2 && namePattern.test(val);
                    setStatus("fullName", isValid, val ? (namePattern.test(val) ? "" : "Họ tên không được chứa số, ký tự đặc biệt hoặc khoảng trắng thừa") : "Họ tên không được để trống");
                    return isValid;
                },
                phone: () => {
                    const el = document.getElementById("addr_phone");
                    const val = el.value.trim();
                    const phonePattern = /^0\d{9,10}$/;
                    const isValid = phonePattern.test(val);
                    setStatus("phone", isValid, "Số điện thoại phải bắt đầu bằng 0 và có 10-11 chữ số");
                    return isValid;
                },
                city: () => {
                    const el = document.getElementById("addr_city");
                    const isValid = el.value.trim().length >= 2;
                    setStatus("city", isValid, "Vui lòng nhập Tỉnh/Thành phố");
                    return isValid;
                },
                district: () => {
                    const el = document.getElementById("addr_district");
                    const isValid = el.value.trim().length >= 2;
                    setStatus("district", isValid, "Vui lòng nhập Quận/Huyện");
                    return isValid;
                },
                ward: () => {
                    const el = document.getElementById("addr_ward");
                    const isValid = el.value.trim().length >= 2;
                    setStatus("ward", isValid, "Vui lòng nhập Phường/Xã");
                    return isValid;
                },
                addressLine: () => {
                    const el = document.getElementById("addr_addressLine");
                    const val = el.value.trim();
                    const isValid = val.length >= 5;
                    setStatus("addressLine", isValid, "Địa chỉ cụ thể phải từ 5 ký tự trở lên");
                    return isValid;
                }
            };

            (function () {
                const modal = document.getElementById('addressModal');
                const addBtn = document.getElementById('add-address-btn');
                const form = document.getElementById('addressForm');
                const submitText = document.getElementById('submitText');

                if (!modal || !addBtn || !form) return;

                const closeBtn = modal.querySelector('.cancel-btn');

                let geoState = {
                    provinces: [],
                    districts: [],
                    wards: []
                };

                const setupAutocomplete = (inputId, listId, items, nameKey, onSelect) => {
                    const input = document.getElementById(inputId);
                    const container = document.getElementById(listId);
                    let activeIndex = -1;
                    
                    const highlight = (text, query) => {
                        if (!query) return text;
                        const re = new RegExp(`(\${query})`, 'gi');
                        return text.replace(re, '<b>$1</b>');
                    };

                    const renderMatches = (matches, query = "") => {
                        container.innerHTML = '';
                        activeIndex = -1;
                        if (matches.length > 0) {
                            matches.forEach((match, index) => {
                                const div = document.createElement('div');
                                div.className = 'suggestion-item';
                                div.innerHTML = `<i class="fa-solid fa-location-dot"></i> <span>\${highlight(match[nameKey], query)}</span>`;
                                div.onclick = () => selectItem(match);
                                container.appendChild(div);
                            });
                            container.style.display = 'block';
                        } else {
                            container.style.display = 'none';
                        }
                    };

                    const selectItem = (match) => {
                        input.value = match[nameKey];
                        container.style.display = 'none';
                        onSelect(match);
                        
                        // Trigger validation
                        const baseId = inputId.replace('addr_', '');
                        if (validators[baseId]) validators[baseId]();
                    };

                    const updateActive = (divs) => {
                        divs.forEach((div, i) => {
                            div.classList.toggle('active', i === activeIndex);
                            if (i === activeIndex) div.scrollIntoView({ block: 'nearest' });
                        });
                    };

                    input.addEventListener('focus', function() {
                        const val = this.value.toLowerCase();
                        if (!val) {
                            renderMatches(items.slice(0, 50));
                        } else {
                            this.dispatchEvent(new Event('input'));
                        }
                    });

                    input.addEventListener('input', function() {
                        const val = this.value.toLowerCase();
                        const matches = items.filter(item => 
                            item[nameKey].toLowerCase().includes(val)
                        );
                        renderMatches(matches, val);
                    });

                    input.addEventListener('keydown', function(e) {
                        const items_divs = container.querySelectorAll('.suggestion-item');
                        if (e.key === 'ArrowDown') {
                            e.preventDefault();
                            activeIndex = Math.min(activeIndex + 1, items_divs.length - 1);
                            updateActive(items_divs);
                        } else if (e.key === 'ArrowUp') {
                            e.preventDefault();
                            activeIndex = Math.max(activeIndex - 1, -1);
                            updateActive(items_divs);
                        } else if (e.key === 'Enter' && activeIndex > -1) {
                            e.preventDefault();
                            items_divs[activeIndex].click();
                        }
                    });

                    // Hide on outside click
                    document.addEventListener('click', (e) => {
                        if (e.target !== input) container.style.display = 'none';
                    });
                };

                const loadProvinces = async (selectedName = null) => {
                    try {
                        const res = await fetch('${pageContext.request.contextPath}/api/provinces');
                        geoState.provinces = await res.json();
                        setupAutocomplete('addr_city', 'provincesSuggestions', geoState.provinces, 'provinceName', (p) => {
                            document.getElementById('addr_provinceId').value = p.id;
                            const districtInput = document.getElementById('addr_district');
                            const wardInput = document.getElementById('addr_ward');
                            districtInput.value = '';
                            document.getElementById('addr_districtId').value = '';
                            wardInput.value = '';
                            document.getElementById('addr_wardId').value = '';
                            districtInput.disabled = false;
                            wardInput.disabled = true;
                            loadDistricts(p.id, p.provinceName);
                        });
                        if (selectedName) document.getElementById('addr_city').value = selectedName;
                        return geoState.provinces;
                    } catch (e) { console.error("Load provinces error:", e); }
                };

                const loadDistricts = async (provinceId, provinceName, selectedName = null) => {
                    try {
                        const url = '${pageContext.request.contextPath}/api/districts?provinceId=' + provinceId + '&provinceName=' + encodeURIComponent(provinceName);
                        const res = await fetch(url);
                        geoState.districts = await res.json();
                        setupAutocomplete('addr_district', 'districtsSuggestions', geoState.districts, 'districtName', (d) => {
                            document.getElementById('addr_districtId').value = d.id;
                            const wardInput = document.getElementById('addr_ward');
                            wardInput.value = '';
                            document.getElementById('addr_wardId').value = '';
                            wardInput.disabled = false;
                            loadWards(provinceId, provinceName, d.id, d.districtName);
                        });
                        if (selectedName) document.getElementById('addr_district').value = selectedName;
                        return geoState.districts;
                    } catch (e) { console.error("Load districts error:", e); }
                };

                const loadWards = async (provinceId, provinceName, districtId, districtName, selectedName = null) => {
                    try {
                        const url = '${pageContext.request.contextPath}/api/wards?provinceId=' + provinceId + '&provinceName=' + encodeURIComponent(provinceName) + 
                                    '&districtId=' + districtId + '&districtName=' + encodeURIComponent(districtName);
                        const res = await fetch(url);
                        geoState.wards = await res.json();
                        setupAutocomplete('addr_ward', 'wardsSuggestions', geoState.wards, 'wardName', (w) => {
                            document.getElementById('addr_wardId').value = w.id;
                        });
                        if (selectedName) document.getElementById('addr_ward').value = selectedName;
                        return geoState.wards;
                    } catch (e) { console.error("Load wards error:", e); }
                };

                const open = async (isEdit = false, data = null) => {
                    modal.style.display = 'flex';
                    const cityInput = document.getElementById('addr_city');
                    const districtInput = document.getElementById('addr_district');
                    const wardInput = document.getElementById('addr_ward');

                    try {
                        await loadProvinces(data ? data.city : null);
                        
                        if (isEdit && data) {
                            const province = geoState.provinces.find(p => p.provinceName === cityInput.value);

                            if (province) {
                                districtInput.disabled = false;
                                await loadDistricts(province.id, province.provinceName, data.district);
                                
                                const district = geoState.districts.find(d => d.districtName === districtInput.value);

                                if (province && district) {
                                    document.getElementById('addr_provinceId').value = province.id;
                                    document.getElementById('addr_districtId').value = district.id;
                                    wardInput.disabled = false;
                                    await loadWards(province.id, province.provinceName, district.id, district.districtName, data.ward);
                                    
                                    const ward = geoState.wards.find(w => w.wardName === wardInput.value);
                                    if (ward) document.getElementById('addr_wardId').value = ward.id;
                                }
                            }
                            Object.keys(validators).forEach(key => validators[key]());
                        } else {
                            form.reset();
                            document.getElementById('formAction').value = 'add';
                            submitText.textContent = 'Lưu địa chỉ';
                            form.querySelectorAll('.editable-input').forEach(input => {
                                input.classList.remove('input-error', 'input-valid');
                            });
                            form.querySelectorAll('.error-msg').forEach(s => s.style.display = 'none');
                            
                            districtInput.disabled = true;
                            wardInput.disabled = true;
                        }
                    } catch (err) { console.error("Modal open error:", err); }
                };

                const close = () => {
                    modal.style.display = 'none';
                };

                // Attach real-time validation
                Object.keys(validators).forEach(key => {
                    const el = document.getElementById('addr_' + key);
                    if (el) {
                        el.addEventListener('input', validators[key]);
                        el.addEventListener('blur', validators[key]);
                    }
                });

                form.onsubmit = function (e) {
                    let isAllValid = true;
                    Object.keys(validators).forEach(key => {
                        if (!validators[key]()) isAllValid = false;
                    });

                    if (!isAllValid) {
                        e.preventDefault();
                        const firstError = form.querySelector('.has-error');
                        if (firstError) firstError.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        return false;
                    }
                    submitText.textContent = 'Đang xử lý...';
                };

                addBtn.addEventListener('click', () => open(false));
                if (closeBtn) closeBtn.addEventListener('click', close);
                window.addEventListener('click', e => { if (e.target === modal) close(); });

                // Vanilla Delegation for Edit Buttons
                document.addEventListener('click', async (e) => {
                    const editBtn = e.target.closest('.edit-btn');
                    if (editBtn) {
                        e.stopPropagation();
                        const ds = editBtn.dataset;
                        document.getElementById('formAction').value = 'edit';
                        document.getElementById('addressId').value = ds.id;
                        form.fullName.value = ds.name || '';
                        form.phone.value = ds.phone || '';
                        form.addressLine.value = ds.address || '';
                        submitText.textContent = 'Cập nhật địa chỉ';
                        await open(true, ds);
                        return;
                    }

                    const card = e.target.closest('.address-card');
                    if (card && !e.target.closest('.btn-icon, .btn-default, .delete-btn')) {
                        const data = {
                            fullName: card.dataset.fullname,
                            phone: card.dataset.phone,
                            address: card.dataset.address
                        };
                        window.parent.postMessage({ type: 'SELECT_ADDRESS', data: data }, '*');
                    }
                });
            })();
        </script>
        <script>
            (function () {
                const alerts = document.querySelectorAll(".auto-hide");
                alerts.forEach(alert => {
                    setTimeout(() => {
                        alert.style.transition = "opacity 0.5s ease";
                        alert.style.opacity = "0";
                        setTimeout(() => alert.remove(), 500);
                    }, 2500);
                });
            })();
        </script>