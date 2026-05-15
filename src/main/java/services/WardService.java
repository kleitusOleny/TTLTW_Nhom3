package services;

import dao.WardDAO;
import model.Ward;
import java.util.List;

public class WardService {
    private WardDAO wardDAO;

    public WardService() {
        this.wardDAO = new WardDAO();
    }

    public List<Ward> getAllWards() {
        return wardDAO.findAll();
    }

    public List<Ward> getWardsByDistrict(String provinceId, String districtId) {
        return wardDAO.findByProvinceAndDistrict(provinceId, districtId);
    }

    public List<Ward> getWardsByNames(String provinceName, String districtName) {
        return wardDAO.findByNames(provinceName, districtName);
    }

    public Ward getWardById(String id) {
        return wardDAO.findById(id).orElse(null);
    }
}
