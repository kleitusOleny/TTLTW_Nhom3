package services;

import dao.ProvinceDAO;
import model.Province;
import java.util.List;

public class ProvinceService {
    private ProvinceDAO provinceDAO;

    public ProvinceService() {
        this.provinceDAO = new ProvinceDAO();
    }

    public List<Province> getAllProvinces() {
        return provinceDAO.findAll();
    }

    public Province getProvinceById(String id) {
        return provinceDAO.findById(id).orElse(null);
    }
}
