package services;

import dao.AddressDAO;
import jakarta.servlet.http.HttpServletRequest;
import model.Address;
import model.User;

import java.util.List;
import java.util.Optional;

public class AddressService {
    private AddressDAO addressDAO;
    private ProvinceService provinceService;
    private DistrictService districtService;
    private WardService wardService;

    public AddressService() {
        addressDAO = new AddressDAO();
        provinceService = new ProvinceService();
        districtService = new DistrictService();
        wardService = new WardService();
    }

    private static final String VN_TEXT_REGEX = "^[^0-9\\!\\@\\#\\$\\^\\&\\*\\(\\)\\_\\+\\=\\{\\}\\[\\]\\|\\\\\\:\\;\\\"\\'\\<\\>\\?\\.\\,\\/\\~\\`\\-]+$";
    private static final String VN_PHONE_REGEX = "^0[0-9]{9,10}$";

    public List<Address> getAll() {
        return addressDAO.findAll();
    }

    public List<Address> getByUserID(int id) {
        return addressDAO.getByUserID(id);
    }

    public Address addAddress(Address address) {
        String error = validateAddress(address);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        return addressDAO.save(address);
    }

    public Address updateAddress(Address address, int userId) {

        if (address == null || address.getId() <= 0) {
            throw new IllegalArgumentException("Địa chỉ không hợp lệ");
        }

        Optional<Address> old = addressDAO.findById(address.getId());
        if (old.isEmpty() || old.get().getUserId() != userId) {
            throw new SecurityException("Không có quyền cập nhật địa chỉ này");
        }

        String error = validateAddress(address);
        if (error != null) {
            throw new IllegalArgumentException(error);
        }
        return addressDAO.save(address);
    }

    public boolean deleteAddress(int id) {

        if (id <= 0) {
            throw new IllegalArgumentException("ID địa chỉ không hợp lệ");
        }

        Optional<Address> existing = addressDAO.findById(id);
        if (existing == null) {
            throw new IllegalArgumentException("Địa chỉ không tồn tại");
        }

        return addressDAO.deleteById(id);
    }

    private String validateAddress(Address address) {
        System.out.println(address);

        if (address == null)
            return "Dữ liệu không hợp lệ";
        String name = address.getFullName();
        String phone = address.getPhoneNumber();
        String city = address.getCity();
        String district = address.getDistrict();
        String ward = address.getWard();
        String addressLine = address.getAddressLine();

        if (name == null || !name.matches(VN_TEXT_REGEX)) {
            return "Họ tên không hợp lệ (không được chứa số hoặc ký tự đặc biệt)";
        }

        if (phone == null || !phone.matches(VN_PHONE_REGEX)) {
            return "Số điện thoại không hợp lệ (phải từ 10-11 số và đúng đầu số mạng VN)";
        }

        if (city == null || city.trim().isEmpty()) {
            return "Vui lòng chọn Thành phố/Tỉnh";
        }

        if (district == null || district.trim().isEmpty()) {
            return "Vui lòng chọn Quận/Huyện";
        }

        if (ward == null || ward.trim().isEmpty()) {
            return "Vui lòng chọn Phường/Xã";
        }

        if (addressLine == null || addressLine.trim().length() < 5) {
            return "Địa chỉ cụ thể phải từ 5 ký tự trở lên";
        }

        return null;
    }

    public void setDefaultAddress(int addressId, int userId) {
        if (addressId <= 0) {
            throw new IllegalArgumentException("ID địa chỉ không hợp lệ");
        }

        addressDAO.unsetAllDefaults(userId);

        Address newDefault = new Address();
        newDefault.setId(addressId);
        newDefault.setUserId(userId);
        newDefault.setDefault(true);
        addressDAO.setDefault(newDefault);
    }

    public void handleAdd(HttpServletRequest req, User user) {
        Address address = mapRequestToAddress(req);
        address.setUserId(user.getId());

        this.addAddress(address);
    }

    public void handleUpdate(HttpServletRequest req, User user) {
        int addressId = Integer.parseInt(req.getParameter("id"));

        Address address = mapRequestToAddress(req);
        address.setId(addressId);
        address.setUserId(user.getId());

        this.updateAddress(address, user.getId());
    }

    public void handleDelete(HttpServletRequest req, User user) {
        int id = Integer.parseInt(req.getParameter("id"));
        this.deleteAddress(id);
    }

    public void handleSetDefault(HttpServletRequest req, User user) {
        int id = Integer.parseInt(req.getParameter("id"));
        this.setDefaultAddress(id, user.getId());
    }

    private Address mapRequestToAddress(HttpServletRequest req) {
        Address address = new Address();

        address.setFullName(req.getParameter("fullName"));
        address.setPhoneNumber(req.getParameter("phone"));

        String provinceId = req.getParameter("provinceId");
        String districtId = req.getParameter("districtId");
        String wardId = req.getParameter("wardId");

        if (provinceId != null && !provinceId.isEmpty()) {
            var p = provinceService.getProvinceById(provinceId);
            if (p != null) address.setCity(p.getProvinceName());
        }

        if (districtId != null && !districtId.isEmpty()) {
            var d = districtService.getDistrictById(districtId);
            if (d != null) address.setDistrict(d.getDistrictName());
        }

        if (wardId != null && !wardId.isEmpty()) {
            var w = wardService.getWardById(wardId);
            if (w != null) address.setWard(w.getWardName());
        }

        address.setAddressLine(req.getParameter("addressLine"));

        return address;
    }

}
