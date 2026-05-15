package dao;

import model.District;
import java.util.List;
import java.util.Optional;

public class DistrictDAO extends ADAO implements IDAO<District, String> {

    @Override
    public List<District> findAll() {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, province_id, code, district_name, support_type, type FROM districts ORDER BY district_name ASC")
                .mapToBean(District.class)
                .list()
        );
    }

    public List<District> findByProvinceId(String provinceId) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, province_id, code, district_name, support_type, type FROM districts WHERE province_id = :provinceId ORDER BY district_name ASC")
                .bind("provinceId", provinceId)
                .mapToBean(District.class)
                .list()
        );
    }

    public List<District> findByProvinceName(String provinceName) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT d.id, d.province_id, d.code, d.district_name, d.support_type, d.type " +
                             "FROM districts d JOIN provinces p ON d.province_id = p.id " +
                             "WHERE p.province_name = :provinceName ORDER BY d.district_name ASC")
                .bind("provinceName", provinceName)
                .mapToBean(District.class)
                .list()
        );
    }

    @Override
    public Optional<District> findById(String id) {
        return jdbi.withHandle(handle ->
            handle.createQuery("SELECT id, province_id, code, district_name, support_type, type FROM districts WHERE id = :id")
                .bind("id", id)
                .mapToBean(District.class)
                .findFirst()
        );
    }

    @Override
    public District save(District entity) {
        jdbi.useHandle(handle ->
            handle.createUpdate("INSERT INTO districts (id, province_id, code, district_name, support_type, type) " +
                                "VALUES (:id, :province_id, :code, :district_name, :support_type, :type) " +
                                "ON DUPLICATE KEY UPDATE province_id = :province_id, code = :code, " +
                                "district_name = :district_name, support_type = :support_type, type = :type")
                .bindBean(entity)
                .execute()
        );
        return entity;
    }

    @Override
    public boolean deleteById(String id) {
        return jdbi.withHandle(handle ->
            handle.createUpdate("DELETE FROM districts WHERE id = :id")
                .bind("id", id)
                .execute() > 0
        );
    }

    @Override
    public boolean existsById(String id) {
        return findById(id).isPresent();
    }
}
