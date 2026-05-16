package services;

import dao.DistrictDAO;
import model.District;
import java.util.List;

public class DistrictService {
    private DistrictDAO districtDAO;

    public DistrictService() {
        this.districtDAO = new DistrictDAO();
    }

    public List<District> getAllDistricts() {
        return districtDAO.findAll();
    }

    public List<District> getDistrictsByProvince(String provinceId) {
        return districtDAO.findByProvinceId(provinceId);
    }

    public List<District> getDistrictsByProvinceName(String provinceName) {
        return districtDAO.findByProvinceName(provinceName);
    }

    public District getDistrictById(String id) {
        return districtDAO.findById(id).orElse(null);
    }
}
